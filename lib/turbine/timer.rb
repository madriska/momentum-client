require "fileutils"
require "time"
require "date"

module Turbine
  class Timer
    MissingTimestampError = Class.new(StandardError)

    def initialize(dir=Turbine::Application.config_dir)
      @file = "#{dir}/timestamp"
    end

    def write_timestamp
      File.open(@file, "w") { |f| f << Time.now.utc.to_s }
    end

    def timestamp
      raise MissingTimestampError unless running?
      Time.parse(File.read(@file)).localtime
    end

    def elapsed_time
      ((Time.now.utc - timestamp.utc) / 60.0 / 60.0).round(Turbine::PRECISION)
    end

    def clear_timestamp
      FileUtils.rm_f(@file)
    end

    def running?
      File.exist?(@file)
    end
  end
end

