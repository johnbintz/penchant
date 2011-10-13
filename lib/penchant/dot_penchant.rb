module Penchant
  class DotPenchant
    class << self
      def run(env = nil, deployment = false)
        dot_penchant = new
        dot_penchant.run(env)
        dot_penchant
      end
    end

    def run(env = nil, deployment = false)
      instance_eval(File.read('.penchant'))
    end

    def rake(*tasks)
      command = [ "rake", *tasks ]
      command.unshift("bundle exec") if gemfile?
      Kernel.system command.join(' ')
    end

    private
    def gemfile?
      File.file?('Gemfile')
    end
  end
end

