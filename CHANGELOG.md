# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).


## Unreleased

### Breaking changes

-

### Compatible changes

-

## 2.3.1 - 2020-10-01

### Compatible changes

- Lowered the priority of all steps in this gem to avoid issues with overlapping steps.

## 2.3.0 - 2020-09-24

### Compatible changes

- Added a step to add file objects to a model:
  ```cucumber
  Given there is a user with the avatar file:"path/to/avatar.jpg"
  ```
  Both single and double quotes are supported.

## 2.2.0 - 2020-09-23

### Compatible changes

- A step was added that allows modifying existing records with a similar syntax to creating new records:
  ```cucumber
  (Given "Bob" is a user)
    And "Bob" has the email "foo@bar.com" and is subscribed
  ```
  - This step will also work with doc strings or tables:
  ```cucumber
  (Given "Bob" is a user)
    And the user above has these attributes:
    | name  | Bob         |
    | email | foo@bar.com | 
  ```

## 2.1.1 - 2020-05-20

### Compatible changes

- Cucumber 2.1.0 introduced some regressions which are being addressed with this patch:
    - Fix the assignment of polymorphic associations.
    - Restore the support for inherited traits within nested factories.

## 2.1.0 - 2020-03-09

### Compatible changes

- Allow associations to be set for [transient attributes](https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md#transient-attributes) if they are named after the model. For example, when there is a `Role` model and the`user` factory has a transient attribute `role`, the following steps are now valid:
  ```
  Given there is a role
    And there is a user with the role above
  ```

## 2.0.2 - 2020-03-26

### Compatible changes

- Removed development and test support for Ruby 1.8. Closes #32.

## 2.0.1 - 2020-02-27

### Compatible changes

- Fix a bug that prevented created records to be named when using multiline attribute assignments
  ```
  Given "Bob" is a user with these attributes:
    | email | foo@bar.com     |
  ```

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
