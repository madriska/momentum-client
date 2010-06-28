Turbine::Application.extension do
  def add
    hours = params[:arguments].first

    queue = Turbine::Queue.new(self.class.config_dir)
    queue << hours
  end
end
