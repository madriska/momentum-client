require "json"
require "erb"
require "fileutils"

module Turbine
  module StandardCommands
    include FileUtils

    def init
      mkdir_p(".turbine")
      mkdir_p(".turbine/log")
      mkdir_p(".turbine/commands")
      mkdir_p(".turbine/commands/custom")

      key  = params[:api_key] || ENV['TURBINE_API_KEY']
      url  = params[:arguments][0]
      project_name = params[:arguments][1] || "default"

      raise if key.nil?
      
      current_dir = File.dirname(__FILE__)

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

      cp_r("#{current_dir}/standard", 
           "#{self.class.config_dir}/commands/")
    end
  end
end      
