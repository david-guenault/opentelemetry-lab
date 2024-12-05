# opentelemetry lab

just a simple lab to test opentelemetry collector on your local workstation
This will deploy: 
- a stack with preconfigured open telemetry gateway, grafana, loki, tempo and prometheus
- a local opentelemetry collector to send data in the lgtm stack
- a local prometheus node-exporter which will be scraped by the opentelemetry collector and then send the data to the lgtm stack 
- a local prometheus process-exporter which will be scraped by the opentelemetry collector and then send the data to the lgtm stack 

## requirements

- docker
- make

## configure the opentelemetry collector

edit **cotelcol-contrib/config.yaml** file

## access grafana 

on this url: http://localhost:3000

## usage

Initialize the environment

``` bash
make bootstrap
```

Start the lgtm stack

```bash
make stack-up
```

Start otelcol (this will deploy the config each time)

```bash
make otelcol-start
```

Start node-exporter

```bash
make node-exporter-start
```

Start process-exporter

```bash
make process-exporter-start
```

Clean up everything

```bash
make clean
```

# usefull resources

## opentelemetry service attributes

- about service.*: https://github.com/open-telemetry/opentelemetry-collector-contrib/issues/32484#issuecomment-2329372053

## target info metric in prometheus

- https://grafana.com/docs/grafana-cloud/send-data/otlp/otlp-format-considerations/#resource-attributes-added-to-target_info-metric

## promql query join

```bash
sum by(device,job, instance) (rate(node_disk_io_time_seconds_total[1m])) * on (job, instance) group_left (nodename,sysname) node_uname_info
system_uptime_seconds * on (job,host_name) group_left(os_type) target_info{process_pid=""}
sum by(process_command_line) (rate(process_cpu_time_seconds_total{state="wait"}[1m]) * on (job) group_left(process_command_line) target_info{http_scheme=""} )
sum by (release) (rate(node_cpu_seconds_total{mode="idle"}[5m]) * on (instance) group_left(release) node_uname_info)
```

- https://www.robustperception.io/left-joins-in-promql/
- https://iximiuz.com/en/posts/prometheus-vector-matching/

## cheat sheets

- https://sysdig.com/content/c/pf-infographic-promql-cheatsheet?x=u_WFRi#page=1
- https://pbs.twimg.com/media/EbxvCxHXgAA_D3x?format=jpg&name=4096x4096

