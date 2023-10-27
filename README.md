# THW-PAIRS

A crisis management (CM) testbed for training people when responsding to (simulated) incidents, and for testing new CM applications. 
![image](https://github.com/erikvullings/thw-pairs/assets/3140667/f2512202-f13b-4d76-b463-2cbc6b57ac5a)

It consists of:

- A scenario editor, for creating CM incidents and executing them during a training or trial. For example, you can send prepared emails or maps.
- A time service, so you can control the time that the simulation takes place. It also acts as a billboard for displaying messages to participants, or for displaying videos (e.g. a news flash)
- An email service, so you can send email messages to participants: the service is not connected to any real email service, i.e. none of the created messages is sent outside the training environment.
- An map tiling service using Open Street Map (OSM) data, so you can use the maps offline.
- A map service (TODO) to show the sent maps

The whole setup can be run locally on a single PC using Docker, and is exposed on [http://localhost](http://localhost). Participants will need access to this PC in order to use the email or map service, e.g. via a local network or a tunnel.

## Prerequisites

A working version of Docker, including Docker compose.

```bash
cd docker
docker compose pull
cp .env_example .env
```

```dos
cd docker
docker compose pull
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

And access the services via your browser at [http://localhost](http://localhost).

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
