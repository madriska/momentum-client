Turbine::Application.extension do
  def rewind
    delete_file("timestamp")
  end
end
