# Original source: https://coderwall.com/p/aridag


# set the locations that we will look for changed assets to determine whether to precompile
set :assets_dependencies, %w(app/assets lib/assets vendor/assets Gemfile.lock config/routes.rb)
set :force_precompile, false

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
          with rails_env: fetch(:rails_env) do
            begin
              raise PrecompileRequired.new("A forced precompile was triggered") if fetch(:force_precompile)

              # find the most recent release
              latest_release = capture(:ls, '-xr', releases_path).split[1]

              # precompile if this is the first deploy
              raise PrecompileRequired.new('Fresh deployment detected (no previous releases present)') unless latest_release

              latest_release_path = releases_path.join(latest_release)

              # precompile if the previous deploy failed to finish precompiling
              execute(:ls, latest_release_path.join('assets_manifest_backup')) rescue raise PrecompileRequired.new('The previous deployment does not have any assets_manifest_backup this indicates precompile was not successful')

              fetch(:assets_dependencies).each do |dep|
                release = release_path.join(dep)
                latest = latest_release_path.join(dep)

                # skip if both directories/files do not exist
                next if [release, latest].map{|d| test "[ -e #{d} ]"}.uniq == [false]

                # execute raises if there is a diff
                execute(:diff, '-Nqr', release, latest) rescue raise PrecompileRequired.new("Found a difference between the current and the new version of: #{dep}")
              end

              # copy over all of the assets from the last release
              release_asset_path = release_path.join('public', fetch(:assets_prefix))
              # skip if assets directory is symlink
              begin
                execute(:test, '-L', release_asset_path.to_s)
              rescue
                execute(:cp, '-r', latest_release_path.join('public', fetch(:assets_prefix)), release_asset_path.parent)
              end

              # check that the manifest has been created correctly, if not
              # trigger a precompile
              begin
                # Support sprockets 2
                execute(:ls, release_asset_path.join('manifest*'))
              rescue
                begin
                  # Support sprockets 3
                  execute(:ls, release_asset_path.join('.sprockets-manifest*'))
                rescue
                  raise PrecompileRequired.new("No sprockets-manifest found")
                end
              end

              info("Skipping asset precompile, no asset diff found")
            rescue PrecompileRequired => e
              warn(e.message)
              execute(:rake, "assets:precompile")
            end
          end
        end
      end
    end
  end
end
