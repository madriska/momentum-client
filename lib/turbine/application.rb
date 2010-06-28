require "pathname"
require "highline"
require "restclient"

module Turbine
  class Application

    class << self
      def config_dir(dir = Pathname.new("."))
        turbine_dir = dir + ".turbine"
        if dir.children.include?(turbine_dir)
          turbine_dir.expand_path
        else
          return nil if dir.expand_path.root?
          config_dir(dir.parent)
        end
      end

      def extensions
        @extensions ||= []
      end

      def extension(&block)
        extensions << Module.new(&block)
      end

      attr_accessor :url, :api_key
    end

    def initialize
      @params        = {}
      @prompt        = HighLine.new
      @option_parser = OptionParser.new
      @turbine_dir   = nil
    end

    def read_file(name)
      File.read("#{self.class.config_dir}/#{name}")
    end

    def write_file(name, mode="w")
      File.open("#{self.class.config_dir}/#{name}", mode) { |f| yield(f) }
    end

    def delete_file(name)
      rm_f "#{self.class.config_dir}/#{name}"
    end

    def service
      RestClient::Resource.new(self.class.url, self.class.api_key, "")
    end

    def load_log_data
      JSON.parse(File.read("#{self.class.config_dir}/log/#{self.class.api_key}.json"))
    end

    def clear_log_data
      write_file("log/#{self.class.api_key}.json") do |f|
        f << [].to_json
      end
    end

    attr_accessor :params, :prompt, :option_parser, :command

    include ::Turbine::CommandRunner
    include ::Turbine::StandardCommands
  end
end
