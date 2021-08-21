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

The project is currently setup to run JMeter in GUI mode. Tests can be created, edited and run from the GUI though it's recommended to use [CLI mode](https://jmeter.apache.org/usermanual/best-practices.html#lean_mean) when running the tests for real.

From the root of the project in a terminal run

```bash
./run.sh test tests.jmx
```

The first arg is required and is the name of the environment to use and should match the name of a config file in `environments/`. For example

```bash
./run.sh dev tests.jmx # environments/.dev.env
./run.sh local tests.jmx # environments/.local.env
./run.sh test tests.jmx # environments/.test.env
```

The second arg is the JMeter `.jmx` file to load. This is not required and if left blank JMeter will start in its default state ready to create a new `.jmx` file. Everything from the environment config will still be available though, loaded as environment variables in the current session.

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
