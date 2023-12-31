# frozen_string_literal: true

require_relative "lib/shipyrd/version"

Gem::Specification.new do |spec|
  spec.name = "shipyrd"
  spec.version = Shipyrd::VERSION
  spec.authors = ["Nick Hammond"]
  spec.email = ["nick@shipyrd.io"]

  spec.summary = "The companion gem for Shipyrd, the Kamal deployment dashboard"
  spec.description = "The companion gem for Shipyrd, the Kamal deployment dashboard"
  spec.homepage = "https://shipyrd.io"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/shipyrd/shipyrd-gem"
  spec.metadata["changelog_uri"] = "https://github.com/shipyrd/shipyrd-gem/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "minitest", "~> 5.20"
  spec.add_development_dependency "minitest-reporters", "~> 1.3"
  spec.add_development_dependency "guard", "~> 2.18"
  spec.add_development_dependency "guard-minitest", "~> 2.4"
  spec.add_development_dependency "guard-standardrb", "~> 0.2"
  spec.add_development_dependency "webmock", "~> 3.19"
end
