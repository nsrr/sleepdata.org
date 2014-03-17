module Gitable
  extend ActiveSupport::Concern

  def local_commit
    FileUtils.cd(root_folder) rescue return ''
    stdout = `git rev-parse HEAD`
    commit = (stdout.match(/[0-9a-f]{40}/)[0] rescue '')
    commit
  end

  def remote_commit
    FileUtils.cd(root_folder) rescue return ''
    (repository_url = URI.parse(self.git_repository).to_s) rescue return ''
    stdout = `git ls-remote #{repository_url} HEAD`
    commit = (stdout.match(/[0-9a-f]{40}/)[0] rescue '')
    commit
  end

  def pull_latest!
    FileUtils.cd(root_folder) rescue return ''
    stdout = `git pull`
    stdout
  end
end
