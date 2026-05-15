# frozen_string_literal: true

require_relative "lib/estimate_count/version"

Gem::Specification.new do |spec|
  spec.name = "estimate_count"
  spec.version = EstimateCount::VERSION
  spec.authors = ["Chris Hasiński"]
  spec.email = ["krzysztof.hasinski@gmail.com"]

  spec.summary = "Adds a method to get an estimate count for an ActiveRecord::Relation"
  spec.description = "Uses EXPLAIN to get an estimate count for an ActiveRecord::Relation"
  spec.homepage = "https://github.com/khasinski/estimate_count"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/khasinski/estimate_count"
  spec.metadata["changelog_uri"] = "https://github.com/khasinski/estimate_count/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git))})
    end
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord"

  # Databases
  spec.add_development_dependency "pg"
  spec.add_development_dependency "mysql2"

  # Paginators (exercised by adapter specs only - never required at runtime)
  spec.add_development_dependency "kaminari", "~> 1.2"
  spec.add_development_dependency "will_paginate", "~> 4.0"
  spec.add_development_dependency "pagy", "~> 6.0"

  # Testing & debugging
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
end
