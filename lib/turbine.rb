$LOAD_PATH.unshift(File.dirname(__FILE__))

module Turbine
  PRECISION = 2 # decimal places for rounding
end

require "turbine/timer"
require "turbine/queue"
require "turbine/commands/init"
require "turbine/command_runner"
require "turbine/application"
