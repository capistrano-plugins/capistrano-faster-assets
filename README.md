# Capistrano::FasterAssets

This gem speeds up asset compilation by skipping the assets:precompile task if none of the assets were changed
since last release.

Works *only* with Capistrano 3+.

### Installation

Add this to `Gemfile`:

    group :development do
      gem 'capistrano', '~> 3.1'
      gem 'capistrano-rails', '~> 1.1'
      gem 'capistrano-faster-assets', '~> 1.0'
    end

And then:

    $ bundle install

### Setup and usage

Add this line to `Capfile`, after `require 'capistrano/rails/assets'`

    require 'capistrano/faster_assets'
    
Configure your asset depedencies in deploy.rb if you need to check additional paths (e.g. if you have some assets in YOUR_APP/engines/YOUR_ENGINE/app/assets). Default paths are:

    set :assets_dependencies, %w(app/assets lib/assets vendor/assets Gemfile.lock config/routes.rb)
    
### Warning

Please keep in mind, that if you use ERB in your assets, you might run into cases where Capistrano won't recompile assets when needed. For instance, let's say you have a CoffeeScript file like this:

```coffee
text = <%= helper.get_text %>
```

The assets might not get recompiled, even if they have to, as this gem only checks if the asset file has changed (which is probably the only safe/fast way to do this).

### More Capistrano automation?

If you'd like to streamline your Capistrano deploys, you might want to check
these zero-configuration, plug-n-play plugins:

- [capistrano-unicorn-nginx](https://github.com/bruno-/capistrano-unicorn-nginx)<br/>
no-configuration unicorn and nginx setup with sensible defaults
- [capistrano-postgresql](https://github.com/bruno-/capistrano-postgresql)<br/>
plugin that automates postgresql configuration and setup
- [capistrano-rbenv-install](https://github.com/bruno-/capistrano-rbenv-install)<br/>
would you like Capistrano to install rubies for you?
- [capistrano-safe-deploy-to](https://github.com/bruno-/capistrano-safe-deploy-to)<br/>
if you're annoyed that Capistrano does **not** create a deployment path for the
app on the server (default `/var/www/myapp`), this is what you need!

### Bug reports and pull requests

...are very welcome!

### Thanks

[@athal7](https://github.com/athal7) - for the original idea and implementation. See https://coderwall.com/p/aridag
for more details
