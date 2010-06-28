Turbine::Application.extension do
  def reset
    delete_file("queue")
  end
end
