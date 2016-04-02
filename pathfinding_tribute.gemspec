# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pathfinding_tribute/version'

Gem::Specification.new do |spec|
  spec.name          = "pathfinding_tribute"
  spec.version       = PathfindingTribute::VERSION
  spec.authors       = ["Adam McCann"]
  spec.email         = ["adam.jt.mccann@gmail.com"]

  spec.summary       = %q{Implementation of the Red Blob Games tutorial, 'Pathfinding for Tower Defense'}
  spec.description   = %q{Implementation of the Red Blob Games tutorial, 'Pathfinding for Tower Defense'}
  spec.homepage      = "https://github.com/AJTMCCANN/pathfinding_tribute"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  # list all files under git using '\0' as the line delimiter, create
  # an array out of the list, and then exclude any array elements
  # referencing files in the 'test', 'spec', or 'features' subdirectories
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler" , "~> 1.11"
  spec.add_development_dependency "rake"    , "~> 10.0"
  spec.add_development_dependency "rspec"   , "~> 3.0"
  spec.add_runtime_dependency     "gosu"    , "~> 0.10"
  spec.add_runtime_dependency     "minigl"  , "~> 2.0"
end
