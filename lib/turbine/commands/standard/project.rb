Turbine::Application.extension do

  def project
    _list_projects || _manage_projects
  end

  private

  def _list_projects
    return false unless params[:arguments].empty?

    prompt.say("\n")

    self.class.projects.each do |name, url|
      prompt.say(name == self.class.current_project ? "  > " : "    ")
      prompt.say("#{name} : #{url}")
    end

    true
  end

  def _manage_projects
    command, project, *args = *params[:arguments]        
    case command
    when "add"
      url = args.shift

      raise "Not enough arguments" unless url

      prompt.say "adding project: #{project}"
      projects = self.class.projects
      write_file("projects.json") do |f|
        f << projects.merge(project => url).to_json
      end
    when "rm"
      projects = self.class.projects

      unless projects.keys.include?(project)
        prompt.say("No such project: #{project}")
        return
      end

      prompt.say "removing project: #{project}"

      projects.delete(project)

      write_file("projects.json") do |f|
        f << projects.to_json
      end
    when "select"
      projects = self.class.projects

      unless projects.keys.include?(project)
        prompt.say("No such project: #{project}")
        return
      end

      prompt.say "selecting project: #{project}" 

      self.class.current_project = project
    else
      prompt.say "Unknown command: project #{command}"
    end
  end

end
