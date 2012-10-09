module Penchant
  class Defaults
    def initialize
      @defaults = {}
    end

    def [](key)
      @defaults[key.to_s] ||= {}
    end
  end
end
