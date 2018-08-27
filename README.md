# Rex Integration Tests

This repository is currently work-in-progress.

We are currently moving the tests from *rex-build* repository to this repository and trying to streamline them so that they can be run with the common perl testing tools.

## Running Tests

You can define some environment variables to control to which system the tests should connect to. In this early stage of development only password authentication is supported.

### Environment variables

* REX_TEST_HOST - The host which should be used to run the tests on
* REX_TEST_USER - The user which should be used to login (for ex.: root or if you want to run sudo tests some other user)
* REX_TEST_PASSWORD - The password to use to connect to the host
* REX_TEST_SUDO - Whether to use sudo or not. If you want to use sudo set it to `1`
* REX_TEST_SUDO_PASSWORD - If rex needs to provide a password for sudo set it with this variable

```
$ export REX_TEST_HOST=some-host-name
$ export REX_TEST_USER=user-to-use
$ export REX_TEST_PASSWORD=password-to-use
$ export REX_TEST_SUDO=1
$ export REX_TEST_SUDO_PASSWORD=sudo-password-to-use
$ prove -r tests
```