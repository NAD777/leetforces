# codetest_bot

## Description
This is the implementation of the demo-project for the course of System and Network Administration at Innopolis 
University Spring 2023 semester.

**_Disclaimer:_** The codetest_bot team strongly recommends the developer not to use the project as a part of any 
high-risc project as it might contain some vulnerabilities that we (the codetest_bot) did not encounter during 
the development phase.

The project is an attempt to implement user submission testing system (e.g. CodeForces, CodinGame, etc.), but as 
Telegram bot. The Telegram bot implementation offers neat UI for the end-user with abilities to add problems to the 
problem set and test their submissions.

## Reference architecture
```
                                   +-----------------+
                                   |                 |
                                   |   Database      |
                                   |  (PostgresSQL)  |
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
As depicted above, the project consists of several modules:
    - Telegram Bot (bot) - the service which provides interaction with user
    - Juggler (aka backend) - the service which handles requests from bot and forwards them according to their 
destination
    - Orchestrator - the service which manages test generation and user submission execution and checking

## Technology stack
Docker, docker-compose, github actions CI/CD, Prometheus, Grafana, postgreSQL, Java Spring boot, Python

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
