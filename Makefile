OTEL_VERSION=0.114.0
NODE_EXPORTER_VERSION=1.8.2
PROCESS_EXPORTER_VERSION=0.8.4
BIN_FOLDER=/opt/otelcol
ETC_FOLDER=/etc/otelcol
TMP_FOLDER=/tmp/otelcol
SYSTEMD_SERVICES_PATH=/etc/systemd/system

bootstrap: otelcol-install process-exporter-install stack-up otelcol-restart process-exporter-start

clean: process-exporter-stop node-exporter-stop otelcol-stop stack-remove process-exporter-remove otelcol-remove node-exporter-remove
	sudo rm -Rf $(BIN_FOLDER) $(TMP_FOLDER) $(ETC_FOLDER)

bootstrap: otelcol-install node-exporter-install stack-up otelcol-start node-exporter-start

status-all: otelcol-status node-exporter-status process-exporter-status stack-ps

start-all: stack-up process-exporter-start node-exporter-start otelcol-start	

stop-all: otelcol-stop node-exporter-stop process-exporter-stop stack-stop

update-collectors: stop-collectors
	sudo cp process-exporter.yaml $(ETC_FOLDER)/process-exporter.yaml
	make otelcol-config
	make restart-collectors

stop-collectors: otelcol-stop process-exporter-stop node-exporter-stop

restart-collectors: otelcol-restart process-exporter-restart node-exporter-restart

process-exporter-download:
	mkdir -p $(TMP_FOLDER)
	curl -sL https://github.com/ncabatoff/process-exporter/releases/download/v$(PROCESS_EXPORTER_VERSION)/process-exporter-$(PROCESS_EXPORTER_VERSION).linux-amd64.tar.gz -o $(TMP_FOLDER)/process-exporter.tar.gz 

