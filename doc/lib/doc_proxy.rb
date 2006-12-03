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

require 'erb_proxy'

# Processes ERB templates to produce documentation. Templates may contain "<xref...>" tags where the ... represents the target anchor of the cross-reference.
class DocProxy < ErbProxy
  Block = Struct.new :anchor, :title, :type
  Heading = Struct.new :anchor, :title, :depth

  attr_reader :blocks, :headings, :references

  def initialize
    super

    @blocks = Hash.new {|h,k| h[k] = []}
    @headings = []

    # admonitions
      [:tip, :note, :important, :caution, :warning].each do |type|
        add_block_handler :admonition, type do |index, title, text|
          join_redcloth_elements [
            %{!<images/#{type}.png(#{type})!},
            %{p(title). #{type.to_s.capitalize}: #{title}},
            text,
          ]
        end
      end

    # formal blocks; see http://www.sagehill.net/docbookxsl/FormalTitles.html
      [:figure, :table, :example, :equation, :procedure].each do |type|
        add_block_handler :formal, type do |index, title, text|
          join_redcloth_elements [
            %{p(title). #{type.to_s.capitalize} #{index}. #{title}},
            text,
          ]
        end
      end
  end

  # Post-processes the given ERB template result by parsing the document structure and expanding cross-references, and returns the result.
  def post_process! aResult
    buffer = aResult

    # parse document structure and insert anchors (so that the table of contents can link directly to these headings) where necessary
      buffer.gsub! %r{^(\s*h(\d))(\.|\(.*?\)\.)(.*)$} do
        target = $~.dup

        title = target[4].strip
        depth = target[2].to_i

        hasAnchor = target[3] =~ /#([^#]+)\)/
        anchor = $1 || "anchor#{headings.length}"


        @headings << Heading.new(anchor, title, depth)
        @blocks[:section] << Block.new(anchor, title, :section)


        if hasAnchor
          target.to_s
        else
          "#{target[1]}(##{anchor})#{target[3]}#{target[4]}"
        end
      end

    # expand cross-references into links to their targets
      blocks = @blocks.values.flatten

      buffer.gsub! %r{<xref\s*(.+?)\s*/?>} do
        anchor = unanchor($1)
        target = blocks.find {|b| b.anchor == anchor}

        if target
          %{"the #{target.type} named &ldquo;#{target.title}&rdquo;":##{target.anchor}}
        else
          warn "unresolved cross-reference to #{anchor}"
          %{"#{anchor}":##{anchor}}
        end
      end

    buffer
  end

  # Adds a block handler for the given type of block and outputs the result in a <div> whose CSS class is the given category.
  # The arguments for the block handler are:
  # 1. number of the block
  # 2. title of the block
  # 3. content of the block
  def add_block_handler aCategory, aType
    raise ArgumentError unless block_given?

    add_handler aType do |buf, text, title, anchor|
      index = @blocks[aType].length + 1

      unless anchor
        anchor = "#{aType}#{index}"
      end
      anchor = unanchor(anchor)

      @blocks[aType] << Block.new(anchor, title, aType)


      elts = [
        %{<div class="#{aCategory}">},
          %{<div class="#{aType}" id="#{anchor}">},
            yield(index, title, text),
          '</div>',
        '</div>',
      ]

      text = join_redcloth_elements(elts)
      buf << text
    end
  end

  private

  # Joins the given elements by putting enough white-space between them so that RedCloth knows they're different elements.
  def join_redcloth_elements *args
    args.join "\n\n\n"
  end

  # Removes the # from a HTML anchor so that only its name is preserved.
  def unanchor aAnchor
    aAnchor.sub(/^#+/, '')
  end
end
