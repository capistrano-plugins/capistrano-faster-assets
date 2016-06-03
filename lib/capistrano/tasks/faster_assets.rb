# Original source: https://coderwall.com/p/aridag

require "capistrano/faster_assets"

Capistrano::Configuration.instance(:must_exist).load do
  # set the locations that we will look for changed assets to determine whether to precompile
  _cset(:assets_dependencies) { Capistrano::FasterAssets::DEPENDENCIES }
  _cset(:assets_manifest_basename) { "assets_manifest" }

  # Alias the base capistrano provided task so that we can still access it
  alias_task("deploy:assets:force_precompile", "deploy:assets:precompile")

  def first_deploy?
    previous_release.nil?
  end

  def previous_release_failed_compilation?
    previous_manifest_count = capture("ls -1 #{previous_release}/#{assets_manifest_basename}* | wc -l").to_i

    previous_manifest_count < 1
  end

  def asset_file_diff?
    assets_dependencies.any? do |dep|
      previous = "#{previous_release}/#{dep}"
      latest = "#{release_path}/#{dep}"

      # skip if both directories/files do not exist
      next if [previous, latest].any? { |path| result = capture("ls -1 #{path} | wc -l"); puts result; result.to_i < 1 }

      # if there are file diffs between the directories/files, return true
      diff = capture("diff -Nqr #{previous} #{latest} | wc -l")
      diff.to_i > 0
    end
  end

  namespace :deploy do
    namespace :assets do
      desc <<-DESC
        Override capistrano v2's deploy:assets:precompile to add a pre-check
        for differences in asset files in subsequent relase before invoking
        the task.
      DESC
      task :precompile, roles: lambda { assets_role }, except: { no_release: true } do
        if !first_deploy? && !previous_release_failed_compilation? && !asset_file_diff?
          logger.info("Skipping asset precompile, no asset diff found")
        else
          force_precompile
        end
      end
    end
  end
end
