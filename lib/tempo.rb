require "fileutils"
require "date"

module Tempo

  class Timer
    MissingTimestampError = Class.new(StandardError)

    def initialize(dir)
      @file = "#{dir}/timestamp"
    end

    def write_timestamp
      File.open(@file, "w") { |f| f << Time.now.utc.to_s }
    end
    
    def read_timestamp
      raise MissingTimestampError unless running?
      File.read(@file)
    end
    
    def elapsed_time
      (DateTime.now.to_time.utc - DateTime.parse(read_timestamp).to_time.utc) / 60.0 / 60.0
    end

    def clear_timestamp
      FileUtils.rm_f(@file)
    end

    def running?
      File.exist?(@file)
    end

  end

  class Queue
    EmptyQueueError = Class.new(StandardError)

    def initialize(dir)
      @file = "#{dir}/timestamp"
    end

    def <<(duration)
      File.open(@file, "a") { |f| f.puts(duration.to_s)}
    end

    def empty?
      !File.exist?(@file)
    end

    def compute
      raise EmptyQueueError if empty?

      sum = 0

      File.foreach(@file) do |line|
        sum += line.to_f
      end
      
      return sum
    end

    def clear
      FileUtils.rm_f(@file)
    end
  end

  class Client

  end

end
