module Penchant
  class DotPenchant
    class << self
      def run(env = nil)
        dot_penchant = new
        dot_penchant.run(env)
        dot_penchant
      end
    end

    def run(env = nil)
      instance_eval(File.read('.penchant'))
    end
  end
end

