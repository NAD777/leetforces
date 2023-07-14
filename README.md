# codetest_bot

## Description
This is the implementation of the demo-project for the course of System and Network Administration at Innopolis
University Spring 2023 semester.

**_Disclaimer:_** The codetest_bot team strongly recommends the developer not to use the project as a part of any
high-risc project as it might contain some vulnerabilities that we (the codetest_bot team) did not encounter during
the development phase.

The project is an attempt to implement user submission testing system (e.g. CodeForces, CodinGame, etc.), but as
Telegram bot. The Telegram bot implementation offers neat UI for the end-user with abilities to add problems to the
problem set and test their submissions.

## Reference architecture
```
                                   +-----------------+
                                   |                 |
                                   |   Database      |
                                   |  (PostgreSQL)   |
                                   |                 |
                                   +--------+--------+
                                            |
                                            |
                                            |
          +-----------------+      +--------+--------+      +-----------------+
          |                 |      |                 |      |                 |
          |                 |      |                 |      |                 |
          |  Orchestrator   +------+     Juggler     +------+   Telegram Bot  |
          |                 |      |                 |      |                 |
          |                 |      |                 |      |                 |
          +--------+--------+      +-----------------+      +-----------------+
                   |
       +-----------+-----------+
       |                       |
+------+-------+       +-------+------+
|              |       |              |
| Test runner  |       | Test         |
|              |       |  generator   |
|              |       |              |
+--------------+       +--------------+
```
As depicted above, the project consists of several modules: \
    - Telegram Bot (bot) - the service which provides interaction with user \
    - Juggler (aka backend) - the service which handles requests from bot and forwards them according to their
destination \
    - Orchestrator - the service which manages test generation and user submission execution and checking

The links between services are to show how they communicate within project, in reality, there are several
distinct networks: one for `orchestrator` and its services, one for `orchestrator` and `juggler`, and one for
`juggler` and `bot`. Such complex network partitioning is made with considerations of security and logical
separation.

### Telegram Bot (bot)
Provides neat UI for end-user, as well as communicates with Telegram API for filename resolution, etc. Has several API
routes to gather data from the user, as well as to accept submission testing results from the `Juggler`.

### Juggler (aka backend)
Provides extensive API for task storing and retrieval, communicating with the database (postgreSQL) storage and
forwarding user submissions to the `Orchestrator` service.

### Orchestrator  (not k8s, haha)
Has 2 container dependencies on `Test runner` and `Generator` which are responsible for running user submissions and
generating tests correspondigly. `Orchestrator` itself has only 1 route for accepting submissions.

## Technology stack
Docker, docker-compose, github actions CI/CD, Prometheus, Grafana, postgreSQL, Java Spring boot, Python, XMLRPC.

## Deployment
We have [deployed](https://github.com/users/NAD777/packages?repo_name=codetest_bot) containers to the Github Container
registry using Github Actions.

## Installation
- Install docker-compose and docker packages according to your operating systems guidelines first.
- Acquire the Telegram API token for your bot
- Clone the project github repository
- Paste your token to the newly created `./bot/env.properties` file with the key `BOT_TOKEN`
```bash
cd codetest_bot
touch env.properties
```
Note: the example of `env.properties` file configuration:
```yaml
# env.properties
BOT_TOKEN=<insert_your_token_here>
```

## Usage
To build & run the project run in the project root directory
```bash
docker-compose up
```
And then you can access the bot via Telegram

## Metrics
To access metrics, go to http://localhost:3000/ and log in to Grafana with credentials according to
`docker-compose.yaml`, and then add the Prometheus data source (Prometheus service is configured to run at port 9090)
and import the dashboard (dashboard configuration file is located in `/configs/dashboard.json`).

## License
Licensed under MIT open license.
The codetest_bot team @ 2023.
