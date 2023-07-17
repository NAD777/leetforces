# leetforces

## Description
**_Disclaimer:_** The leetforces team strongly recommends the developers not to
use the project as a part of any high-risk project as it might contain some
vulnerabilities that we (the leetforces team) did not encounter during
the development and testing phase.

This project started as a course project for the System and Network
Administration course at Innopolis University Spring 2023 semester, and
then was redesigned and greatly improved for the Capstone Project course at
Innopolis University Summer 2023 semester.

The project is an attempt to implement the service for end-user submission
checking for the academia, i.e. for universities, schools, etc. The service
provides modularity and extensibility by utilizing microservice architecture.

**NB** In the description below we distinguish 2 definitions: user and end-user.
User stands for the member(s) of the technical support team, while end-users
may be students of some educational organization.

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
  |  Orchestrator   +------+     Juggler     +------+    Frontend     |
  |                 |      |                 |      |                 |
  |                 |      |                 |      |                 |
  +--------+--------+      +-----------------+      +-----------------+
           |
           |
           |
 +---------+---------+
 |                   |
 |   Test runner /   |
 |   Test generator  |
 |                   |
 +-------------------+
```
As depicted above, the project consists of several modules: \
    - Frontend - the service which provides interaction with user \
    - Juggler (aka backend) - the service which handles requests from frontend
    and forwards them according to their destination \
    - Orchestrator - the service which manages test generation and user
    submission execution and checking

The links between services are to show how they communicate within project, in
reality, there are several distinct networks: one for `orchestrator` and its
services, one for `orchestrator` and `juggler`, and one for `juggler` and
`frontend`. Such complex network partitioning is made with considerations of
security and logical separation.

### Frontend
Provides neat UI for end-user by utilizing the capabilities of the Flutter
framework, communicates with `juggler` to retrieve and send user information.

### Juggler (aka backend)
Provides extensive API for task storing and retrieval, communicating with the
database (PostgreSQL) storage and forwarding user submissions to the
`Orchestrator` service.

### Orchestrator (not k8s, haha)
Provides 1 API route for user submissions, depends itself on DockerAPI for
communicating with Docker daemon to start worker containers. The additional
user submission container isolation is made for the security and modularity
reasons.

## Technology stack
Docker, docker-compose, GitHub actions CI/CD, PostgreSQL, Dart, Flutter, 
Python, XMLRPC, nginx.

## Deployment
We have
[deployed](https://github.com/users/NAD777/packages?repo_name=codetest_bot)
containers to the GitHub Container registry using GitHub Actions for the sake
of user convenience.

## Installation
- Install docker-compose and docker packages according to your operating
systems guidelines first.
- Clone the project GitHub repository

## Usage
To build & run the project run in the project root directory
```bash
docker-compose up
```
And then you can access the site on the `http://localhost:8080/`

## License
Licensed under MIT open license.
The leetforces team @ 2023.
