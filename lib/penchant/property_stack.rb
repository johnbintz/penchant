module Penchant
  class PropertyStack
    PATHING_OPTIONS = [ :git, :branch, :path ].freeze

    def initialize(builder, property_stack, strip_pathing_options)
      @builder, @property_stack, @strip_pathing_options = builder, property_stack.dup, strip_pathing_options
    end

    def processor
      @processor ||= PropertyStackProcessor.new(@builder)
    end

    def process_for_gem(gem_name, additional_env = {})
      properties = processor.process(gem_name, @property_stack)

      if @strip_pathing_options
        PATHING_OPTIONS.each { |key| properties.delete(key) }
      end

      properties = processor.process(gem_name, @builder.defaults[gem_name].merge(additional_env)).merge(properties)

      properties.delete(:opposite)

      Hash[properties.sort]
    end
  end
end

