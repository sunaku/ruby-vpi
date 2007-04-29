=begin
  Copyright 2006 Suraj N. Kurapati

  This file is part of Ruby-VPI.

  Ruby-VPI is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License
  as published by the Free Software Foundation; either version 2
  of the License, or (at your option) any later version.

  Ruby-VPI is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with Ruby-VPI; if not, write to the Free Software Foundation,
  Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
=end

require 'cgi'
require 'rubygems'
require 'coderay'
require 'redcloth'

class String
  # The content of these HTML tags will be preserved verbatim when they are
  # processed by Textile.
  PRESERVED_TAGS = [:code, :tt]

  # Transforms this string into HTML.
  def to_html
    text = dup

    # prevent the content of these tags from being transformed by Textile.
    # for example, Textile transforms quotation marks in code into curly ones
    # (&#8192;) -- this ruins any source code in the content of the tags!
      PRESERVED_TAGS.each do |tag|
        text.gsub! \
          %r{<#{tag}(.*?)>(.*?)</#{tag}>}m,
          %{<pre tag=#{tag.inspect}\\1>\\2</pre>}
      end

    html = text.redcloth

    # redcloth wraps a single item within paragraph tags, which prevents the
    # item's HTML from being validly injected within other block-level
    # elements, such as headings (h1, h2, etc.)
    html.sub! %r{^<p>(.*)</p>$}m do |match|
      payload = $1

      if payload =~ /<p>/
        match
      else
        payload
      end
    end

    # restore the original tags for the preserved tags
      # unescape content of <pre> tags because they may contain nested
      # preserved tags (redcloth escapes the content of <pre> tags)
        html.gsub! %r{(<pre>)(.*?)(</pre>)}m do
          $1 + CGI.unescapeHTML($2) + $3
        end

      PRESERVED_TAGS.each do |tag|
        html.gsub! \
          %r{<pre tag=#{tag.inspect}(.*?)>(.*?)</pre>}m,
          %{<#{tag}\\1>\\2</#{tag}>}
      end

      # assume that indented text in Textile is NOT source code
        html.gsub! %r{(<pre>)\s*<code>(.*?)\s*</code>\s*(</pre>)}m, '\1\2\3'

      # escape content of <pre> tags, because we un-escaped it above
        html.gsub! %r{(<pre>)(.*?)(</pre>)}m do
          $1 + CGI.escapeHTML($2) + $3
        end

    html.coderay
  end

  # Returns the result of running this string through RedCloth.
  def redcloth
    RedCloth.new(self).to_html
  end

  # Adds syntax coloring to <code> elements in the given text. If the <code>
  # tag has an attribute lang="...", then that is considered the programming
  # language for which appropriate syntax coloring should be applied.
  # Otherwise, the programming language is assumed to be ruby.
  def coderay
    gsub %r{<(code)(.*?)>(.*?)</\1>}m do
      code = CGI.unescapeHTML $3
      atts = $2

      lang =
        if $2 =~ /lang=('|")(.*?)\1/i
          $2
        else
          :ruby
        end

      tag =
        if code =~ /\n/
          :pre
        else
          :code
        end

      html = CodeRay.scan(code, lang).html(:css => :style)

      %{<#{tag} class="code"#{atts}>#{html}</#{tag}>}
    end
  end
end
