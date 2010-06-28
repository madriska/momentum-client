Turbine::Application.extension do
  def start
    timer = Turbine::Timer.new
    if timer.running?
      prompt.say "Timer already started, please stop or rewind first"
    else
      timer.write_timestamp
      prompt.say "Timer started at #{Time.now}"
    end
  end
end
