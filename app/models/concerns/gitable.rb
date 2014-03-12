module Gitable
  extend ActiveSupport::Concern

  def local_commit
    FileUtils.cd(root_folder)
    stdout = `git rev-parse HEAD` rescue stdout = ''
    commit = (stdout.match(/[0-9a-f]{40}/)[0] rescue '')
  end

  def remote_url
    FileUtils.cd(root_folder)
    stdout = `git ls-remote --get-url`
    stdout.gsub('git@github.com:', 'https://github.com/').strip
  end

  def remote_commit
    FileUtils.cd(root_folder)
    stdout = `git ls-remote #{remote_url} HEAD` rescue stdout = ''
    commit = (stdout.match(/[0-9a-f]{40}/)[0] rescue '')
  end

  def pull_latest!
    FileUtils.cd(root_folder)
    stdout = `git pull` rescue stdout = ''
  end
end
