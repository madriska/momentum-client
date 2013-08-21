require "json"
require "erb"
require "fileutils"

module Turbine
  module StandardCommands
    include FileUtils

    def setup
      option_parser.on("--update", "Update") do
        params[:update] = true
      end
    end

    def init
      current_dir = File.dirname(__FILE__)

      if params[:update] == true
        update_standard_commands(current_dir)
        prompt.say "Standard commands updated"
        return
      end

      mkdir_p(".turbine")
      mkdir_p(".turbine/log")
      mkdir_p(".turbine/commands")
      mkdir_p(".turbine/commands/custom")

      key  = params[:api_key] || ENV['TURBINE_API_KEY']
      url  = params[:arguments][0]
      project_name = params[:arguments][1] || "default"

      raise if key.nil?


      write_file("log/#{key}.json") { |f| f << [].to_json }

      write_file("config.rb") do |f|
        template    = File.read("#{current_dir}/../../../data/config.rb.erb")
        f << ERB.new(template).result(binding)
      end

      write_file("current_project") do |f|
        f << project_name
      end

      write_file("projects.json") do |f|
       f << { project_name => url }.to_json
      end

      update_standard_commands(current_dir)
    end

    private

    def update_standard_commands(current_dir)
      cp_r("#{current_dir}/standard",
        "#{self.class.config_dir}/commands/")
    end
  end
end
