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
      else
        # no script/hooks dir, so we must not want them
        true
      end
    end

    def self.install!
      if git?
        puts "[penchant] installing git hooks"

        Dir['script/hooks/*'].each do |hook|
          FileUtils.ln_sf File.join(Dir.pwd, hook), "#{GIT_HOOKS_DIR}/#{File.split(hook).last}"
        end
      end
    end

    def self.git?
      File.directory?(GIT_HOOKS_DIR)
    end
  end
end

