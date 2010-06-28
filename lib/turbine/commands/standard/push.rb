Turbine::Application.extension do
  def push
    log_data = load_log_data

    log_data.each do |record|
      service["/time_entries"].post("time_entry" => record)
    end

    clear_log_data
  end
end
