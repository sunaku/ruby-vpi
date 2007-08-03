<%
  unindent '  ' # 2 spaces

  history = YAML.load_file('history.yaml')
  version = history.first['Version']

  projectURL  = 'http://ruby-vpi.rubyforge.org/'
  downloadURL = projectURL + 'download/'
  forumURL    = projectURL + 'forum/'
  mailListURL = projectURL + 'mail/'
  trackerURL  = projectURL + 'tracker/'
  portalURL   = projectURL + 'portal/'
  codeURL     = projectURL + 'code/'
%>
