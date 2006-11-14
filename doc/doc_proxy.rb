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

# ERB proxy used to evaluate all documentation ERB templates.
class DocProxy < ErbProxy
  Block = Struct.new :anchor, :title, :type
  Heading = Struct.new :anchor, :title, :depth
  Reference = Struct.new :target, :position

  attr_reader :blocks, :headings, :references

  def initialize *aArgs
    super
    @blocks = Hash.new {|h,k| h[k] = []}
    @references = []

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

    # references
      add_handler :xref do |aBuf, aText, aTarget|
        @references << Reference.new(unanchor(aTarget), aBuf.length)
        nil
      end

    # footnotes
  end

  alias orig_result result

  def result *aArgs
    orig_result *aArgs

    # expand cross references (xref) into links to their targets
      unless @references.empty?
        # resolve the targets of the xrefs
          blocks = @blocks.values.flatten

          targets = @references.map do |ref|
            blocks.find {|b| b.anchor == ref.target}
          end

        # expand the xrefs in-place within the buffer
          @references.map {|ref| ref.position}.inject(0) do |memo, pos|
            if t = targets.shift
              link = %{"the #{t.type} named &ldquo;#{t.title}&rdquo;":##{t.anchor}}
            else
              xref = @references[-targets.length.next]
              link = %{"#{xref.target}":##{xref.target}}

              warn "unresolved cross-reference to #{xref.target.inspect}"
            end

            @buffer.insert memo + pos, link
            memo += link.length
          end
      end

    # parse document structure and insert anchors where necessary
      @headings = []

      @buffer.gsub! /^(\s*h(\d))(\.|\(.*?\)\.)(.*)$/ do
        target = $~.dup

        hasAnchor = target[3] =~ /#([^#]+)\)/
        anchor = $1 || "anchor#{headings.length}"

        @headings << Heading.new(anchor, target[4].strip, target[2].to_i)

        if hasAnchor
          target.to_s
        else
          "#{target[1]}(##{anchor})#{target[3]}#{target[4]}"
        end
      end

    @buffer
  end

  private

  # The category eases the task of customizing each type's appearance via CSS.
  # This method must return the result of the handling of the input text.
  def add_block_handler aCategory, aType
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
      text
    end
  end

  def join_redcloth_elements *args
    args.join("\n\n\n")
  end

  def unanchor aAnchor
    aAnchor.sub /^#+/, ''
  end
end
