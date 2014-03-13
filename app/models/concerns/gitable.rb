module Gitable
  extend ActiveSupport::Concern

  def local_commit
    FileUtils.cd(root_folder)
    stdout = `git rev-parse HEAD`
    commit = (stdout.match(/[0-9a-f]{40}/)[0] rescue '')
    commit
  end

  def remote_commit
    FileUtils.cd(root_folder)
    stdout = `git ls-remote #{self.git_repository} HEAD`
    commit = (stdout.match(/[0-9a-f]{40}/)[0] rescue '')
    commit
  end

  def pull_latest!
    FileUtils.cd(root_folder)
    stdout = `git pull`
    stdout
  end
end
