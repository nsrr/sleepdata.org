# frozen_string_literal: true

module Gitable
  extend ActiveSupport::Concern

  def local_commit
    return "" unless valid_git_repository?

    begin
      FileUtils.cd(root_folder)
    rescue Errno::ENOENT
      return ""
    end
    stdout = `git rev-parse HEAD`
    commit = (stdout.match(/[0-9a-f]{40}/)[0] rescue "")
    commit
  end

  def remote_commit
    return "" unless valid_git_repository?
    return "" unless repository_url

    begin
      FileUtils.cd(root_folder)
    rescue Errno::ENOENT
      return ""
    end
    stdout = `git ls-remote #{repository_url} HEAD`
    commit = (stdout.match(/[0-9a-f]{40}/)[0] rescue "")
    commit
  end

  def pull_latest!
    return "" unless valid_git_repository?

    begin
      FileUtils.cd(root_folder)
    rescue Errno::ENOENT
      return ""
    end
    stdout = `git fetch --all; git reset --hard origin/master`
    stdout
  end

  def git_init_repository!
    FileUtils.mkdir_p root_folder
    if repository_url.blank?
      disconnect_repository!
      return
    end

    begin
      FileUtils.cd(root_folder)
    rescue Errno::ENOENT
      return
    end
    `git init; git remote add origin #{repository_url}; git remote set-url origin #{repository_url}`
    pull_latest!
  end

  def disconnect_repository!
    begin
      FileUtils.cd(root_folder)
    rescue Errno::ENOENT
      return
    end

    `rm -rf .git/; rm -rf pages/` unless Rails.env.test?
  end

  def valid_git_repository?
    begin
      FileUtils.cd(root_folder)
    rescue Errno::ENOENT
      return false
    end

    stdout = `git rev-parse --show-toplevel`.to_s.strip
    root_folder == stdout
  end

  def repository_url
    URI.parse(git_repository).to_s
  rescue URI::Error
    nil
  end
end
