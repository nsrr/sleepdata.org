module Gitable
  extend ActiveSupport::Concern

  def local_commit
    FileUtils.cd(root_folder)
    stdout = `git rev-parse HEAD`
    commit = (stdout.match(/[0-9a-f]{40}/)[0] rescue '')
    Rails.logger.info "LOCAL_COMMIT: #{commit}"
    commit
  end

  def remote_repository_url
    Rails.logger.info self.inspect
    Rails.logger.info root_folder
    FileUtils.cd(root_folder)
    Rails.logger.info Dir.pwd
    result = `git ls-remote --get-url`
    version = `git --version`
    Rails.logger.info "VERSION: #{version}"
    Rails.logger.info "REMOTE_REPOSITORY_URL (result): #{result}"
    repository = result.gsub('git@github.com:', 'https://github.com/').strip
    Rails.logger.info "REMOTE_REPOSITORY_URL: #{repository}"
    repository
    "https://github.com/nsrr/shhs-documentation.git"
  end

  def remote_commit
    FileUtils.cd(root_folder)
    command = "git ls-remote #{self.remote_repository_url} HEAD"
    Rails.logger.info command
    stdout = `#{command}`
    commit = (stdout.match(/[0-9a-f]{40}/)[0] rescue '')
    Rails.logger.info "REMOTE_COMMIT: #{commit}"
    commit
  end

  def pull_latest!
    FileUtils.cd(root_folder)
    stdout = `git pull`
    Rails.logger.info "PULL_LATEST!: #{stdout}"
    stdout
  end
end
