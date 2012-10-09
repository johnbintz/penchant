module Penchant
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
end

