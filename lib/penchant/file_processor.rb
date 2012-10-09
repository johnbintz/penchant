module Penchant
  class FileProcessor
    attr_reader :environment, :is_deployment, :available_environments, :defined_git_repos

    ANY_ENVIRONMENT = :any_environment

    def self.result(data, *args)
      new(data).result(*args)
    end

    def initialize(data)
      @data = data
      @available_environments = []
      @defined_git_repos = []
      @defaults = Defaults.new
      @properties = PropertyStackBuilder.new(@defaults)

      @_current_env_defaults = {}
    end

    def result(_env, _is_deployment)
      @environment = _env.to_s.to_sym
      @is_deployment = _is_deployment

      @output = []

      instance_eval(@data)

      @output.join("\n")
    end

    def <<(string)
      @output << string
    end

    def env(*args)
      options = {}
      options = args.pop if args.last.kind_of?(::Hash)

      @available_environments += args

      requested_env_defaults = _defaults_for(Env.new(environment))

      if block_given?
        if for_environment?(args)
          @_current_env_defaults = requested_env_defaults
          yield
          @_current_env_defaults = {}
        else
          if opposite_environment = (options[:opposite] or requested_env_defaults[:opposite])
            if for_environment?([ environment, args, opposite_environment ].flatten.uniq)
              @_current_env_defaults = requested_env_defaults
              @_strip_pathing_options = true
              yield
              @_strip_pathing_options = false
              @_current_env_defaults = {}
            end
          end
        end
      else
        Env.new(args.shift)
      end
    end

    def property(name, hash = nil, &block)
      @properties[name] = hash || block
    end

    def opposites(left, right)
      @defaults[Env.new(left)][:opposite] = right
      @defaults[Env.new(right)][:opposite] = left
    end

    def for_environment?(envs)
      envs.include?(environment) || environment == ANY_ENVIRONMENT
    end

    def no_deployment
      yield if !is_deployment
    end

    def ensure_git_hooks!
      Penchant::Hooks.install!
    end

    def os(*args)
      yield if args.include?(current_os)
    end

    def defaults_for(*args)
      defaults = args.pop

      args.flatten.each do |gem|
        @defaults[gem].merge!(defaults)
      end
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

    def call_and_indent_output(block = nil, &given_block)
      index = @output.length
      (block || given_block).call
      index.upto(@output.length - 1) do |i|
        @output[i] = "  " + @output[i]
      end
    end

    def _defaults_for(gem_name)
      result = @_current_env_defaults
      result.merge(@defaults[gem_name] || {})
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

    def gem(*args)
      gem_name = [ args.shift ]
      template = {}

      if args.last.kind_of?(::Hash)
        template = args.pop
      end

      version = args.first

      options = @properties.create_stack_for(template, @_strip_pathing_options).process_for_gem(gem_name.first, @_current_env_defaults)

      args = [ gem_name.first ]
      args << version if version

      if options[:git]
        @defined_git_repos << Penchant::Repo.new(options[:git])
      end

      args << options if !options.empty?

      self << %{gem #{args_to_string(args)}}
    end

    def gems(*args)
      gems, template = split_args(args)

      gems.flatten.each do |gem_name|
        options = @properties.create_stack_for(template, @_strip_pathing_options).process_for_gem(gem_name)

        args = [ gem_name ]
        args << options if !options.empty?

        gem *args
      end
    end

    def group(*args, &block)
      self << ""
      self << %{group #{args_to_string(args)} do}

      call_and_indent_output(block)

      self << %{end}
    end

    def ruby(*args)
      passthrough :ruby, *args
    end

    def gemspec
      passthrough :gemspec
    end

    def source(*args)
      passthrough :source, *args
    end

    def passthrough(method, *args)
      self << %{#{method} #{args_to_string(args)}}.strip
    end
  end
end

