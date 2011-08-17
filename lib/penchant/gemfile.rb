module Penchant
  class Gemfile
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def has_gemfile?
      has_file_in_path?('Gemfile')
    end

    def has_gemfile_erb?
      has_file_in_path?('Gemfile.erb')
    end

    private
    def has_file_in_path?(file)
      File.file?(File.join(@path, file))
    end
  end
end

