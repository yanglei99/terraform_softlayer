organization  := "spark.xgboost"

name := "spark-xgboost-test"

version       := "0.1-SNAPSHOT"

scalaVersion  := "2.11.8"

fork in run := true

resolvers ++= Seq(
  "typesafe repo" at "http://repo.typesafe.com/typesafe/releases/"
)

libraryDependencies ++= {
  val sparkV =  "2.1.0"
  val xgboostV = "0.7"
  Seq(
    "org.apache.spark"    %  "spark-core_2.11"	  %  sparkV % "provided",
    "org.apache.spark"    %  "spark-mllib_2.11"	  %  sparkV % "provided",
    "org.apache.spark"    %  "spark-sql_2.11"	  %  sparkV % "provided"
  )
}

libraryDependencies += "xgboost" % "spark" % "0.7" % "provided" from "file:///./lib/xgboost4j-spark-0.7-jar-with-dependencies.jar"

assemblyOption in assembly := (assemblyOption in assembly).value.copy(includeScala = false)

assemblyMergeStrategy in assembly := {
  case "reference.conf"   => MergeStrategy.first
  case PathList("scala", xs @ _*) => MergeStrategy.discard
  case x =>
    val oldStrategy = (assemblyMergeStrategy in assembly).value
    oldStrategy(x)
}

assemblyJarName in assembly := "spark-xgboost-test-assembly.jar"
