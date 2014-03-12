module Gitable
  extend ActiveSupport::Concern

  def retrieve_commit_number(reference)
    command = "git rev-parse #{reference}"
    status, stdout, stderr = systemu command, cwd: root_folder
    commit = (stdout.match(/[0-9a-f]{40}/)[0] rescue '')
  end

  def local_commit
    retrieve_commit_number('HEAD')
  end

  def remote_url
    status, stdout, stderr = systemu "git ls-remote --get-url", cwd: root_folder
    stdout.gsub('git@github.com:', 'https://github.com/').strip
  end

  def remote_commit
    remote = "git ls-remote #{remote_url} HEAD"
    status, stdout, stderr =  systemu remote, cwd: root_folder
    commit = (stdout.match(/[0-9a-f]{40}/)[0] rescue '')
  end

  def requires_update?
    local_commit != remote_commit
  end

  def pull_latest!
    command = "git pull"
    status, stdout, stderr = systemu command, cwd: root_folder
    Rails.logger.debug command
    Rails.logger.debug status
    Rails.logger.debug stdout
    Rails.logger.debug stderr
  end
end
