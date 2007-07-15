#--
# Copyright 2006 Suraj N. Kurapati
# See the file named LICENSE for details.

require 'erb_proxy'
require 'doc_format'
require 'digest/md5'

# Processes ERB templates to produce documentation.
# Templates may contain "<xref...>" tags where the ...
# represents the target anchor of the cross-reference.
class DocProxy < ErbProxy
  Box = Struct.new(:type, :anchor, :index, :title, :id)
  Ref = Struct.new(:anchor, :name)

  BOX_TYPES = {
    :admonition => [:tip, :note, :important, :caution, :warning],

    # see http://www.sagehill.net/docbookxsl/FormalTitles.html
    :formal => [:figure, :table, :example, :equation, :procedure],
  }

  def initialize
    super

    @bib   = []
    @boxes = Hash.new {|h,k| h[k] = []}
    @mask  = Hash.new do |h,k|
      d    = Digest::MD5.hexdigest(k)
      h[d] = k
      d
    end
    @lazyHandlers = {}

    type = :admonition
    BOX_TYPES[type].each do |name|
      add_box_handler(type, name) do |content, box, *args|
        [
          %{<img src="images/tango/#{name}.png" alt="#{name}"/>},
          %{<p class="title">#{name.to_s.capitalize}: #{box.title.to_html}</p>},
          content.to_html,
        ].join
      end
    end

    type = :formal
    BOX_TYPES[type].each do |name|
      add_box_handler(type, name) do |content, box, *args|
        [
          %{<p class="title">#{name.to_s.capitalize} #{box.index}. #{box.title.to_html}</p>},
          content.to_html,
        ].join
      end
    end

    # bibliography items
    add_handler :reference do |buffer, content, name|
      anchor = name.to_html_anchor
      @bib << Ref.new(anchor, name)

      buffer << @mask[
        [
          %{<div id="#{anchor}">},
            %{|_. #{name}|#{content}|}.to_html,
          '</div>',
        ].join
      ]
    end

    # bibliography citations
    add_lazy_handler :cite do |aTarget|
      target = @bib.find {|item| item.name == aTarget}

      if target
        %{[<a href="##{target.anchor}">#{target.name.to_html}</a>]}
      else
        warn "unresolved cross-reference to bibliography item: #{name}"
      end
    end

    # cross references
    add_lazy_handler :xref do |aTarget|
      target = @boxes.values.flatten.find {|b| b.id == aTarget} ||
               @boxes[:section].find {|b| b.anchor == aTarget}

      if target
        %{<a href="##{target.anchor}">the #{target.type} named &ldquo;#{target.title.to_html}&rdquo;</a>}
      else
        warn "unresolved cross-reference to id: #{aTarget}"
      end
    end
  end

  # Post-processes the given ERB template result by parsing the document
  # structure and expanding cross-references, and returns the result.
  def post_process aResult
    text = aResult.to_html

    @mask.each_pair do |src, dst|
      text.gsub! src, dst
    end

    # parse document structure and insert anchors (so that the table
    # of contents can link directly to these headings) where necessary
    toc, text = text.table_of_contents do |title, anchor, index, depth, atts|
      @boxes[:section] << Box.new(:section, anchor, index, title)
    end

    # expand cross-references into links to their targets
    @lazyHandlers.each_pair do |token, (handler, args)|
      text.gsub! token, handler.call(*args)
    end

    [toc, text]
  end

  # Adds a block handler for the given type of
  # block and outputs the result in a <div>
  # whose CSS class is the given category.
  # The arguments for the block handler are:
  #
  # 1. number of the block
  #
  # 2. title of the block
  #
  # 3. content of the block
  #
  def add_box_handler aType, aName
    raise ArgumentError unless block_given?

    add_handler aName do |buffer, content, title, id, *args|
      index = @boxes[aName].length + 1
      anchor = (id || "#{aName}:#{title}").to_html_anchor

      box = Box.new(aName, anchor, index, title, id)
      @boxes[aName] << box

      buffer << @mask[
        [
          %{<div class="#{aType}">},
            %{<div class="#{aName}" id="#{anchor}">},
              yield(content, box, *args),
            '</div>',
          '</div>',
        ].join
      ]
    end
  end

  def add_lazy_handler aName, &aHandler
    (class << self; self; end).instance_eval do
      define_method aName do |*args|
        token = Digest::MD5.hexdigest("#{aName}#{args.object_id}")
        @lazyHandlers[token] = [aHandler, args]
        token
      end
    end
  end
end
