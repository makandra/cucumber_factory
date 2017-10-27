cucumber_factory [![Build Status](https://travis-ci.org/makandra/cucumber_factory.svg?branch=master)](https://travis-ci.org/makandra/cucumber_factory)
================

Create ActiveRecord objects without step definitions
----------------------------------------------------

cucumber_factory allows you to create ActiveRecord objects directly from your [Cucumber](http://cukes.info/) features. No step definitions required.


Basic usage
-----------

To create a new record with default attributes:

```cucumber
Given there is a movie
```

To create the record, cucumber_factory will call [`Movie.make`](http://github.com/notahat/machinist), [`Factory.create(:movie)`](http://github.com/thoughtbot/factory_bot), [`Movie.create!`](http://apidock.com/rails/ActiveRecord/Persistence/ClassMethods/create%21) or `Movie.new`, depending on what's available.

To create a new record with attributes set, you can say:

```cucumber
Given there is a movie with the title "Sunshine" and the year "2007"
```

Boolean attributes can be set by appending `which`, `that` or `who` at the end:

```cucumber
Given there is a movie which is awesome
And there is a movie with the name "Sunshine" that is not a comedy
And there is a director who is popular
```

Instead of `and` you can also use `but` and commas to join sentences:

```cucumber
Given there is a movie which is awesome, popular and successful but not science fiction
And there is a director with the income "500000" but with the account balance "-30000"
```


Setting associations
--------------------

You can set `belongs_to` associations by referring to the last created record of as `above`:

```cucumber
Given there is a movie with the title "Before Sunrise"
And there is a movie with the prequel above
```

The example above also shows how to set `has_many` associations - you simply set the `belongs_to` association on the other side.

You can also refer to a previously created record using any string attribute used in its creation:

```cucumber
Given there is a movie with the title "Before Sunrise"
And there is a movie with the title "Limitless"
And there is a movie with the prequel "Before Sunrise"
```

You can also explicitly give a record a name and use it to set a `belongs_to` association below:

```cucumber
Given "Before Sunrise" is a movie
And there is a movie with the title "Limitless"
And there is a movie with the prequel "Before Sunrise"
```

Note that in the example above, "Before Sunrise" is only a name you can use to refer to the record. The name is not actually used for the movie title, or any other attribute value.


Support for popular factory gems
--------------------------------

[Machinist blueprints](http://github.com/notahat/machinist) and [factory_bot factories](http://github.com/thoughtbot/factory_bot) will be used when available.

You can use a [FactoryBot child factory](https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md#inheritance) or [Machinist named blueprint](https://github.com/notahat/machinist/tree/1.0-maintenance#named-blueprints) by putting the variant name in parentheses:

```cucumber
Given there is a movie (comedy) with the title "Groundhog Day"
```

You can use [FactoryBot traits](https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md#traits) by putting the traits in parentheses, as a comma-separated list:

```cucumber
Given there is a movie (moody, dark) with the title "Interstellar"
```


Overriding factory steps
-----------------------

If you want to override a factory step with your own version, just do so:

```ruby
Given /^there is a movie with good actors$/ do
  movie = Movie.make
  movie.actors << Actor.make(:name => 'Clive Owen')
  movie.actors << Actor.make(:name => 'Denzel Washington')
end
```

Custom steps will always be preferred over factory steps. Also Cucumber will not raise a warning about ambiguous steps if the only other matching step is a factory step. Thanks, [cucumber_priority](https://github.com/makandra/cucumber_priority)!


Supported Cucumber versions
----------------------------

cucumber_factory is tested against Cucumber 1.3, 2.4 and 3.0.


Installation
------------

In your `Gemfile` say:

    gem 'cucumber_factory'

Now create a file `features/step_definitions/factory_steps.rb`, which just says

    Cucumber::Factory.add_steps(self)

Now run `bundle install` and restart your server.


Development
-----------

There are tests in `spec`. We only accept PRs with tests. To run tests:

- Install Ruby 2.3.3
- Create a local MySQL database `cucumber_factory_test`
- Copy `spec/support/database.sample.yml` to `spec/support/database.yml` and enter your local credentials for the test databases
- Install development dependencies using `bundle install`
- Run tests using `bundle exec rspec`

We recommend to test large changes against multiple versions of Ruby and multiple dependency sets. Supported combinations are configured in `.travis.yml`. We provide some rake tasks to help with this:

- Install development dependencies using `bundle matrix:install`
- Run tests using `bundle matrix:spec`

Note that we have configured Travis CI to automatically run tests in all supported Ruby versions and dependency sets after each push. We will only merge pull requests after a green Travis build.

If you would like to contribute:

- Fork the repository.
- Push your changes **with passing specs**.
- Send us a pull request.

I'm very eager to keep this gem leightweight and on topic. If you're unsure whether a change would make it into the gem  [talk to me beforehand](mailto:henning.koch@makandra.de).


Credits
-------

Henning Koch from [makandra](https://makandra.com/)
