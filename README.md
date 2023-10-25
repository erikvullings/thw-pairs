# THW-PAIRS

TMT infrastructure example.

## Prerequisites

A working version of Docker, including Docker compose.

```bash
cd docker
cp .env_example .env
```

```dos
cd docker
copy .env_example .env
```

## Prepare

See the `prepare` folder to prepare your maps. It is based on the setup as described in [gis-to-go](https://github.com/erikvullings/gis-to-go). Note that you only have the prepare the volumes. You do not need to run them, as they will be started here. 

Merge the final `./prepare/.env` file with the current `./env` file.

## Usage

To run the environment:

```bash
cd docker
docker compose up -d
```

## Exposed UI services

- [TMT](http://localhost/tmt)
- [Time service](http://localhost/time)
- [Mail service](http://localhost/mail), based on this [email service](https://github.com/DRIVER-EU/email-gateway).
- [Redpanda console](http://localhost/console)

## Exposed services

- [Kafka broker](http://localhost:3501)
- [Schema registry](http://localhost:3502)
- [MapTiler](http://localhost/maptiler)

### APIs

- [Kafka REST API](http://localhost:3500/topics)
- [Schema registry API](http://localhost:3502/subjects)
- [Nominatim API](http://localhost/nominatim)
- [Valhalla API](http://localhost/valhalla)