module Gitable
  extend ActiveSupport::Concern

  def working_tree
    "--git-dir #{root_folder}/.git/ --work-tree #{root_folder}"
  end

  def retrieve_commit_number(reference)
    command = "git #{working_tree} rev-parse #{reference}"
    status, stdout, stderr =  systemu command
    commit = (stdout.match(/[0-9a-f]{40}/)[0] rescue '')
  end

  def local_commit
    retrieve_commit_number('HEAD')
  end

  def remote_url
    status, stdout, stderr =  systemu "git #{working_tree} ls-remote --get-url"
    stdout.gsub('git@github.com:', 'https://github.com/').strip
  end

  def remote_commit
    remote = "git #{working_tree} ls-remote #{remote_url} HEAD"
    status, stdout, stderr =  systemu remote
    commit = (stdout.match(/[0-9a-f]{40}/)[0] rescue '')
  end

  def requires_update?
    local_commit != remote_commit
  end

  def pull_latest!
    command = "git #{working_tree} pull"
    status, stdout, stderr = systemu command
    Rails.logger.debug command
    Rails.logger.debug status
    Rails.logger.debug stdout
    Rails.logger.debug stderr
  end
end
