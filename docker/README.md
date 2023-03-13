# Introduction

This folder contains a single `docker-compose` files, allowing you to run an OSINT track either:

- Locally: make sure to edit the `.env` file (see `.env_example`) first.
- Run `./start.sh`. Stop with `./stop.sh` or `./down.sh`.

## Environment variables

### `HOST`

Please copy `.env_example` to `.env` and set the HOST IP address or localhost appropriately. The docker compose will read from this file and substitute the variables in your script.

### `BROKER` and `SCHEMA` registry

Set the location of the Kafka broker and schema registry.

```bash
# When Kafka is part of the docker compose
BROKER=broker:29092
SCHEMA=http://schema-registry:8081
```

```bash
# When Kafka is externally hosted
BROKER=134.221.20.203:3501
SCHEMA=http://134.221.20.203:3502
```

### `COMPOSE_PROFILES`

It also includes [profiles](https://docs.docker.com/compose/profiles/) to selectively run some services. E.g. the profile

- `server`: is for starting Telegram on the server
- `lt` for starting the Lithuanian services
- `translate` for starting the Translation services and LibreTranslate.
- `jupyter` for starting the Jupyter notebook: note that you should not expose this application to the outside world, as it will be exploited.
- `pdf` for starting the PDF service

Multiple profiles can be specified by passing multiple --profile flags or a comma-separated list for the `COMPOSE_PROFILES` environment variable. E.g. to start the system on the server, set the `.env` to contain

```bash
COMPOSE_PROFILES=server,lt,translate
```

## Backups

The Weaviate database can be backed up to the [file system](https://weaviate.io/developers/weaviate/current/configuration/backups.html#filesystem) by setting the appropriate environment properties in the docker compose file. In particular, you need to set the `BACKUP_FILESYSTEM_PATH: /tmp/weaviate` in the Weaviate environment properties, and also make sure that this folder is mapped in your volume settings to a local folder (otherwise the backup is stored inside the container). For example, use the following volume settings: `- /tmp/weaviate:/tmp/weaviate` in order to create a backup in the `/tmp/weaviate` folder.

You can trigger a backup using `curl`, e.g.

```bash
curl -X POST -H "Content-Type: application/json" -d '{ "id": "icemYYYYMMDDHHmmss" }' http://localhost:8888/v1/backups/filesystem

# Check the status
curl --location --request GET 'http://localhost:8888/v1/backups/filesystem/icemYYYYMMDDHHmmss'

# Restore a backup
curl --location --request POST 'http://localhost:8888/v1/backups/filesystem/icemYYYYMMDDHHmmss/restore' --header 'Content-Type: application/json' --data-raw '{}'

# Check the size
du -sh /tmp/weaviate/icemYYYYMMDDHHmmss/

# And tar/compress it
tar -zcvf icem20221110110000.tar.gz /tmp/weaviate/icemYYYYMMDDHHmmss/
```