process-exporter-install: process-exporter-download
	sudo mkdir -p $(BIN_FOLDER)
	sudo tar xvf $(TMP_FOLDER)/process-exporter.tar.gz -C $(TMP_FOLDER) --strip-components=1
	sudo cp -a $(TMP_FOLDER)/process-exporter $(BIN_FOLDER)/
	sudo rm -Rf $(TMP_FOLDER)/* 
	sudo setcap CAP_SYS_PTRACE,CAP_DAC_READ_SEARCH=+eip $(BIN_FOLDER)/process-exporter
	sudo cp process-exporter.service $(SYSTEMD_SERVICES_PATH)/process-exporter.service
	sudo cp process-exporter.yaml $(ETC_FOLDER)/process-exporter.yaml
	sudo systemctl enable process-exporter.service
	sudo systemctl daemon-reload

process-exporter-remove: process-exporter-stop
	@-sudo systemctl disable process-exporter.service
	sudo rm -Rf $(BIN_FOLDER)/process-exporter $(SYSTEMD_SERVICES_PATH)/process-exporter.* $(ETC_FOLDER)/process-exporter.yaml
	sudo systemctl daemon-reload
	sudo systemctl reset-failed

process-exporter-stop:
	-sudo systemctl stop process-exporter.service

process-exporter-stop:
	-sudo systemctl stop process-exporter.service

process-exporter-start:
	sudo systemctl daemon-reload
	sudo systemctl start process-exporter.service

process-exporter-status:
	-sudo systemctl status process-exporter

process-exporter-logs:
	sudo journalctl --no-pager -fu process-exporter

process-exporter-dump:
	curl http://localhost:9256/metrics

process-exporter-restart: process-exporter-stop process-exporter-start

node-exporter-download:
	mkdir -p $(TMP_FOLDER)
	curl -sL https://github.com/prometheus/node_exporter/releases/download/v$(NODE_EXPORTER_VERSION)/node_exporter-$(NODE_EXPORTER_VERSION).linux-amd64.tar.gz -o $(TMP_FOLDER)/node-exporter.tar.gz 

node-exporter-install: node-exporter-download
	sudo mkdir -p $(BIN_FOLDER)
	sudo tar xvf $(TMP_FOLDER)/node-exporter.tar.gz -C $(TMP_FOLDER) --strip-components=1
	sudo cp -a $(TMP_FOLDER)/node_exporter $(BIN_FOLDER)/
	sudo rm -Rf $(TMP_FOLDER)/* 
	sudo setcap CAP_SYS_PTRACE,CAP_DAC_READ_SEARCH=+eip $(BIN_FOLDER)/node_exporter
	sudo mkdir -p /etc/systemd/system/node-exporter.d /var/lib/node-exporter/textfile_collector
	sudo cp node-exporter.service $(SYSTEMD_SERVICES_PATH)/node-exporter.service
	sudo cp node-exporter.conf $(SYSTEMD_SERVICES_PATH)/node-exporter.d/node-exporter.conf
	sudo systemctl enable node-exporter.service
	sudo systemctl daemon-reload

node-exporter-remove: node-exporter-stop
	@-sudo systemctl disable node-exporter.service
	sudo rm -Rf $(BIN_FOLDER)/node_exporter $(SYSTEMD_SERVICES_PATH)/node-exporter.* $(SYSTEMD_SERVICES_PATH)/node-exporter.d.* 
	sudo systemctl daemon-reload
	sudo systemctl reset-failed

node-exporter-stop:
	-sudo systemctl stop node-exporter.service

node-exporter-start:
	sudo systemctl daemon-reload
	sudo systemctl start node-exporter.service

node-exporter-status:
	-sudo systemctl status node-exporter

node-exporter-logs:
	sudo journalctl --no-pager -fu node-exporter

node-exporter-dump:
	curl http://localhost:9100/metrics

node-exporter-restart: node-exporter-stop node-exporter-start

otelcol-download:
	mkdir -p $(TMP_FOLDER)
	curl -sL https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v$(OTEL_VERSION)/otelcol-contrib_$(OTEL_VERSION)_linux_amd64.tar.gz -o $(TMP_FOLDER)/otelcol-contrib.tar.gz 

otelcol-install: otelcol-download
	sudo mkdir -p $(BIN_FOLDER) $(ETC_FOLDER) 
	sudo tar xvf $(TMP_FOLDER)/otelcol-contrib.tar.gz -C $(TMP_FOLDER) 
	sudo cp -a $(TMP_FOLDER)/otelcol-contrib $(BIN_FOLDER)/
	sudo rm -Rf $(TMP_FOLDER)/otelcol-contrib.tar.gz $(TMP_FOLDER)/* 
	sudo setcap CAP_SYS_PTRACE,CAP_DAC_READ_SEARCH=+eip $(BIN_FOLDER)/otelcol-contrib
	sudo cp otelcol.service $(SYSTEMD_SERVICES_PATH)/otelcol.service
	make otelcol-config
	sudo systemctl daemon-reload

otelcol-logs:
	journalctl --no-pager -fu otelcol

otelcol-stop: 
	-sudo systemctl stop otelcol

otelcol-start: otelcol-config
	sudo systemctl daemon-reload
	sudo systemctl start otelcol

otelcol-restart: otelcol-stop otelcol-start

otelcol-status:
	-sudo systemctl status otelcol

otelcol-remove: otelcol-stop
	sudo rm -Rf $(BIN_FOLDER)/otelcol-contrib $(ETC_FOLDER) $(SYSTEMD_SERVICES_PATH)/otelcol.service 
	sudo systemctl daemon-reload

otelcol-config:
	sudo cp -a config.yaml environment $(ETC_FOLDER)

stack-down:
	docker compose down

stack-ps:
	docker compose ps

stack-up:
	docker compose up -d

stack-reset: stack-down
	@-sudo rm -Rf container
	@-sudo mkdir container

restart: stack-down stack-up

stack-logs:
	docker compose logs -f

stack-remove: stack-reset
	-docker compose rm -vf 
	-docker rmi grafana/otel-lgtm
	-docker rmi quay.io/prometheus/node-exporter

.PHONY: *