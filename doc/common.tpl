<%
  require 'doc_format'

  # set default page title if none was given
  unless page_title
    if h = @nodeTree.group2nodes[:latex].first
      page_title = h.title
    end
  end

  Listing = Struct.new(:name, :anchor, :key, :nodes) unless defined? Listing

  listings = (
    DocProxy::GROUP2TYPES[:admonition] +
    DocProxy::GROUP2TYPES[:formal]
  ).flatten.inject([]) do |ary, key|
    nodes = @nodeTree.type2nodes[key]

    unless nodes.empty?
      ary << Listing.new(key.to_s.capitalize << 's', "toc:#{key}".to_html_anchor, key, nodes)
    end

    ary
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
    <div id="menu">
      <h1>Site navigation</h1>
      <ul id="site-links">
        <li><a href="readme.html">Home</a></li>
        <%
          Dir['*.doc'].each do |src|
            name, ext = src.split('.', 2)
            next if name == 'readme'
        %>
          <li><a href="<%= name %>.html"><%= name.capitalize %></a></li>
        <% end %>
      </ul>

      <% if insert_toc %>
        <%
          links = listings.map do |x|
            %{<a href="##{x.anchor}">#{x.name}</a>}
          end

          unless links.empty?
        %>
        <h1>Menu navigation</h1>
        <ul id="toc-links">
          <%=
            links.unshift %{<a href="#toc-contents">Contents</a>}
            links.map {|x| "<li>#{x}</li>"}.join
          %>
        </ul>
        <% end %>

        <div id="toc">
          <h1 id="toc-contents">Contents</h1>
          <%= toc %>

          <% listings.each do |x| %>
            <h1 id="<%= x.anchor %>"><%= x.name %></h1>
            <ol>
            <% x.nodes.map do |node| %>
              <%= %{<li><a href="##{node.anchor}" id="#{node.tocAnchor}">#{node.title.to_html}</a></li>} %>
            <% end %>
            </ol>
          <% end %>
        </div>
      <% end %>
    </div>

    <div id="body">
      <%= content %>
      <br/>
      <hr/>
      This website is maintained by Suraj N. Kurapati (SNK at GNA dot ORG). It was last updated on <%= Time.now %>.
    </div>
  </body>
</html>
