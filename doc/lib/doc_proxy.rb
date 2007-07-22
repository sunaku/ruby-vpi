#--
# Copyright 2006 Suraj N. Kurapati
# See the file named LICENSE for details.

$: << File.basename(__FILE__)
require 'erb_proxy'
require 'doc_format'

require 'digest/md5'
require 'ostruct'
require 'pp'

class String
  def digest
    Digest::MD5.hexdigest self
  end
end

# Processes ERB templates to produce documentation.
# Templates may contain "<xref...>" tags where the ...
# represents the target anchor of the cross-reference.
class DocProxy < ErbProxy
  Box = Struct.new(:type, :anchor, :index, :title, :id)
  BibItem = Struct.new(:anchor, :name)
  FootNote = Struct.new(:anchor, :name)

  GROUP2TYPES = {
    :admonition => [:tip, :note, :important, :caution, :warning],

    # see http://www.sagehill.net/docbookxsl/FormalTitles.html
    :formal => [:figure, :table, :example, :equation, :procedure],

    :latex => [:part, :chapter, :section, :paragraph],
  }

  attr_reader :nodeTree, :references

  def initialize
    super

    @boxCipher = Cipher.new
    @references = []
    @boxes = Hash.new {|h,k| h[k] = []}
    @lazyHandlers = {}


    # node hierarcy

    @nodeTree = NodeTree.new

    GROUP2TYPES.each_pair do |group, types|
      next if group == :latex

      types.each do |type|
        add_node_handler group, type do |node, content, *args|
          %{
            <hr style="display: none"/>

            <div class="#{group}">
              <div class="#{type}" id="#{node.anchor}">
                #{
                  if group == :admonition
                    %{<img src="images/tango/#{type}.png" alt="#{type}" class="icon"/>}
                  end
                }

                <p class="title"><a href="##{node.tocAnchor}">#{type.to_s.capitalize} #{node.number}</a>. &nbsp; #{node.title.to_html}</p>

                #{content.to_html}
              </div>
            </div>
          }
        end
      end
    end

    add_node_handler :latex, :front_cover do |node, content, *args|
      %{
        <hr style="display: none"/>

        <div id="#{node.anchor}" class="front_cover">
          <h1 class="title"><big>#{node.title.to_html}</big></h1>

          #{content.to_html}

        </div>
      }
    end

    add_node_handler :latex, :part do |node, content, *args|
      %{
        <hr style="display: none"/>

        <div id="#{node.anchor}" class="part">
          <h1 class="title">
            Part <a href="##{node.tocAnchor}">#{node.number}</a>

            <br/><br/>

            <big>#{node.title.to_html}</big>
          </h1>

          #{content.to_html}

        </div>
      }
    end

    add_node_handler :latex, :chapter do |node, content, *args|
      %{
        <hr style="display: none"/>

        <div id="#{node.anchor}" class="chapter">
          <h1 class="title">
            Chapter <a href="##{node.tocAnchor}">#{node.latexNumber}</a>

            <br/><br/>

            <big>#{node.title}</big>
          </h1>

          #{content.to_html}
        </div>
      }
    end

    add_node_handler :latex, :section do |node, content, *args|
      level = [node.depth, 6].min

      %{
        <hr style="display: none"/>

        <div id="#{node.anchor}" class="section">
          <h#{level} class="title">
            <a href="##{node.tocAnchor}">#{node.latexNumber}</a>

            &nbsp;

            #{node.title.to_html}
          </h#{level}>

          #{content.to_html}

        </div>
      }
    end

    add_node_handler :latex, :paragraph do |node, content, *args|
      %{
        <div id="#{node.anchor}" class="paragraph">
          <p class="title">#{node.title.to_html}</p>
          #{content.to_html}
        </div>
      }
    end


    @bibCipher = Cipher.new

    # bibliography items
    add_node_handler :index, :reference do |node, content, *args|
      %{
        <div id="#{node.anchor}" class="reference">
          <table>
            <tr>
              <th>[#{node.number}]</th>
              <td>#{content.to_html}</td>
            </tr>
          </table>
        </div>
      }
    end

    # bibliography items
    add_handler :footnote do |caller, buffer, content, name|
      anchor = "ref:#{name}".to_html_anchor
      index  = @footnotes.length
      @footnotes << FootNote.new(anchor, name)

      buffer << @bibCipher.encrypt(
        [
          %{<div id="#{anchor}">},
            %{|_. [#{index}]|#{content}|}.to_html,
          '</div>',
        ].join
      )
    end

    # bibliography citations
    add_lazy_handler :cite do |target, *args|
      node = @nodeTree.type2nodes[:reference].find {|n| n.id == target}

      if node
        words = [
          %{<a href="##{node.anchor}">Reference #{node.number}</a>},

          # extra information about the citation (page #, etc.)
          *args.map {|s| s.to_html}
        ]

        "(see #{ words.join(', ') })"
      else
        warn "invalid cite to #{target.inspect}"
        ''
      end
    end

    # cross references
    add_lazy_handler :xref do |aTarget, aTitle|
      nodes  = @nodeTree.nodes
      target = nodes.find {|n| n.id == aTarget} || # id has first priority
               nodes.find {|n| n.anchor == aTarget}

      if target
        title = aTitle || "#{target.type.to_s.capitalize} #{target.latexNumber || target.number}"
        %{<a href="##{target.anchor}">#{title.to_html}</a>}
      else
        warn "invalid xref to #{aTarget.inspect}"
        ''
      end
    end
  end

  def add_lazy_handler aHandlerName, &aHandler
    (class << self; self; end).instance_eval do
      define_method aHandlerName do |*args|
        token = "#{aHandlerName}#{args.object_id}".digest
        @lazyHandlers[token] = [aHandler, args]
        token
      end
    end
  end

  # aNodeType:: name of the command that will trigger the handler
  # aNodeHandler:: handler that will be triggered by the given command
  def add_node_handler aNodeGroup, aNodeType, &aNodeHandler #:yields: node, content, *args
    raise ArgumentError unless block_given?

    if @nodeTree.handlers.key? aNodeType
      raise "node handler #{aNodeType.inspect} already exists"
    end
    @nodeTree.handlers[aNodeType] = aNodeHandler


    add_handler aNodeType do |caller, buffer, content, nodeInfo, *args|
      if @nodeTree.caller2node.key? caller
        node = @nodeTree.caller2node[caller]

        # collect tree traversal information
        node.timesSeen += 1

      else # first time we are handling this node

        # parse the arguments given to this handler
        if nodeInfo.respond_to? :to_hash
          nodeInfo = nodeInfo.to_hash
          raise ArgumentError unless nodeInfo.key? :title
        else
          nodeInfo = {:title => nodeInfo.to_s, :id => args.shift}
        end

        # register this node as having been seen
        node = Node.new nodeInfo.merge(
          # node info
          :caller       => caller,
          :type         => aNodeType,
          :group        => aNodeGroup,
          :args         => args,

          # content info
          :content      => content,
          :digest       => content.digest,
          :leadingSpace => (buffer =~ /([ \t]*)\Z/ && $1),

          # traversal info
          :orderSeen    => @nodeTree.caller2node.keys.length,
          :timesSeen    => 1
        )
        @nodeTree.caller2node[caller] = node
      end

      buffer << node.digest
    end
  end

  # Post-processes the given ERB template result by parsing the document
  # structure and expanding cross-references, and returns the result.
  def post_process aResult
    text = aResult


    # build the node tree
    @nodeTree.build!
    toc = @nodeTree.table_of_contents


    # convert to HTML
    File.open('text', 'w') {|f| f << text} if $DEBUG
    html = text.to_html
    File.open('html', 'w') {|f| f << html} if $DEBUG


    @nodeTree.process_input! html, @innerSpace

    # expand cross-references into links to their targets
    @lazyHandlers.each_pair do |token, (handler, args)|
      html.gsub! token, handler.call(*args)
    end

    # expand all citations
    # html = @bibCipher.decrypt_all(html)


    [toc, html]
  end


  ##-----------------------------------------------------------------------
  # user API

  # Unindents the inner space by the given amount.
  def unindent aInnerSpace
    @innerSpace = aInnerSpace
  end

  #-----------------------------------------------------------------------

  private

  def expand_includes aFilePath
    input = File.read(aFilePath)

    input.gsub! %r{<doc_proxy_include *(.*?)>} do
      expand_includes($1)
    end

    input
  end

  #-----------------------------------------------------------------------

  class Node < OpenStruct
    undef id
    undef type
  end

  class Cipher < Hash
    def encrypt aString
      digest       = aString.digest
      self[digest] = aString
      digest
    end

    def decrypt digest
      self[digest]
    end

    # Iteratively decrypts all digest substrings within the given string.
    def decrypt_all aString
      temp = self.dup
      str  = aString.dup

      until temp.empty?
        cipher = temp.find do |(digest, original)|
          str.gsub! digest, original
        end

        raise unless cipher
        temp.delete cipher[0]
      end

      str
    end
  end

  class NodeTree < Hash
    attr_reader :caller2node, :group2nodes, :type2nodes, :cipher, :handlers

    def initialize
      @cipher      = Cipher.new
      @handlers    = {}
      @caller2node = {}
      @type2nodes  = Hash.new {|h,k| h[k] = []}
      @group2nodes = Hash.new {|h,k| h[k] = []}
    end

    def nodes
      @caller2node.values
    end

    # Evaluates the given string which contains node digests.
    def process_input! aString, aInnerSpace = nil
      list = nodes

      # let handlers modify node content
      list.each do |node|
        src = node.content
        dst = @handlers[node.type].call(node, src, *node.args)

        if aInnerSpace
          space = node.leadingSpace + aInnerSpace

          # add leading space if not present. this will ensure that
          # lines without any leading space are correctly unindented
          dst.gsub! %r/^[ \t]*/ do
            if $&.index(space) == 0
              $&
            else
              space + $&
            end
          end

          # remove leading space
          dst.gsub! %r/^#{space}/, ''
        end

        # XXX: escape single backslashes because they
        #      are removed later on for some reason...
        dst.gsub! %r/\\/, '\&\&'

        node.content = dst
      end

      # replace all node digests with node content
      until list.empty?
        target = list.find do |node|
          aString.gsub! node.digest, node.content
        end

        raise unless target
        list.delete target
      end
    end

    # Builds this tree from traversal information.
    def build!
      # build the tree
      self.clear
      children = []
      lastDepth = 0

      nodes.sort_by {|n| n.orderSeen}.each do |node|
        currDepth = node.timesSeen

        # register this node into adjacency list
        self[node] = [] unless self.key? node

        if lastDepth > currDepth
          subnodes = children.select {|n| n.timesSeen > currDepth}
          self[node].concat subnodes
          children = children - subnodes
        end

        children << node
        lastDepth = currDepth
      end

      if $DEBUG
        nodes.each do |node|
          def node.inspect
            title.inspect
          end
        end
        pp self
      end


      # set depths of all nodes starting from root-level nodes
      rootNodes = self.keys - self.values.flatten.uniq
      rootNodes.sort_by {|n| n.orderSeen}.each do |node|
        set_depth node, 1
      end


      # fill information for later stages
      idUsage = Hash.new {|h,k| h[k] = []}

      nodes.each do |node|
        node.id ||= node.title
        idUsage[node.id] << node

        # forward and reverse anchors from & back to TOC
        node.anchor    = node.id.to_html_anchor
        node.tocAnchor = node.object_id.to_s.to_html_anchor
      end

      idUsage.select {|(k,v)| v.length > 1}.each do |id, nodes|
        warn "#{nodes.length} nodes have the same identifier: #{id.inspect}"
      end
    end

    def table_of_contents
      toc = '<ul>'
      prevDepth = 0
      prevIndex = ''

      @group2nodes[:latex].each do |node|
        # generate a LaTeX-style index (section number) for the heading
        depthDiff = (node.depth - prevDepth).abs

        node.latexNumber =
          if node.depth > prevDepth
            toc << '<li><ul>' * depthDiff

            s = prevIndex + ('.1' * depthDiff)
            s.sub(/^\./, '')

          elsif node.depth < prevDepth
            toc << '</ul></li>' * depthDiff

            s = prevIndex.sub(/(\.\d+){#{depthDiff}}$/, '')
            s.next

          else
            prevIndex.next
          end

        prevDepth = node.depth
        prevIndex = node.latexNumber


        # generate hyperlink for traveling from TOC to heading
        toc << %{<li><span class="hide">#{node.latexNumber} </span><a id="#{node.tocAnchor}" href="##{node.anchor}">#{node.title.to_html}</a></li>}
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

      toc
    end

    private

    # recursively sets the depth of the given
    # node and performs linear node numbering
    def set_depth aNode, aDepth
      aNode.depth = aDepth

      # set number for boxes (fig 1, fig 2, etc.)
      ary = @type2nodes[aNode.type]
      ary << aNode
      aNode.number = ary.length
      @group2nodes[aNode.group] << aNode

      self[aNode].each do |child|
        set_depth child, aDepth + 1
      end
    end
  end
end
