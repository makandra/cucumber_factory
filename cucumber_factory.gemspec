# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{cucumber_factory}
  s.version = "1.1.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Henning Koch"]
  s.date = %q{2009-09-07}
  s.description = %q{Cucumber Factory allows you to create ActiveRecord models from your Cucumber features without writing step definitions for each model.}
  s.email = %q{github@makandra.de}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    ".gitignore",
     "MIT-LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "cucumber_factory.gemspec",
     "lib/cucumber_factory.rb",
     "lib/cucumber_factory/factory.rb",
     "spec/app_root/app/controllers/application_controller.rb",
     "spec/app_root/app/models/movie.rb",
     "spec/app_root/app/models/user.rb",
     "spec/app_root/config/boot.rb",
     "spec/app_root/config/database.yml",
     "spec/app_root/config/environment.rb",
     "spec/app_root/config/environments/in_memory.rb",
     "spec/app_root/config/environments/mysql.rb",
     "spec/app_root/config/environments/postgresql.rb",
     "spec/app_root/config/environments/sqlite.rb",
     "spec/app_root/config/environments/sqlite3.rb",
     "spec/app_root/config/routes.rb",
     "spec/app_root/db/migrate/001_create_movies.rb",
     "spec/app_root/db/migrate/002_create_users.rb",
     "spec/app_root/lib/console_with_fixtures.rb",
     "spec/app_root/log/.gitignore",
     "spec/app_root/script/console",
     "spec/factory_spec.rb",
     "spec/rcov.opts",
     "spec/spec.opts",
     "spec/spec_helper.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/makandra/cucumber_factory}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Create records from Cucumber features without writing step definitions.}
  s.test_files = [
    "spec/app_root/app/models/movie.rb",
     "spec/app_root/app/models/user.rb",
     "spec/app_root/app/controllers/application_controller.rb",
     "spec/app_root/config/environment.rb",
     "spec/app_root/config/environments/mysql.rb",
     "spec/app_root/config/environments/postgresql.rb",
     "spec/app_root/config/environments/sqlite3.rb",
     "spec/app_root/config/environments/in_memory.rb",
     "spec/app_root/config/environments/sqlite.rb",
     "spec/app_root/config/boot.rb",
     "spec/app_root/config/routes.rb",
     "spec/app_root/db/migrate/002_create_users.rb",
     "spec/app_root/db/migrate/001_create_movies.rb",
     "spec/app_root/lib/console_with_fixtures.rb",
     "spec/factory_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
