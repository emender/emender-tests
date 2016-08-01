#Emender Tests

A generic set of tests using Emender.

## Asciidoctor Tests and Docbook Tests

These folders containers a set of generic tests that can be re-used and/or modified for use with asciidoctor or docbook projects who want to integrate emender.

## Test
This folder contains a Dockerfile and supporting scripts to run all the provided tests against a set of example content.
You find more details on installing and configuring docker [here](https://docs.docker.com/engine/installation/).

To run the test:

1. Change to the test directory.
```
$ cd test/
```
1. Run the `build.sh` script to build a new docker image with `emender-tests`:
```
$ ./build.sh
```
1. Edit the `runAllTests.sh` file and replace the value of the `REPO_PATH` variable with the absolute path to the `emender-tests` directory, for example:
```
REPO_PATH="/home/rhoads-zach/emender-tests"
```
1. Run the `runAllTests.sh` scripts to verify that provided Emender tests work as expected:
```
$ ./runAllTests.sh
```
