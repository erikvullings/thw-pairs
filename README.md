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

## Usage

To run the environment (Apache Kafka, Zookeeper, Schema registry, Kafka UI, TMT and Time service):

```bash
cd docker
docker compose up -d
```

## Exposed services

- [Kafka UI](http://localhost:3600)
- [TMT](http://localhost:3388/tmt)
- [Time service](http://localhost:8100/time)
