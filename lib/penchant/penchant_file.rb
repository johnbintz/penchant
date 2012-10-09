module Penchant
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

      options = @properties.create_stack_for(template, @_strip_pathing_options).process_for_gem(gem_name.first, @_current_env_defaults)

      args = [ gem_name.first ]
      args << version if version

      if options[:git]
        @defined_git_repos << Penchant::Repo.new(options[:git])
      end

      args << options if !options.empty?

      self << %{gem #{args_to_string(args)}}
    end

    def gemspec
      @output << %{gemspec}
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

    def source(*args)
      self << %{source #{args_to_string(args)}}
    end
  end
end

