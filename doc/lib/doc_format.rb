#--
# Copyright 2006-2007 Suraj N. Kurapati
# See the file named LICENSE for details.

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


  # Transforms this string into a valid XHTML anchor (ID attribute).
  # See http://www.nmt.edu/tcc/help/pubs/xhtml/id-type.html
  def to_html_anchor
    # The first or only character must be a letter.
      buf =
        if self[0,1] =~ /[[:alpha:]]/
          self
        else
          'a' + self
        end

    # The remaining characters must be letters, digits, hyphens (-),
    # underscores (_), colons (:), or periods (.) [or Unicode characters]
      buf.unpack('U*').map! do |code|
        if code > 0xFF or code.chr =~ /[[:alnum:]\-_:\.]/
          code
        else
          ?_
        end
      end.pack('U*')
  end

  @@anchors = []

  # Resets the list of anchors encountered thus far.
  def String.reset_anchors
    @@anchors.clear
  end

  # Builds a table of contents from XHTML headings (<h1>, <h2>, etc.) found
  # in this string and returns an array containing [toc, text] where:
  #
  # toc::   the generated table of contents
  #
  # text::  a modified version of this string which contains anchors for the
  #         hyperlinks in the table of contents (so that the TOC can link to
  #         the content in this string)
  #
  # If a block is given, it will be invoked every time a heading is found, with
  # information about the found heading.
  #
  def table_of_contents
    toc = '<ul>'
    prevDepth = 0
    prevIndex = ''

    text = gsub %r{<h(\d)(.*?)>(.*?)</h\1>$}m do
      depth, atts, title = $1.to_i, $2, $3.strip

      # generate a LaTeX-style index (section number) for the heading
        depthDiff = (depth - prevDepth).abs

        index =
          if depth > prevDepth
            toc << '<li><ul>' * depthDiff

            s = prevIndex + ('.1' * depthDiff)
            s.sub(/^\./, '')

          elsif depth < prevDepth
            toc << '</ul></li>' * depthDiff

            s = prevIndex.sub(/(\.\d+){#{depthDiff}}$/, '')
            s.next

          else
            prevIndex.next

          end

        prevDepth = depth
        prevIndex = index

      # generate a unique HTML anchor for the heading
        anchor = CGI.unescape(
          if atts =~ /id=('|")(.*?)\1/
            atts = $` + $'
            $2
          else
            title
          end
        ).to_html_anchor

        anchor << anchor.object_id.to_s while @@anchors.include? anchor
        @@anchors << anchor

      yield title, anchor, index, depth, atts if block_given?

      # provide hyperlinks for traveling between TOC and heading
        dst = anchor
        src = dst.object_id.to_s.to_html_anchor

        # forward link from TOC to heading
        toc << %{<li><a id="#{src}" href="##{dst}">#{title}</a></li>}

        # reverse link from heading to TOC
        %{<h#{depth}#{atts}><a id="#{dst}" href="##{src}">#{index}</a> &nbsp; #{title}</h#{depth}>}
    end

    if prevIndex.empty?
      toc = nil # there were no headings
    else
      toc << '</ul></li>' * prevDepth
      toc << '</ul>'

      # collapse redundant list elements
      while toc.gsub! %r{(<li>.*?)</li><li>(<ul>)}, '\1\2'
      end

      # collapse unnecessary levels
      while toc.gsub! %r{(<ul>)<li><ul>(.*)</ul></li>(</ul>)}, '\1\2\3'
      end
    end

    [toc, text]
  end
end
