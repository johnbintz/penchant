module Penchant
  class PropertyStackProcessor
    def initialize(builder)
      @builder = builder
    end

    def process(gem_name, stack)
      properties = {}
      property_stack = stack.dup.to_a

      while !property_stack.empty?
        key, value = property_stack.shift

        if property = @builder[key]
          property_stack += property.process([ value ].flatten)
        else
          value = value % gem_name if value.respond_to?(:%)

          properties[key] = value
        end
      end

      properties
    end
  end
end
