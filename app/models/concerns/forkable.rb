# frozen_string_literal: true

# Allows long running methods to be forked easily
module Forkable
  extend ActiveSupport::Concern

  def fork_process(method, *args)
    if args.last.is_a? Hash
      hash = args.pop
      fork_process_with_hash(method, args, hash)
    else
      fork_process_with_array(method, args)
    end
  end

  private

  def fork_process_with_array(method, args)
    if Rails.env.test?
      send method, *args
    else
      create_fork_with_array method, args
    end
  end

  def fork_process_with_hash(method, args, hash)
    if Rails.env.test?
      send method, *args, **hash
    else
      create_fork_with_hash method, args, hash
    end
  end

  def create_fork_with_array(method, args)
    pid = Process.fork
    if pid.nil?
      send method, *args
      Kernel.exit!
    else
      Process.detach pid
    end
  end

  def create_fork_with_hash(method, args, hash)
    pid = Process.fork
    if pid.nil?
      send method, *args, **hash
      Kernel.exit!
    else
      Process.detach pid
    end
  end
end
