# SROC Charging Module API Performance tests

[![Licence](https://img.shields.io/badge/Licence-OGLv3-blue.svg)](http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3)

The [Charging Module API](https://github.com/defra/sroc-charging-module-api) provides an interface for calculating charges, creating and queuing transactions, and generating transaction and customer files used to produce Environment Agency invoices.

This project contains [JMeter](https://jmeter.apache.org/) performance tests for the service.

## Pre-requisites

You'll need an instance of JMeter installed and running. You'll also need to know the path to its `bin/jmeter.sh` script (look in the folder you extracted JMeter to).

## Installation

First clone the repository and then drop into your new local repo

```bash
git clone https://github.com/DEFRA/sroc-cha-performance-tests.git && cd sroc-cha-performance-tests
```

## Configuration

> Important! Do not add environment files to source control

We have 6 environments where the CHA could be running; local, development, test, integration, pre-production, and production.

For each environment you wish to test you'll need to create an 'environment file' in  `environments/`. An [example](/environments/example.env) with dummy data is provided as a reference.

For example, if you wanted to start testing the **development** environment the steps would be

- duplicate [.example.env](/environments/example.env)
- rename to something meaningful; `.dev.env`
- update the `CMS_JMETER_PATH` attribute to point to your JMeter install and its `jmeter.sh` file
- update the rest of the values for each of the properties (`CMS_TOKEN_URL`, `CMS_SYSTEM_USER`, `CMS_BASE_URL` etc) to match the environment

You'll need to contact an existing [team member](https://github.com/DEFRA/sroc-service-team) to obtain the proper credentials.

Git is setup to ignore everything bar the example environment file. Even so, double check your environment file has not been comitted before pushing it to GitHub.

## Execution

Test plans can be run in either [GUI](https://jmeter.apache.org/usermanual/get-started.html#running) or [CLI](https://jmeter.apache.org/usermanual/get-started.html#non_gui) mode.

Use GUI mode to create, edit and and debug tests. It's [recommended](https://jmeter.apache.org/usermanual/best-practices.html#lean_mean) to use CLI mode when running the tests for real.

### GUI Mode

From the root of the project in a terminal run

```bash
./gui.sh test tests.jmx
```

The first arg is required and is the name of the environment to use and should match the name of a config file in `environments/`. For example

```bash
./gui.sh dev tests.jmx # environments/.dev.env
./gui.sh local tests.jmx # environments/.local.env
./gui.sh test tests.jmx # environments/.test.env
```

The second arg is the JMeter `.jmx` file to load. This is not required and if left blank JMeter will start in its default state ready to create a new `.jmx` file. Everything from the environment config will still be available though, loaded as environment variables in the current session.

### CLI mode

From the root of the project in a terminal run

```bash
./gui.sh test tests.jmx
```

The first arg is required and is the name of the environment to use and should match the name of a config file in `environments/`. For example

```bash
./gui.sh dev tests.jmx # environments/.dev.env
./gui.sh local tests.jmx # environments/.local.env
./gui.sh test tests.jmx # environments/.test.env
```

The second arg is the JMeter `.jmx` file to load. This is not required and if left the script will default to using `tests.jmx`.

When run in this way no GUI will appear and test output will be written to a [.jtl file](https://jmeter.apache.org/usermanual/listeners.html#batch).

## Enabling/Disabling tests

JMeter stores test plans in `.jmx` files. Our main test plan `tests.jmx` features multiple scenarios to be tested. These are held under [Thread Groups](https://jmeter.apache.org/usermanual/test_plan.html#thread_group).

From the GUI you can disable and enable these thread groups (scenarios). But this information is saved to the jmx file. This can be a problem when switching between GUI and CLI mode. Instead we use environment variables to control which groups will be run.

```bash
CMS_STANDARD_JOURNEY_THREAD_COUNT=1
CMS_DELETE_LICENCE_JOURNEY_THREAD_COUNT=0
CMS_DELETE_JOURNEY_THREAD_COUNT=0
CMS_REBILLING_JOURNEY_THREAD_COUNT=0
```

> See /environments/.example.env for a full example

Any thread group with a count of 0 _will not be run_.

## Docker

[Docker](https://www.docker.com/) is our chosen solution for deploying and managing our apps in production. We also use it for local development and where possible to simplify the use of our support projects. **SROC Charging Module API Performance tests** supports using Docker to run the tests. This avoids needing to setup a JMeter environment manually. See [the README in Docker/](/docker/README.md) for more details.

## Contributing to this project

If you have an idea you'd like to contribute please log an issue.

All contributions should be submitted via a pull request.

## Licence

THIS INFORMATION IS LICENSED UNDER THE CONDITIONS OF THE OPEN GOVERNMENT LICENCE found at:

<http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3>

The following attribution statement MUST be cited in your products and applications when using this information.

> Contains public sector information licensed under the Open Government licence v3

### About the licence

The Open Government Licence (OGL) was developed by the Controller of Her Majesty's Stationery Office (HMSO) to enable information providers in the public sector to license the use and re-use of their information under a common open licence.

It is designed to encourage use and re-use of information freely and flexibly, with only a few conditions.
