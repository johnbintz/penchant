require 'erb'

module Penchant
  class Gemfile
    attr_reader :path, :is_deployment

    def self.do_full_env_switch!(env, deployment = false)
      return false if !(gemfile = pre_switch(env, deployment))

      gemfile.switch_to!(env, deployment)
    end

    def self.switch_back!(fallback_env)
      return false if !(gemfile = pre_switch(fallback_env))

      gemfile.switch_back!(fallback_env)
    end

    def self.pre_switch(env, deployment = false)
      gemfile = Penchant::Gemfile.new
      return false if !gemfile.has_gemfile_erb?
      gemfile.run_dot_penchant!(env, deployment)

      gemfile
    end

    def current_env ; @env ; end

    def initialize(path = Dir.pwd)
      @path = path
    end

    def gemfile_path
      file_in_path('Gemfile')
    end

    def has_gemfile?
      File.file?(gemfile_path)
    end

    def has_dot_penchant?
      File.file?('.penchant')
    end

    def gemfile_erb_path
      file_in_path('Gemfile.erb')
    end

    def has_gemfile_erb?
      File.file?(gemfile_erb_path)
    end

    def environment
      gemfile_header.strip[%r{environment: ([^, ]*)}, 1]
    end

    def deployment?
      gemfile_header['deployment mode'] != nil
    end

    def switch_to!(gemfile_env = nil, deployment = false)
      @env, @is_deployment = gemfile_env, deployment

      output = [ header, ERB.new(template).result(binding) ]

      File.open(gemfile_path, 'wb') { |fh| fh.print output.join("\n") }
    end

    def run_dot_penchant!(env, deployment)
      DotPenchant.run(env || environment, deployment) if has_dot_penchant?
    end

    def header
      header = [ "# generated by penchant, environment: #{current_env}" ]

      if is_deployment
        header << ", deployment mode (was #{environment})"
      end

      header.join
    end

    def prior_environment
      gemfile_header[%r{\(was (.+)\)}, 1]
    end

    def switch_back!(fallback_env)
      switch_to!(prior_environment || fallback_env)
    end

    private
    def file_in_path(file)
      File.join(@path, file)
    end

    def template
      File.read(gemfile_erb_path)
    end

    def env(check, &block)
      instance_eval(&block) if check.to_s == @env.to_s
    end

    def no_deployment(&block)
      instance_eval(&block) if !@is_deployment
    end

    def gemfile_header
      (has_gemfile? and File.readlines(gemfile_path).first) or ""
    end
  end
end

