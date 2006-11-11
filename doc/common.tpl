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
    <div id="toc">
      <%= toc.redcloth %>
    </div>

    <%= text.to_html %>
<% else %>
    <%= content.to_html %>
<% end %>
  </body>
</html>
