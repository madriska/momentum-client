Turbine::Application.extension do
  def commit
    if message = params[:message]
      queue      = Turbine::Queue.new
      duration   = queue.sum.to_s
      timestamp  = Time.now.utc.to_s

      if queue.empty?
        prompt.say "ERROR: No entries!"
        exit
      end

      log_data = load_log_data

      log_data << { :description          => message,
                    :recorded_timestamp   => timestamp,
                    :recorded_date        => Date.today.to_s,
                    :hours                => duration }

      write_file("log/#{self.class.api_key}.json") { |f| f << log_data.to_json }

      prompt.say "Committed time entry totaling #{duration} hrs"

      queue.clear
    else
      prompt.say "You need to supply a message"
    end
  end
end
