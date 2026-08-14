require File.expand_path("../lib/#{File.basename(__FILE__, '.gemspec')}/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = 'humanname'
  s.version     = HumanName::VERSION
  s.summary     = "A library for parsing and comparing human names"
  s.description = "A library for parsing and comparing human names. Wraps the Rust crate `human_name`."
  s.authors     = ["David Judd"]
  s.email       = 'david.a.judd@gmail.com'
  s.files       = %w(humanname.gemspec Gemfile LICENSE README.md) + Dir.glob("{lib,spec}/**/*")
  s.homepage    = 'https://github.com/djudd/human-name-rb'
  s.license     = 'Apache-2.0'
  # Binaries for all supported platforms ship inside the gem and are selected
  # at runtime, so publish a single ruby-platform gem rather than per-platform
  # gems whose darwin OS version (e.g. arm64-darwin-24) must match the
  # installing machine's exactly.
  s.platform    = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.7.0'
  s.add_runtime_dependency 'ffi', '~> 1.15.1'
  s.add_development_dependency 'rake', '~> 13.0.6'
  s.add_development_dependency 'rspec', '~> 3.4.0'
  s.add_development_dependency 'rubygems-tasks', '~> 0.2.5'
  s.add_development_dependency 'pry', '~> 0.14.2'
end
