module Penchant
  class PropertyStackBuilder
    attr_reader :defaults

    def initialize(defaults)
      @defaults = defaults

      @custom_properties = {}
    end

    def []=(key, value)
      @custom_properties[key] = CustomProperty.new(value)
    end

    def [](key)
      @custom_properties[key]
    end

    def create_stack_for(stack, strip_pathing_options = false)
      PropertyStack.new(self, stack, strip_pathing_options)
    end
  end
end
