require 'yaml'
@history = YAML.load_file(File.join(File.dirname(__FILE__), 'history.yml'))

def format_history_entry aEntry
  output = "h1. Version #{aEntry['Version']} (#{aEntry['Date']})\n\n"

  %w[Summary Acknowledgment Notice Detail].each do |key|
    if content = aEntry[key]
      output << "h2. #{key}\n\n#{content}\n\n"
    end
  end

  output
end
