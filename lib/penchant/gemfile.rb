module Penchant
  class Gemfile
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def gemfile_path
      file_in_path('Gemfile')
    end

    def has_gemfile?
      File.file?('Gemfile')
    end

    def gemfile_erb_path
      file_in_path('Gemfile.erb')
    end

    def has_gemfile_erb?
      File.file?(gemfile_erb_path)
    end

    def environment
      File.readlines(gemfile_path).first.strip[%r{environment: (.*)}, 1]
    end

    private
    def file_in_path(file)
      File.join(@path, file)
    end
  end
end

