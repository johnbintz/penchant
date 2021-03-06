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
      gemfile = new
      return false if !gemfile.has_processable_gemfile?
      gemfile.run_dot_penchant!(env, deployment)

      gemfile
    end

    def self.available_environments
      new.available_environments
    end

    def self.defined_git_repos
      new.defined_git_repos
    end

    def current_env ; @env ; end

    def initialize(path = Dir.pwd)
      @path = path
      @env = environment
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

    def gemfile_penchant_path
      file_in_path('Gemfile.penchant')
    end

    def has_gemfile_penchant?
      File.file?(gemfile_penchant_path)
    end

    def has_processable_gemfile?
      has_gemfile_penchant?
    end

    def processable_gemfile_path
      gemfile_penchant_path
    end

    def environment
      gemfile_header.strip[%r{environment: ([^, ]*)}, 1]
    end

    def deployment?
      gemfile_header['deployment mode'] != nil
    end

    def available_environments
      process
      builder.available_environments
    end

    def defined_git_repos
      process(FileProcessor::ANY_ENVIRONMENT)
      builder.defined_git_repos
    end

    def switch_to!(gemfile_env = nil, deployment = false)
      @env, @is_deployment = gemfile_env, deployment

      output = [ header, process ]

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

    def process(env = @env)
      builder.result(env, @is_deployment)
    end

    def builder
      @builder ||= FileProcessor.new(template)
    end

    def template
      File.read(processable_gemfile_path)
    end

    def gemfile_header
      (has_gemfile? and File.readlines(gemfile_path).first) or ""
    end
  end
end

