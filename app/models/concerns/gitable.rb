module Gitable
  extend ActiveSupport::Concern

  def local_commit
    return '' unless valid_git_repository?
    FileUtils.cd(root_folder) rescue return ''
    stdout = `git rev-parse HEAD`
    commit = (stdout.match(/[0-9a-f]{40}/)[0] rescue '')
    commit
  end

  def remote_commit
    return '' unless valid_git_repository?
    FileUtils.cd(root_folder) rescue return ''
    (repository_url = URI.parse(self.git_repository).to_s) rescue return ''
    stdout = `git ls-remote #{repository_url} HEAD`
    commit = (stdout.match(/[0-9a-f]{40}/)[0] rescue '')
    commit
  end

  def pull_latest!
    return '' unless valid_git_repository?
    FileUtils.cd(root_folder) rescue return ''
    stdout = `git fetch --all; git reset --hard origin/master`
    stdout
  end

  def valid_git_repository?
    FileUtils.cd(root_folder) rescue return false
    stdout = `git rev-parse --show-toplevel`.to_s.strip
    root_folder == stdout
  end
end
