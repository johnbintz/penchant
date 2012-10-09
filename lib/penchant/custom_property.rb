module Penchant
  class CustomProperty
    def initialize(value)
      @value = value
    end

    def process(values)
      if @value.respond_to?(:call)
        @value.call(*values).to_a
      else
        @value.collect do |k, v|
          v = v.dup.gsub(%r{\$(\d+)}) { |m| values[m.to_i - 1 ] }

          [ k, v ]
        end
      end
    end
  end
end

