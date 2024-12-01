OTEL_VERSION=0.114.0

bootstrap: otelcol-install stack-up otelcol-restart

clean: stack-remove otelcol-remove

otelcol-download:
	curl -sL https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v$(OTEL_VERSION)/otelcol-contrib_$(OTEL_VERSION)_linux_amd64.tar.gz -o /tmp/otelcol-contrib.tar.gz 

otelcol-install: otelcol-download
	- sudo rm -Rf /tmp/otelcol /opt/otelcol
	sudo mkdir -p /tmp/otelcol /opt/otelcol /etc/otelcol
	sudo tar xvf /tmp/otelcol-contrib.tar.gz -C /tmp/otelcol
	sudo cp -a /tmp/otelcol/otelcol-contrib /opt/otelcol/
	sudo rm -Rf /tmp/otelcol-contrib.tar.gz /tmp/otelcol
	sudo cp otelcol.service /etc/systemd/system/otelcol.service
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
	sudo rm -Rf /opt/otelcol /etc/systemd/system/otelcol.service /etc/otelcol
	sudo systemctl daemon-reload

otelcol-config:
	sudo cp -a otelcol-contrib/config.yaml /etc/otelcol/


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