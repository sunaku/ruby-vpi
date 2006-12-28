require 'yaml'
@history = YAML.load_file(File.join(File.dirname(__FILE__), 'history.yml'))

# note: @history is an array of hashes


def format_history_entry aEntry
  output = "h1(##{aEntry['Version']}). Version #{aEntry['Version']} (#{aEntry['Date']})\n\n"

  %w[Summary Acknowledgment Notice Details].each do |key|
    if content = aEntry[key]
      output << "h2. #{key}\n\n#{content}\n\n"
    end
  end

  output
end
