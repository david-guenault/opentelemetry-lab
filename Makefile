OTEL_VERSION=0.114.0
BIN_FOLDER=/opt/otelcol
ETC_FOLDER=/etc/otelcol
TMP_FOLDER=/tmp/otelcol
SYSTEMD_SERVICES_PATH=/usr/lib/systemd/system/

bootstrap: otelcol-install stack-up otelcol-restart

clean: stack-remove otelcol-remove

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
	sudo systemctl status otelcol

otelcol-remove: otelcol-stop
	sudo rm -Rf $(BIN_FOLDER) $(TMP_FOLDER) $(ETC_FOLDER) $(SYSTEMD_SERVICES_PATH)/otelcol.service 
	sudo systemctl daemon-reload

otelcol-config:
	sudo cp -a config.yaml environment $(ETC_FOLDER)

stack-down:
	docker compose down

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