require "fileutils"
require "time"
require "optparse"
require "pathname"
require "erb"

require "highline"
require "fastercsv"

module Turbine

  extend self

  attr_accessor :user, :client, :project

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
      (Time.now.utc - Time.parse(read_timestamp).utc) / 60.0 / 60.0
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

    def initialize(basedir, queue="queue")
      @file = "#{basedir}/#{queue}"
    end

    def <<(duration)
      File.open(@file, "a") { |f| f.puts(duration.to_s)}
    end

    def empty?
      !File.exist?(@file)
    end

    def entries
      File.read(@file).split("\n").map { |e| e.to_f }
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

  class Application
    COMMANDS = %w[init start stop commit add reset rewind export log status stash]
    
    include FileUtils

    def initialize(argv)
      @params = {}
      @prompt = HighLine.new
      parse_options(argv)
    end
    
    attr_reader :params, :prompt, :turbine_dir, :command, :arguments

    extendable_features = Module.new do
      def init
        mkdir_p(".turbine")
        mkdir_p(".turbine/log")
        mkdir_p(".turbine/stashes")
        
        user    = prompt.ask("user: ")
        client  = prompt.ask("client: ")
        project = prompt.ask("project: ")

        FasterCSV.open(".turbine/log/#{user}.csv", "w") do |csv|
          csv << ["date", "client", "project", "message", "duration"]
        end

        File.open(".turbine/config.rb", "w") do |f|
          template = File.read("#{File.dirname(__FILE__)}/../data/config.rb.erb")
          f << ERB.new(template).result(binding)
        end
      end

      def start
        timer = Turbine::Timer.new(turbine_dir)
        if timer.running?
          prompt.say "Timer already started, please stop or rewind first"
        else
          timer.write_timestamp
          prompt.say "Timer started at #{Time.now}"
        end
      end

      def stop
        timer = Turbine::Timer.new(turbine_dir)
        if timer.running?
          begin
            duration = prompt.ask("Time to enter (CTRL-C to cancel): ", Float) do |q|
              q.default = ("%0.2f" % timer.elapsed_time).to_f
            end

            queue = Turbine::Queue.new(turbine_dir)
            queue << duration

            timer.clear_timestamp
          rescue Interrupt
            prompt.say("\n")
          end
        else
          prompt.say "ERROR: Timer was not running."
        end
      end

      def add
        hours = arguments.first

        queue = Turbine::Queue.new(turbine_dir)
        queue << hours
      end

      def log
        if File.exist?("#{turbine_dir}/log/#{Turbine.user}.csv")
          prompt.say File.read("#{turbine_dir}/log/#{Turbine.user}.csv")
        else
          prompt.say "No log has been created yet."
        end
      end

      def status
        prompt.say "\nRecording time for #{Turbine.client}: #{Turbine.project}\n\n"

        queue = Turbine::Queue.new(turbine_dir)
        
        if queue.empty?
          prompt.say "No entries for this commit yet\n\n"
        else
          entries = queue.entries.join(", ")
          sum     = queue.entries.inject {|sum, n| sum + n }
          prompt.say "Entries for this commit: ( #{entries} )"
          prompt.say "Total for this commit: #{sum}\n\n"
        end

        timer = Turbine::Timer.new(turbine_dir)
        if timer.running?
          prompt.say("Current timer started at #{timer.read_timestamp}")
          prompt.say("Elapsed time: #{'%0.2f' % timer.elapsed_time} hrs")
        else
          prompt.say("Timer is not presently running")
        end

        prompt.say("\n")
      end

      # FIXME: Unlike the rest of these commands, stash may involve some actual
      # thought.  Bad code below shows what happens when you wing it.
      # 
      def stash
        timer = Turbine::Timer.new(turbine_dir)

        if timer.running?
          prompt.say "Cannot use stash while timer is running.  Stop or rewind it first"
          return
        end

        case label = arguments.shift
        when nil
          prompt.say "You need to supply a label"
        when "list"
          prompt.say((turbine_dir + "stashes/").children.map { |e| e.basename }.join("\n"))
        when "drop"
          label = arguments.shift
          unless label
            prompt.say "You need to supply a label"
            return
          end

          if label[" "]
            prompt.say "label may not include spaces"
            return
          end

          rm_f "#{@turbine_dir}/stashes/#{label}"
        when "apply"
          label = arguments.shift

          unless label
            prompt.say "You need to supply a label"
            return
          end

         
          stashed_queue = Turbine::Queue.new(turbine_dir, "stashes/#{label}")

          if stashed_queue.empty?
            prompt.say "Invalid stash name"
            return
          end

          queue = Turbine::Queue.new(turbine_dir)

          stashed_queue.entries.each do |item|
            queue << item
          end

          rm_f("#{turbine_dir}/stashes/#{label}")

          status
        else
         unless label
           prompt.say "You need to supply a label"
           return
         end

         if label[" "]
           prompt.say "label may not include spaces"
           return
         end

          if File.exist?(turbine_dir + "/stashes/#{label}")
            prompt.say "Stash already exists.  Drop it first or use a different name"
            return
          end

          queue = Turbine::Queue.new(turbine_dir)

          if queue.empty?
            prompt.say "No times recorded yet, creating a stash would have no effect"
            return
          end

          mv "#{turbine_dir}/queue", "#{turbine_dir}/stashes/#{label}"
        end
      end

      def rewind
        rm_f "#{turbine_dir}/timestamp"
      end

      def reset
        rm_f "#{turbine_dir}/queue"
      end

      def export
        cp "#{turbine_dir}/log/#{Turbine.user}.csv", arguments.first
      end

      def commit
        if message = params[:message]
          queue = Turbine::Queue.new(turbine_dir)
          duration = queue.compute.to_s

          if queue.empty?
            prompt.say "ERROR: No entries!"
            exit
          end

          FasterCSV.open("#{turbine_dir}/log/#{Turbine.user}.csv", "a") do |csv|
            csv << [Date.today.strftime("%Y.%m.%d"), Turbine.client, Turbine.project, message, duration]
          end

          prompt.say "Committed time entry totaling #{duration} hrs"

          queue.clear
        else
          prompt.say "You need to supply a message"
        end
      end

      def run
        return init if command == "init"

        unless @turbine_dir = config_dir
          prompt.say "Cannot find config file.  Did you forget to run turbine init?"
          return
        end

        require "#{@turbine_dir}/config"

        if COMMANDS.include?(command) 
          send(command)
        else 
          prompt.say("Unknown command: #{command}")
        end
      end

      def config_dir(dir = Pathname.new("."))
        turbine_dir = dir + ".turbine"
        if dir.children.include?(turbine_dir)
          turbine_dir.expand_path
        else
          return nil if dir.expand_path.root?
          config_dir(dir.parent)
        end
      end


      def parse_options(argv)
        opts = OptionParser.new

        opts.on("-t", "=HOURS", Float) do |hours|
          params[:hours] = hours
        end

        opts.on("-m", "=MSG", String) do |msg|
          params[:message] = msg
        end

        @command, *@arguments = opts.parse(*ARGV)
      end
    end

    include extendable_features

  end
end
