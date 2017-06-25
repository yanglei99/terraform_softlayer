
package mytest.spark

/**
 * @author yanglei
 * 
 * Revised from:  
 * 		 https://apsportal.ibm.com/analytics/notebooks/78be018b-021c-431a-8408-c8c5b1b355b3/view?access_token=64b7542b28abfe6c60dc3c690fbf14095c47f0bd7b205afd2ffb65fdf21b7358
 *
 * Reference: 
 * 		https://www.elenacuoco.com/2016/10/10/scala-spark-xgboost-classification/
 *     https://docs.databricks.com/_static/notebooks/xgboost.html
 * 
 * Data Preparation:
 * 
 *     Data Set cleansed from : https://www.lendingclub.com/info/download-data.action
 *     
 *     Input data under <train_path>/input
 *     
 *         loan_sub_new.csv
 * 
 *     Output model will be saved under <train_path>/results
 *     
 * To Run on a Master Node
 *
 *        spark-submit --class "mytest.spark.LendingXGBoost" --master $SPARK_MASTER --conf spark.driver.memory=6g  --conf spark.driver.cores=3 --conf spark.executor.memory=6g --conf spark.executor.cores=4 --packages org.apache.hadoop:hadoop-aws:2.7.3 --properties-file /root/myspark.properties --jars /root/xgboost/jvm-packages/xgboost4j-spark/target/xgboost4j-spark-0.7-jar-with-dependencies.jar  ./target/scala-2.11/spark-xgboost-test-assembly.jar 20 6 s3a://lending
 *      
 */


import java.util.Calendar
import org.apache.log4j.{Level, Logger}
import ml.dmlc.xgboost4j.scala.spark.XGBoost
import org.apache.spark.sql._
import org.apache.spark.sql.functions.lit
import org.apache.spark.ml.feature._
import org.apache.spark.SparkContext
import ml.dmlc.xgboost4j.scala.Booster
import org.apache.spark.ml.feature.StringIndexer
import org.apache.spark.ml.feature.OneHotEncoder
import org.apache.spark.ml.feature.VectorAssembler
import org.apache.spark.ml.evaluation.RegressionEvaluator



object LendingXGBoost {

	Logger.getLogger("org").setLevel(Level.WARN)

	def main(args: Array[String]): Unit = {
	  
	  if (args.length != 3) {
      println(
        "usage: program num_of_rounds num_workers train_path")
      sys.exit(1)
    }
	  
    val numRound = args(0).toInt
    val numWorkers = args(1).toInt
    val trainPath = args(2)
	  
    // create SparkSession
  	val spark = SparkSession
  	.builder()
  	.appName("Lending XGBoost Application")
  	.config("spark.serializer", "org.apache.spark.serializer.KryoSerializer")
  	.getOrCreate()

  	spark.sparkContext.getConf.registerKryoClasses(Array(classOf[Booster]))

  	val now=Calendar.getInstance()
  	val date=java.time.LocalDate.now
  	val currentHour = now.get(Calendar.HOUR_OF_DAY)
  	val currentMinute = now.get(Calendar.MINUTE)
  	val direct=trainPath+"/results/"+date+"-"+currentHour+"-"+currentMinute+"/"
  	println(s"output directory: $direct")
	
  	///read data from disk
  	var df_data_1 = spark.read.option("header", "true").option("inferSchema", true).csv(trainPath + "/input/loan_sub_new.csv")
	
  	println("original schema")
  	df_data_1.printSchema()
  	//prepare data for ML
    //1. Convert label into label indices using the StringIndexer

     val label_stringIdx = new StringIndexer()
        .setInputCol("default")
        .setOutputCol("label")
  
     df_data_1 = label_stringIdx.fit(df_data_1).transform(df_data_1)
  
     //2. One-hot encoder for all strings

    val categoricalColumns = Array("term", "home_ownership", "verification_status", "purpose", "addr_state")

    for (categoricalCol <- categoricalColumns)
    {
       var strIndex =  new StringIndexer()
              .setInputCol(categoricalCol)
              .setOutputCol(categoricalCol+"Index")
       var  oneHotEncoder = new OneHotEncoder()
              .setInputCol(categoricalCol+"Index")
              .setOutputCol(categoricalCol+"classVec")
              
       df_data_1 = strIndex.fit(df_data_1).transform(df_data_1)
       df_data_1 = oneHotEncoder.transform(df_data_1)  
    }
    
    // 3. Assemble feature vector
  
    val numericCols = Array("loan_amnt", "int_rate", "annual_inc", "dti", "delinq_2yrs", "mths_since_last_delinq", "total_acc", "inq_last_6mths", "mths_since_last_record", "open_acc", "pub_rec", "collections_12_mths_ex_med", "acc_now_delinq")
    val assemblerInputs = categoricalColumns.map(c => c + "classVec") ++ numericCols
  
    val assembler = new VectorAssembler()
      .setInputCols(assemblerInputs)
      .setOutputCol("features")
  
    df_data_1 = assembler.transform(df_data_1)
    
    df_data_1 = df_data_1.select("id","label", "features")
    
    println("transformed ML schema")
    df_data_1.printSchema()
    df_data_1.show()
    
    val Array(trainDF, testDF) = df_data_1.randomSplit(Array(0.7, 0.3), seed = 824)
    val trainCount = trainDF.count()
    val testCount =  testDF.count()

    println(s"VectorAssembler is done with train:$trainCount, test:$testCount")
    
	  val trainingData = trainDF.select("label", "features")
    val testData = testDF.select("label", "features")

  	// training parameters
  	val paramMap = List(
  	      "eta" -> 0.023f,
  	      "max_depth" -> 10,
  	      "min_child_weight" -> 3.0,
  	      "subsample" -> 1.0,
  	      "colsample_bytree" -> 0.82,
  	      "colsample_bylevel" -> 0.9,
  	      "base_score" -> 0.005,
  	      "eval_metric" -> "auc",
  	      "seed" -> 49,
  	      "silent" -> 1,
  	      "objective" -> "binary:logistic").toMap

  	println("Starting Xgboost ")
  	val xgBoostModelWithDF = XGBoost.trainWithDataFrame(trainingData, paramMap,round = numRound, nWorkers = numWorkers, useExternalMemory = true)
	
	  val predictions = xgBoostModelWithDF.setExternalMemory(true).transform(testData).select("label", "prediction", "probabilities")

	  val evaluator = new RegressionEvaluator()
      .setLabelCol("label")
      .setPredictionCol("prediction")
      .setMetricName("rmse")

    val rmse = evaluator.evaluate(predictions)
    println(s"Root mean squared error: $rmse")

	  // Save the predication as Parquet files, maintaining the schema information
    predictions.write.save(direct+"predictions.parquet")
    
	}

	}