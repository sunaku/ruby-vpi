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
    <link rel="stylesheet" type="text/css" href="common.css" media="screen" />
    <link rel="stylesheet" type="text/css" href="print.css" media="print" />
    <link rel="alternate" type="application/rss+xml" href="<%= RSS_URL %>" title="<%= RSS_INFO %>" />
    <title><%= page_title %></title>
  </head>
  <body>
  <% if table_of_contents %>
    <h1 style="margin-top: 0"><%= page_title %></h1>

    <%= %{p=. !images/tango/home.png(Return to main page)!:readme.html}.redcloth %>

    <div id="menu">
      <%=
        links = @indexes.values.flatten.map do |i|
          %{<a href="##{i.name.downcase}">#{i.name}</a>}
        end
        links.unshift %{<a href="#index">Contents</a>}

        links.join ' &middot; '
      %>
    </div>

    <div id="index">
      <h1>Contents</h1>
      <%=
        @headings.map do |h|
          %{#{'*' * h.depth} #{h.index} "#{h.title}":##{h.anchor}}
        end.join("\n").redcloth
      %>

      <% @indexes.each_pair do |cat, lists| %>
        <h1><%= cat %></h1>

        <% lists.each do |list| %>
          <h2 id="<%= list.name.downcase %>"><%= list.name %></h2>
          <%=
            list.items.inject('') do |memo, block|
              memo << "# #{(block.title || block.anchor).inspect}:##{block.anchor}\n"
            end.redcloth
          %>
        <% end %>
      <% end %>
    </div>
  <% end %>
    <%= content.to_html %>
  </body>
</html>
