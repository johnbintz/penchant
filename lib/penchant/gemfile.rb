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

    def gemfile_erb_path
      file_in_path('Gemfile.erb')
    end

    def gemfile_penchant_path
      file_in_path('Gemfile.penchant')
    end

    def has_gemfile_erb?
      File.file?(gemfile_erb_path)
    end

    def has_gemfile_penchant?
      File.file?(gemfile_penchant_path)
    end

    def has_processable_gemfile?
      has_gemfile_erb? || has_gemfile_penchant?
    end

    def processable_gemfile_path
      has_gemfile_erb? ? gemfile_erb_path : gemfile_penchant_path
    end

    def environment
      gemfile_header.strip[%r{environment: ([^, ]*)}, 1]
    end

    def deployment?
      gemfile_header['deployment mode'] != nil
    end

    class Env
      attr_accessor :name

      def initialize(name)
        @name = name.to_s
      end

      def ==(other)
        @name == other.name
      end

      def to_s
        "@#{name}"
      end
    end

    class FileProcessor
      attr_reader :environment, :is_deployment, :available_environments, :defined_git_repos

      ANY_ENVIRONMENT = :any_environment

      def self.result(data, *args)
        new(data).result(*args)
      end

      def self.handle_result(&block)
        if block
          @handle_result = block
        else
          @handle_result
        end
      end

      def initialize(data)
        @data = data
        @available_environments = []
        @defined_git_repos = []
        @defaults = {}

        @_current_env_defaults = {}
      end

      def result(_env, _is_deployment)
        @environment = _env.to_s.to_sym
        @is_deployment = _is_deployment

        @output = []

        handle_result(@data)

        @output.join("\n")
      end

      def env(*args)
        @available_environments += args

        if block_given?
          if for_environment?(args)
            @_current_env_defaults = _defaults_for(Env.new(environment))
            yield
            @_current_env_defaults = {}
          end
        else
          Penchant::Gemfile::Env.new(args.shift)
        end
      end

      def for_environment?(envs)
        envs.include?(environment) || environment == ANY_ENVIRONMENT
      end

      def no_deployment
        yield if !is_deployment
      end

      def os(*args)
        yield if args.include?(current_os)
      end

      def defaults_for(*args)
        defaults = args.pop

        args.flatten.each { |gem| @defaults[gem.to_s] = defaults.dup }
      end

      protected
      def args_to_string(args)
        args.inspect[1..-2]
      end

      def split_args(args)
        template = {}

        while args.last.instance_of?(Hash)
          template.merge!(args.pop)
        end

        [ args, template ]
      end

      def call_and_indent_output(block)
        index = @output.length
        block.call
        index.upto(@output.length - 1) do |i|
          @output[i] = "  " + @output[i]
        end
      end

      def process_options(gem_name, template = {})
        Hash[
          _defaults_for(gem_name).dup.merge(template).collect { |key, value|
            value = value % gem_name if value.respond_to?(:%)

            [ key, value ]
          }.sort
        ]
      end

      def _defaults_for(gem_name)
        result = @_current_env_defaults
        result.merge(@defaults[gem_name.to_s] || {})
      end

      def current_os
        require 'rbconfig'
        case host_os = RbConfig::CONFIG['host_os']
        when /darwin/
          :darwin
        when /linux/
          :linux
        else
          host_os[%r{^[a-z]+}, 1].to_sym
        end
      end
    end

    class ERBFile < FileProcessor
      def handle_result(data)
        @output << ERB.new(data, nil, nil, '@_erbout').result(binding)
      end

      def env(check, template = {}, &block)
        if check.to_s == @environment.to_s
          original_erbout = @_erbout.dup
          @_erbout = ''

          output = instance_eval(&block).lines.to_a

          output.each do |line|
            if gem_name = line[%r{gem ['"]([^'"]+)['"]}, 1]
              new_line = line.rstrip

              if !(options = process_options(gem_name, template)).empty?
                new_line += ", #{options.inspect}"
              end

              line.replace(new_line + "\n")
            end
          end

          @_erbout = original_erbout + output.join
        end
      end

      def gems(*gems)
        template = {}
        template = gems.pop if gems.last.instance_of?(Hash)

        gems.flatten.each do |gem|
          @_current_gem = gem
          if block_given?
            yield
          else
            @_erbout += gem(template) + "\n"
          end
        end
      end

      def gem(template = {})
        output = "gem '#{@_current_gem}'" 
        options = process_options(@_current_gem, template)
        if !options.empty?
          output += ", #{options.inspect}"
        end
        output
      end
    end

    class PenchantFile < FileProcessor
      def handle_result(data)
        instance_eval(data)
      end

      def gem(*args)
        gem_name = [ args.shift ]
        template = {}

        if args.last.kind_of?(::Hash)
          template = args.pop
        end

        version = args.first

        options = process_options(gem_name.first, template)

        args = [ gem_name.first ]
        args << version if version
        args << options if !options.empty?

        if options[:git]
          @defined_git_repos << Penchant::Repo.new(options[:git])
        end

        @output << %{gem #{args_to_string(args)}}
      end

      def gemspec
        @output << %{gemspec}
      end

      def gems(*args)
        gems, template = split_args(args)

        gems.flatten.each do |gem_name|
          options = process_options(gem_name, template)

          args = [ gem_name ]
          args << options if !options.empty?

          gem *args
        end
      end

      def group(*args, &block)
        @output << ""
        @output << %{group #{args_to_string(args)} do}

        call_and_indent_output(block)

        @output << %{end}
      end

      def source(*args)
        @output << %{source #{args_to_string(args)}}
      end
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
      return @builder if @builder

      klass = case File.extname(processable_gemfile_path)
      when '.penchant'
        PenchantFile
      when '.erb'
        ERBFile
      end

      @builder = klass.new(template)
    end

    def template
      File.read(processable_gemfile_path)
    end

    def gemfile_header
      (has_gemfile? and File.readlines(gemfile_path).first) or ""
    end
  end
end

