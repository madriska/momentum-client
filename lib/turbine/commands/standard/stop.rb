Turbine::Application.extension do
  def stop
    timer = Turbine::Timer.new
    if timer.running?
      begin
        duration = prompt.ask("Time to enter (CTRL-C to cancel): ", Float) do |q|
          q.default = ("%0.2f" % timer.elapsed_time).to_f
        end

        queue = Turbine::Queue.new
        queue << duration

        timer.clear_timestamp
      rescue Interrupt
        prompt.say("\n")
      end
    else
      prompt.say "ERROR: Timer was not running."
    end
  end
end

