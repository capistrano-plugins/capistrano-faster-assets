module Capistrano
  module FasterAssets
    DEPENDENCIES = %w(app/assets lib/assets vendor/assets Gemfile.lock config/routes.rb)
  end
end

if Gem::Specification.find_by_name('capistrano').version >= Gem::Version.new('3.0.0')
  load File.expand_path("../tasks/faster_assets.rake", __FILE__)
else
  require_relative 'tasks/faster_assets'
end
