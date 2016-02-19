[![Build Status](https://travis-ci.org/zooniverse/nero.svg)](https://travis-ci.org/zooniverse/nero)

# Nero

This runs as a service listening to the Kafka event stream coming out of Panoptes,
determines when a subject needs to retired, in which case it calls back to Panoptes' API to mark it as retired.

### Development

The easiest path to running Nero in development mode is to run it using Docker. Assuming you've installed and set up Docker, you'll need to configure some AWS credentials. Copy `.env.template` to `.env`, and edit it to add your AWS credentials. After that, you can run:

```
$ docker-compose up
```

Once this has finished starting up services (and Postgresql is running) you need to create the databases for development and test work. Open another terminal tab:

```
$ docker exec -it nero_postgres_1 createdb --username=nero nero_development
$ docker exec -it nero_postgres_1 createdb --username=nero nero_test
```

Then try running the test suite:

```
bin/rspec
```
