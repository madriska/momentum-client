Turbine::Application.extension do 
  def status
    queue = Turbine::Queue.new
    
    if queue.empty?
      prompt.say "No entries for this commit yet\n\n"
    else
      entries = queue.entries.join(", ")
      sum     = queue.entries.inject {|sum, n| sum + n }
      prompt.say "Entries for this commit: ( #{entries} )"
      prompt.say "Total for this commit: #{sum}\n\n"
    end

    timer = Turbine::Timer.new
    if timer.running?
      prompt.say("Current timer started at #{timer.timestamp}")
      prompt.say("Elapsed time: #{'%0.2f' % timer.elapsed_time} hrs")
    else
      prompt.say("Timer is not presently running")
    end

    prompt.say("\n")
  end
end
