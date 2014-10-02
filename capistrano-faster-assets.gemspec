# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/faster_assets/version'

Gem::Specification.new do |gem|
  gem.name          = "capistrano-faster-assets"
  gem.version       = Capistrano::FasterAssets::VERSION
  gem.authors       = ["Andrew Thal", "Ruben Stranders"]
  gem.email         = ["athal7@me.com", "r.stranders@gmail.com"]
  gem.description   = <<-EOF.gsub(/^\s+/, '')
    Speeds up asset compilation by skipping the assets:precompile task if none of the assets were changed since last release.

    Works *only* with Capistrano 3+.

    Based on https://coderwall.com/p/aridag
  EOF
  gem.summary       = "Speeds up asset compilation if none of the assets were changed since last release."
  gem.homepage      = "https://github.com/capistrano-plugins/capistrano-faster-assets"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "capistrano", ">= 3.1"
  gem.add_development_dependency "rake"
end
