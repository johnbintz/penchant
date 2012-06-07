module Penchant
  class Repo
    def initialize(url)
      @url = url
    end

    def clone_to(dir)
      Dir.chdir(dir) do
        system %{git clone #{@url}}
      end
    end

    def to_s ; @url ; end
  end
end

