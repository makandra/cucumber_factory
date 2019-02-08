# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).


## Unreleased

### Breaking changes

- Moved gem's code from `Cucumber` module into `CucumberFactory` module.
- Instead of calling `Cucumber::Factory.add_steps(self)`, `require 'cucumber_factory/add_steps'` instead.


## 1.14.2 - 2018-10-31

### Compatible changes

- Replace deprecated `Fixnum` with `Integer`


## 1.14.1 - 2018-10-26

### Compatible changes

- Allow to refer to previously set foreign keys


## 1.14.0 - 2018-10-26

### Compatible changes

- Allow to set numbers without quotes
- Support array fields out of the box
- Allow to set has_many associations with square bracket notation


## 1.13.0 - 2018-04-26

### Compatible changes

- Support multi line attribute assignment


## 1.12.0 - 2018-04-26

### Compatible changes

- Support for Cucumber 3.0 and 3.1


## Previous releases

- See [GitHub](https://github.com/makandra/cucumber_factory/commits/master)