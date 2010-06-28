module Turbine
  class Queue 
    include Enumerable

    def initialize(dir=Turbine::Application.config_dir)
      @file = "#{dir}/queue"
    end

    def <<(duration)
      File.open(@file, "a") { |f| f.puts(duration.to_s)}
      self
    end

    def empty?
      !File.exist?(@file)
    end

    def entries
      return [] if empty?

      File.read(@file).split("\n").map { |e| e.to_f }
    end

    def each
      entries.each { |e| yield(e) }
    end

    def sum
      return 0 if empty?

      File.foreach(@file).inject(0) do |sum, line|
        sum + line.to_f
      end
    end

    def clear
      FileUtils.rm_f(@file)
    end
  end
end
