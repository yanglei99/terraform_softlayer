#!/usr/bin/env bash

# Reference https://docs.mesosphere.com/1.9/administration/logging/aggregating/elk/

curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-5.0.0-x86_64.rpm
sudo rpm -vi filebeat-5.0.0-x86_64.rpm

sudo mkdir -p /var/log/dcos

sudo mv /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.BAK

sudo tee /etc/filebeat/filebeat.yml <<-EOF 
filebeat.prospectors:
- input_type: log
  paths:
    - /var/lib/mesos/slave/slaves/*/frameworks/*/executors/*/runs/latest/stdout
    - /var/lib/mesos/slave/slaves/*/frameworks/*/executors/*/runs/latest/stderr
    - /var/log/mesos/*.log
    - /var/log/dcos/dcos.log
tail_files: true
output.elasticsearch:
  hosts: ["http://elasticsearch.marathon.mesos:9200"]
EOF

if [ "$1" = "master" ]; then 

sudo tee /etc/systemd/system/dcos-journalctl-filebeat.service<<-EOF 
[Unit]
Description=DCOS journalctl parser to filebeat
Wants=filebeat.service
After=filebeat.service

[Service]
Restart=always
RestartSec=5
ExecStart=/bin/sh -c '/usr/bin/journalctl --no-tail -f \
  -u dcos-3dt.service \
  -u dcos-3dt.socket \
  -u dcos-adminrouter-reload.service \
  -u dcos-adminrouter-reload.timer   \
  -u dcos-adminrouter.service        \
  -u dcos-bouncer.service            \
  -u dcos-ca.service                 \
  -u dcos-cfn-signal.service         \
  -u dcos-cosmos.service             \
  -u dcos-download.service           \
  -u dcos-epmd.service               \
  -u dcos-exhibitor.service          \
  -u dcos-gen-resolvconf.service     \
  -u dcos-gen-resolvconf.timer       \
  -u dcos-history.service            \
  -u dcos-link-env.service           \
  -u dcos-logrotate-master.timer     \
  -u dcos-marathon.service           \
  -u dcos-mesos-dns.service          \
  -u dcos-mesos-master.service       \
  -u dcos-metronome.service          \
  -u dcos-minuteman.service          \
  -u dcos-navstar.service            \
  -u dcos-networking_api.service     \
  -u dcos-secrets.service            \
  -u dcos-setup.service              \
  -u dcos-signal.service             \
  -u dcos-signal.timer               \
  -u dcos-spartan-watchdog.service   \
  -u dcos-spartan-watchdog.timer     \
  -u dcos-spartan.service            \
  -u dcos-vault.service              \
  -u dcos-logrotate-master.service  \
  > /var/log/dcos/dcos.log 2>&1'
ExecStartPre=/usr/bin/journalctl --vacuum-size=10M

[Install]
WantedBy=multi-user.target
EOF

else

sudo tee /etc/systemd/system/dcos-journalctl-filebeat.service<<-EOF 
[Unit]
Description=DCOS journalctl parser to filebeat
Wants=filebeat.service
After=filebeat.service

[Service]
Restart=always
RestartSec=5
ExecStart=/bin/sh -c '/usr/bin/journalctl --no-tail -f      \
  -u dcos-3dt.service                      \
  -u dcos-logrotate-agent.timer            \
  -u dcos-3dt.socket                       \
  -u dcos-mesos-slave.service              \
  -u dcos-adminrouter-agent.service        \
  -u dcos-minuteman.service                \
  -u dcos-adminrouter-reload.service       \
  -u dcos-navstar.service                  \
  -u dcos-adminrouter-reload.timer         \
  -u dcos-rexray.service                   \
  -u dcos-cfn-signal.service               \
  -u dcos-setup.service                    \
  -u dcos-download.service                 \
  -u dcos-signal.timer                     \
  -u dcos-epmd.service                     \
  -u dcos-spartan-watchdog.service         \
  -u dcos-gen-resolvconf.service           \
  -u dcos-spartan-watchdog.timer           \
  -u dcos-gen-resolvconf.timer             \
  -u dcos-spartan.service                  \
  -u dcos-link-env.service                 \
  -u dcos-vol-discovery-priv-agent.service \
  -u dcos-logrotate-agent.service          \
  > /var/log/dcos/dcos.log 2>&1'
ExecStartPre=/usr/bin/journalctl --vacuum-size=10M

[Install]
WantedBy=multi-user.target
EOF

fi


sudo chmod 0755 /etc/systemd/system/dcos-journalctl-filebeat.service
sudo systemctl daemon-reload
sudo systemctl start dcos-journalctl-filebeat.service
sudo chkconfig dcos-journalctl-filebeat.service on
sudo systemctl start filebeat
sudo chkconfig filebeat on

