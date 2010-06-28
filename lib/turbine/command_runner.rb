module Turbine
  module CommandRunner
    def setup
    end

    def run(argv)
      init_and_exit(*argv) if argv[0] == "init"

      unless self.class.config_dir
        prompt.say "Cannot find config file.  Did you forget to run turbine init?"
        return
      end

      require "#{self.class.config_dir}/config"

      self.class.extensions.each do |extension|
        extend(extension)
      end

      setup
      parse_options(*argv)

      if respond_to?(command) 
        send(command)
      else 
        prompt.say("Unknown command: #{command}")
      end

       teardown
    end

    def init_and_exit(*argv)
      setup
      parse_options(*argv)
      init
      teardown
      exit
    end

     def teardown
     end

    def parse_options(*argv)
      option_parser.on("-t", "=HOURS", Float) do |hours|
        params[:hours] = hours
      end

      option_parser.on("-m", "=MSG", String) do |msg|
        params[:message] = msg
      end

      option_parser.on("-k", "=KEY", String) do |msg|
        params[:api_key] = msg
      end

      command, *arguments = option_parser.parse(*argv)

      self.command = command
      params[:arguments] = arguments
    end
  end
end
 
