# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).


## Unreleased

### Breaking changes

-

### Compatible changes

-

## 2.0.0 - 2020-02-10

### Breaking changes

- CucumberFactory now raises an `ArgumentError` if some parts of a matched step were not used. For example, while this step was accepted in recent versions, it will now complain with the message `Unable to parse attributes " and the ".`:
  ```
  Given there is a user with the attribute 'foo' and the
  ```


### Compatible changes

- Single quoted attribute values and model names are now supported. Example:

  ```
  Given 'jack' is a user with the first name 'Jack'
  ```

## 1.15.1 - 2019-05-30

### Compatible changes

- Fix: Allow to use array assignments within a doc string or table assignment

  Example:

  ```
  Given there is a post with these attributes:
    |tags| ["urgent", "vip"] |
  ```

## 1.15.0 - 2019-02-08

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
