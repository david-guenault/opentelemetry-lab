# opentelemetry lab

just a simple lab to test opentelemetry collector on your local workstation
This will deploy a stack with preconfigured open telemetry gateway, grafana, loki, tempo and prometheus
This will deploy also a local opentelemetry collector to send data in the lgtm stack

## requirements

- docker
- make

## configure the opentelemetry collector

edit **cotelcol-contrib/config.yaml** file


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

Clean up everything

```bash
make clean
```
