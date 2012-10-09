module Penchant
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
      @defaults = Defaults.new
      @properties = PropertyStackBuilder.new(@defaults)

      @_current_env_defaults = {}
    end

    def result(_env, _is_deployment)
      @environment = _env.to_s.to_sym
      @is_deployment = _is_deployment

      @output = []

      handle_result(@data)

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

    def ruby(version)
      self << %{ruby "#{version}"}
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

    def process_options(gem_name, template = {})
      properties = Properties.new(template)

      original_properties = process_option_stack(gem_name, property_stack)

      if @_strip_pathing_options
        [ :git, :branch, :path ].each { |key| original_properties.delete(key) }
      end

      properties = process_option_stack(gem_name, _defaults_for(gem_name).to_a).merge(original_properties)

      properties.delete(:opposite)

      Hash[properties.sort]
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
  end
end

