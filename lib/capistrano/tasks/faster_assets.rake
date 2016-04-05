# Original source: https://coderwall.com/p/aridag


# set the locations that we will look for changed assets to determine whether to precompile
set :assets_dependencies, %w(app/assets lib/assets vendor/assets Gemfile.lock config/routes.rb)

# clear the previous precompile task
Rake::Task["deploy:assets:precompile"].clear_actions
class PrecompileRequired < StandardError;
end

namespace :deploy do
  namespace :assets do
    desc "Precompile assets"
    task :precompile do
      on roles(fetch(:assets_roles)) do
        within release_path do
          # assets_env should be a hash, ie: assets_env: { skip_it: false }
          _assets_env = fetch(:assets_env, {}).merge(rails_env: fetch(:rails_env))
          with _assets_env do
            begin
              # find the most recent release
              latest_release = capture(:ls, '-xr', releases_path).split[1]

              # precompile if this is the first deploy
              raise PrecompileRequired unless latest_release

              latest_release_path = releases_path.join(latest_release)

              # precompile if the previous deploy failed to finish precompiling
              execute(:ls, latest_release_path.join('assets_manifest_backup')) rescue raise(PrecompileRequired)

              fetch(:assets_dependencies).each do |dep|
                release = release_path.join(dep)
                latest = latest_release_path.join(dep)

                # skip if both directories/files do not exist
                next if [release, latest].map{|d| test "[ -e #{d} ]"}.uniq == [false]

                # execute raises if there is a diff
                execute(:diff, '-Nqr', release, latest) rescue raise(PrecompileRequired)
              end

              info("Skipping asset precompile, no asset diff found")

              release_asset_path = release_path.join('public', fetch(:assets_prefix))
              # skip if assets directory is symlink
              begin
                execute(:test, '-L', release_asset_path.to_s)
              rescue
                # copy over all of the assets from the last release
                execute(:cp, '-r', latest_release_path.join('public', fetch(:assets_prefix)), release_asset_path.parent)
              end

              # copy assets if manifest file is not exist (this is first deploy after using symlink)
              execute(:ls, release_asset_path.join('manifest*')) rescue raise(PrecompileRequired)
            rescue PrecompileRequired
              execute(:rake, "assets:precompile")
            end
          end
        end
      end
    end
  end
end
