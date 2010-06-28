Turbine::Application.extension do
  def drop
    log_data = load_log_data

    log_data.delete_at(params[:arguments].first.to_i)

    write_file("log/#{self.class.api_key}.json") { |f| f << log_data.to_json }
  end
end
