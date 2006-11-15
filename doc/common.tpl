<%
  require 'doc_format'

  # set default page title if none was given
    unless page_title
      if h = @headings.first
        page_title = h.title
      end
    end
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
    <link rel="stylesheet" type="text/css" href="common.css" />
    <title><%= page_title %></title>
  </head>
  <body>
<% if table_of_contents %>
    <div id="navigation">
      <%= %{"!images/home.png(project home)!":readme.html}.redcloth %>

      <h1>Contents</h1>
      <%=
        @headings.map do |h|
          %{#{'*' * h.depth} "#{h.title}":##{h.anchor}}
        end.join("\n").redcloth
      %>
<%
    @blocks.keys.sort_by {|k| k.to_s}.each do |type|
      list = @blocks[type]

      unless list.empty?
%>
      <h2><%= type.to_s.capitalize %>s</h2>
<%=
      list.inject('') do |memo, block|
        memo << "# #{(block.title || block.anchor).inspect}:##{block.anchor}\n"
      end.redcloth
%>
<%
    end
  end
%>
    </div>
<% end %>
    <%= content.to_html %>
  </body>
</html>
