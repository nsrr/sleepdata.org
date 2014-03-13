module Gitable
  extend ActiveSupport::Concern

  def local_commit
    FileUtils.cd(root_folder)
    stdout = `git rev-parse HEAD`
    commit = (stdout.match(/[0-9a-f]{40}/)[0] rescue '')
    Rails.logger.info "LOCAL_COMMIT: #{commit}"
    commit
  end

  def remote_commit
    FileUtils.cd(root_folder)
    command = "git ls-remote #{self.git_repository} HEAD"
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
