Turbine::Application.extension do
  def staged
    log_data = load_log_data 

    prompt.say "These entries will be created upon push:\n\n"

    log_data.each_with_index do |record, i|
      prompt.say "  [#{i}] #{record["description"]} (#{record["hours"]} hrs)"
    end
  end
end
