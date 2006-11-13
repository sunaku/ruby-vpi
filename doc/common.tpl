<%
  unless @title
    if h = structure.first
      @title = h.title
    end
  end
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
    <link rel="stylesheet" type="text/css" href="common.css" />
    <title><%= @title %></title>
  </head>
  <body>
<% if @table_of_contents %>
    <div id="navigation">
      <h1>Table of contents</h1>
      <%= toc.redcloth %>
<%
  proxy.blocks.each_pair do |type, list|
    unless list.empty?
%>
      <h2>List of <%= type.to_s %>s</h2>
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

    <%= text.to_html %>
<% else %>
    <%= content.to_html %>
<% end %>
  </body>
</html>
