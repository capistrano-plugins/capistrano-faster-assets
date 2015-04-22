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
          with rails_env: fetch(:rails_env) do
            begin
	      # find the most recent release
              latest_release = capture(:ls, '-xr', releases_path).split[1]

              # precompile if this is the first deploy
              raise PrecompileRequired unless latest_release

              latest_release_path = releases_path.join(latest_release)

              # precompile if the previous deploy failed to finish precompiling
              execute(:ls, latest_release_path.join('assets_manifest_backup')) rescue raise(PrecompileRequired)

              # count the number of commits involving the assets dependencies between HEAD~1 and HEAD
              # the result will be either zero or one
              # but we have to play a trick to get the 0 returned as it's intpreted by the capture command
              previous_rev = capture("tail -1 #{revision_log}")
              previous_ref = previous_rev.match(/\(at (\w{7})\)/)[1]
              current_ref = revision_log_message.match(/\(at (\w{7})\)/)[1]
              result = capture("cd #{repo_path} && git log #{previous_ref}..#{current_ref} -- #{fetch(:assets_dependencies)*" "} | grep '^commit' --count || :")
              raise PrecompileRequired if result != "0"

              info("Skipping asset precompile, no asset diff found")

              # copy over all of the assets from the last release
              execute(:cp, '-r', latest_release_path.join('public', fetch(:assets_prefix)), release_path.join('public', fetch(:assets_prefix)))
            rescue PrecompileRequired
              info("Asset changes require precompiling")
              execute(:rake, "assets:precompile")
            end
          end
        end
      end
    end
  end
end

