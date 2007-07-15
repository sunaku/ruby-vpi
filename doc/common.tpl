<%
  require 'doc_format'

  # set default page title if none was given
  unless page_title
    if h = @boxes[:section].first
      page_title = h.title
    end
  end

  Listing = Struct.new(:name, :anchor, :key)

  listings = (@boxes.keys - [:section]).map do |key|
    Listing.new(key.to_s.capitalize << 's', key.to_s.to_html_anchor, key)
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

      <%
        links = listings.map do |x|
          %{<a href="##{x.anchor}">#{x.name}</a>}
        end
        links.unshift %{<a href="#toc-real">Contents</a>}
      %>
      <ul>
      <% links.each do |link| %>
        <li><%= link %></li>
      <% end %>
      </ul>

      <h1 id="toc-real">Contents</h1>
      <%= toc %>

      <% listings.each do |x| %>
        <h1 id="<%= x.anchor %>"><%= x.name %></h1>
        <ol>
        <% @boxes[x.key].map do |box| %>
          <%= %{<li><a href="##{box.anchor}">#{box.title.to_html}</a></li>} %>
        <% end %>
        </ol>
      <% end %>
    </div>
  <% end %>
    <%= content %>
  </body>
</html>
