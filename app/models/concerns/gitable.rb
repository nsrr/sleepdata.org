module Gitable
  extend ActiveSupport::Concern

  def retrieve_commit_number(reference)
    command = "git -C #{root_folder} rev-parse #{reference}"
    status, stdout, stderr =  systemu command
    commit = (stdout.match(/[0-9a-f]{40}/)[0] rescue nil)
  end

  def local_commit
    retrieve_commit_number('HEAD')
  end

  def remote_url
    status, stdout, stderr =  systemu "git -C #{root_folder} ls-remote --get-url"
    stdout.gsub('git@github.com:', 'https://github.com/')
  end

  def remote_commit
    remote = "git -C #{root_folder} ls-remote #{remote_url} HEAD"
    status, stdout, stderr =  systemu remote
    commit = (stdout.match(/[0-9a-f]{40}/)[0] rescue nil)
  end

  def requires_update?
    local_commit != remote_commit
  end

  def pull_latest!
    command = "git -C #{root_folder} pull"
    status, stdout, stderr = systemu command
    Rails.logger.debug command
    Rails.logger.debug status
    Rails.logger.debug stdout
    Rails.logger.debug stderr
  end
end
