cucumber_factory [![Tests](https://github.com/makandra/cucumber_factory/workflows/Tests/badge.svg)](https://github.com/makandra/cucumber_factory/actions?query=branch:master)
================

Create ActiveRecord objects without step definitions
----------------------------------------------------

cucumber_factory allows you to create ActiveRecord objects directly from your [Cucumber](http://cukes.info/) features. No step definitions required.


Basic usage
-----------

To create a new record with default attributes, begin any step with `Given there is`:

```cucumber
Given there is a movie
```

To create the record, cucumber_factory will call [`FactoryBot.create(:movie)`](http://github.com/thoughtbot/factory_bot), `FactoryGirl.create(:movie)`, [`Movie.make`](http://github.com/notahat/machinist), [`Movie.create!`](http://apidock.com/rails/ActiveRecord/Persistence/ClassMethods/create%21) or `Movie.new`, depending on what's available.

Quoted strings and numbers denote attribute values:

```cucumber
Given there is a movie with the title "Sunshine" and the year 2007
```

To update an existing record, specify the record and the changes:
```
Given the movie above has the title "Sunset" and the year 2008
Given the movie "Sunrise" has the year 2009
```
A record can be specified by the `above` keyword, which uses the last created record of this class, or by any string that was used during its creation.

Setting boolean attributes
--------------------------

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

To update boolean attributes use the keyword `is`:

```cucumber
Given the movie above is awesome but not popular
Given the movie above has the year 1979 but is not science fiction
```


Setting many attributes with a table
------------------------------------

If you have many attribute assignments you can use doc string or data table:

```cucumber
Given there is a movie with these attributes:
  """
  name: Sunshine
  comedy: false
  """
```

```cucumber
Given there is a movie with these attributes:
  | name   | Sunshine |
  | comedy | false    |
```

```cucumber
Given the movie above has these attributes:
  """
  name: Sunshine
  comedy: false
  """
```

Setting associations
--------------------

You can set `belongs_to` and `transient` associations by referring to the last created record of as `above`:

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

It is not possible to define associations in doc string or data table, but you can combine them in one
step:

```cucumber
Given there is a movie with the prequel above and these attributes:
  """
  name: Sunshine
  comedy: false
  """
```

```cucumber
Given there is a movie with the prequel above and these attributes:
  | name   | Sunshine |
  | comedy | false    |
```


Setting array attributes or has_many associations
-------------------------------------------------

You can set `has_many` associations by referring to multiple named records in square brackets:

```cucumber
Given there is a movie with the title "Sunshine"
And there is a movie with the title "Limitless"
And there is a movie with the title "Salt"
And there is a user with the favorite movies ["Sunshine", "Limitless" and "Salt"]
```

When using [PostgreSQL array columns](https://www.postgresql.org/docs/9.1/static/arrays.html), you can set an array attribute to a value with square brackets:

```cucumber
Given there is a movie with the tags ["comedy", "drama" and "action"]
```


Setting file attributes
-----------------------

You can set an attribute to a file object with the following syntax:

```cucumber
Given there is a movie with the image file:'path/to/image.jpg'
```

All paths are relative to the project root, absolute paths are not supported. Please note that file attributes must follow the syntax `file:"PATH"`, both single and double quotes are allowed.

Using named factories and traits
--------------------------------

You can use a [FactoryBot child factory](https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md#inheritance) or [Machinist named blueprint](https://github.com/notahat/machinist/tree/1.0-maintenance#named-blueprints) by putting the variant name in parentheses:

```cucumber
Given there is a movie (comedy) with the title "Groundhog Day"
```

You can use [FactoryBot traits](https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md#traits) by putting the traits in parentheses, as a comma-separated list:

```cucumber
Given there is a movie (moody, dark) with the title "Interstellar"
```




Overriding factory steps
------------------------

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

cucumber_factory is tested against Cucumber 1.3, 2.4, 3.0 and 3.1.


Installation
------------

In your `Gemfile` say:

    gem 'cucumber_factory'

Now create a file `features/step_definitions/factory_steps.rb`, which just says

    require 'cucumber_factory/add_steps'

Now run `bundle install` and restart your server.


Development
-----------

There are tests in `spec`. We only accept PRs with tests. To run tests:

- Install the Ruby version stated in `.ruby-version`
- Create a local PostgreSQL database:
```
$ sudo -u postgres psql -c 'create database cucumber_factory_test;'
```

- Copy `spec/support/database.sample.yml` to `spec/support/database.yml` and enter your local credentials for the test databases
- Install development dependencies using `bundle install`
- Run tests with the default symlinked Gemfile using `bundle exec rspec` or explicit with `BUNDLE_GEMFILE=Gemfile.cucumber-x.x bundle exec rspec spec`

We recommend to test large changes against multiple versions of Ruby and multiple dependency sets. Supported combinations are configured in .github/workflows/test.yml. We provide some rake tasks to help with this:

For each ruby version do (you need to change it manually):
- Install development dependencies using `rake matrix:install`
- Run tests using `rake matrix:spec`

Note that we have configured GitHub Actions to automatically run tests in all supported Ruby versions and dependency sets after each push. We will only merge pull requests after a green workflow build.

If you would like to contribute:

- Fork the repository.
- Push your changes **with passing specs**.
- Send us a pull request.

I'm very eager to keep this gem leightweight and on topic. If you're unsure whether a change would make it into the gem  [talk to me beforehand](mailto:henning.koch@makandra.de).


Credits
-------

Henning Koch from [makandra](https://makandra.com/)
