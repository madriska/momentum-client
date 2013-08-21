require 'tempfile'
require 'shellwords'

Turbine::Application.extension do
  def commit
    message = params[:message] || message_from_editor

    if message && message != ""
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

  private

  # Private launch the default editor to capture a commit message
  #
  # Uses the environment variable +MM_EDITOR+ if present, otherwise falls back
  # to the default +EDITOR+ variable
  #
  # Returns text saved to the temp file
  def message_from_editor
    editor = ENV['MM_EDITOR'] || ENV['EDITOR']

    return unless editor

    Tempfile.open('commit.txt') do |file|
      editor_invocation = "#{editor} #{file.path}"
      system(*Shellwords.split(editor_invocation))
      message = File.read(file.path)
    end
  end
end
