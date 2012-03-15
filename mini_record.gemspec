# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mini_record/version"

Gem::Specification.new do |s|
  s.name        = "mini_record-compat"
  s.version     = MiniRecord::VERSION
  s.authors     = ["Davide D'Agostino", "Seamus Abshere"]
  s.email       = ["d.dagostino@lipsiasoft.com", "seamus@abshere.net"]
  s.homepage    = "https://github.com/seamusabshere/mini_record"
  s.summary     = %q{Alternate gem published by Seamus Abshere for ActiveRecord 3.0 support. MiniRecord is a micro gem that allow you to write schema inside your model as you can do in DataMapper.}
  s.description = %q{
    With it you can add the ability to create columns outside the default schema, directly
    in your model in a similar way that you just know in others projects
    like  DataMapper or  MongoMapper.
  }.gsub(/^ {4}/, '')

  # s.rubyforge_project = "mini_record"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "activerecord", ">=3"
  # s.add_runtime_dependency "activerecord", "3.0.12"
  # s.add_runtime_dependency "activerecord", "3.1.3"
  # s.add_runtime_dependency "activerecord", "3.2.2"

  # dev dependencies appear to be in the Gemfile
end
