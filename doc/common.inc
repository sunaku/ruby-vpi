<%
  unindent '  ' # 2 spaces

  history = YAML.load_file('history.yaml')
  version = history.first['Version']

  downloadURL = 'http://rubyforge.org/frs/?group_id=1339'
  forumURL    = 'http://rubyforge.org/forum/?group_id=1339'
  trackerURL  = 'http://rubyforge.org/tracker/?group_id=1339'
  portalURL   = 'http://rubyforge.org/projects/ruby-vpi/'
  codeURL     = 'http://ruby-vpi.rubyforge.org/src/ruby-vpi/'
  projectURL  = 'http://ruby-vpi.rubyforge.org/'
%>