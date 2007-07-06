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
  <% if insert_toc %>
    <div id="toc">
      <%= 'p=. !images/tango/home.png(Return to main page)!:readme.html'.redcloth %>

      <ul>
      <%
        links = @indexes.values.flatten.map do |i|
          %{<a href="##{i.name.downcase}">#{i.name}</a>}
        end
        links.unshift %{<a href="#toc-real">Contents</a>}

        links.each do |link|
      %>
        <li><%= link %></li>
      <% end %>
      </ul>

      <h1 id="toc-real">Contents</h1>
      <%= toc %>

      <% @indexes.each_pair do |cat, lists| %>
        <% lists.each do |list| %>
          <h1 id="<%= list.name.downcase %>"><%= list.name %></h1>
          <%=
            list.items.inject('') do |memo, block|
              memo << "# #{(block.title || block.anchor).inspect}:##{block.anchor}\n"
            end.redcloth
          %>
        <% end %>
      <% end %>
    </div>
  <% end %>
    <%= content %>
  </body>
</html>
