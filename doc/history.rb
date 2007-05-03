require 'yaml'

@history = YAML.load_file(File.join(File.dirname(__FILE__), 'history.yaml')).each do |entry|
  class << entry
    def to_s
      %{<h1 id="#{self['Version']}">Version #{self['Version']} (#{self['Date']})</h1>\n\n#{self['Record']}}
    end

    def to_html
      to_s.to_html
    end
  end
end
