require 'pathname'

module Penchant
  class Hooks
    HOOKS_DIR = 'script/hooks'
    GIT_HOOKS_DIR = '.git/hooks'

    def self.installed?
      if File.directory?(HOOKS_DIR)
        Dir[File.join(HOOKS_DIR, '*')].each do |file|
          target = File.join(GIT_HOOKS_DIR, File.basename(file))
          return false if !File.symlink?(target)
          return false if !File.expand_path(File.readlink(target)) == File.expand_path(file)
        end

        true
      end
    end
  end
end

