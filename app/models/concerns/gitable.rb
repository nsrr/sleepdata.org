module Gitable
  extend ActiveSupport::Concern

  def local_commit
    FileUtils.cd(root_folder)
    stdout = `git rev-parse HEAD` rescue stdout = ''
    commit = (stdout.match(/[0-9a-f]{40}/)[0] rescue '')
  end

  def remote_repository_url
    FileUtils.cd(root_folder)
    stdout = `git ls-remote --get-url`
    stdout.gsub('git@github.com:', 'https://github.com/').strip
  end

  def remote_commit
    FileUtils.cd(root_folder)
    command = "git ls-remote #{self.remote_repository_url} HEAD"
    Rails.logger.info command
    stdout = `#{command}` rescue stdout = ''
    commit = (stdout.match(/[0-9a-f]{40}/)[0] rescue '')
  end

  def pull_latest!
    FileUtils.cd(root_folder)
    stdout = `git pull` rescue stdout = ''
  end
end
