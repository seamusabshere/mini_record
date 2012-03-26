# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mini_record/version"

Gem::Specification.new do |s|
  s.name        = "mini_record-compat"
  s.version     = MiniRecord::VERSION
  s.authors     = ["Davide D'Agostino", "Seamus Abshere"]
  s.email       = ["d.dagostino@lipsiasoft.com", "seamus@abshere.net"]
  s.homepage    = "https://github.com/seamusabshere/mini_record"
  spec = %q{DEPRECATED. Use active_record_inline_schema or original mini_record gem instead.}
  s.summary     = spec
  s.description = spec

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
