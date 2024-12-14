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

A makefile is available for the most common usage. The following table show the most commonly used one. 
you can use the make command followed by the target name. Here is an example: 

```bash
make bootstrap
```

|make argument|description|target arguments|
|---|---|---|
|bootstrap|first run. initialize the lgtm stack and install all collectors ||
|clean|stop and remove the lgtm stack and all collectors||
|status-all|display the status of the lgtm stack and each collector||
|stop-all|stop the collectors and then stop the lgtm stack||
|start-all|start the lgtm stack then the collectors||
|update-collectors|stop the collectors, redeploy configuration then start the collectors||
|restart-collectors|restart collectorsonly restart collectors||

If you want to deploy collectors on others computers / virtual machines, you just have to clone this repo on the target computer and then issue the following command: 

```bash
make collectors-install update-collectors
```

Do not forget to customize the environment file before !

## Customize preloaded dashboards

The provisioning file is located in ```provisioning_dashboards``` folder. If you want to add more dashboards, edit the configuration file for dashboard provisioning then put the dashboards json files in the ```dashboards folder```

## Customize service labels 

You can customize service labels **before starting the collectors**. In order to do so, ediy the environment file and modify the values in the **OTEL_RESOURCE_ATTRIBUTES** environment variable. Please do not forget to modify the **ENDPOINT**  variable to match the ip address of the computer where the stack is deployed. 

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

