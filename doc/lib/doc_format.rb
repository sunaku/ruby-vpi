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
  # Returns the result of running this string through RedCloth.
  def redcloth
    RedCloth.new(self).to_html
  end

  # Adds syntax coloring to <code>...</code> elements in the given text. If the <code> tag has an attribute lang="...", then that is considered the programming language for which appropriate syntax coloring should be applied. Otherwise, the programming language is assumed to be ruby.
  def coderay
    gsub %r{<(code)(.*?)>(.*?)</\1>}m do
      code = $3.unescape_html
      atts = $2
      lang =
        if $2 =~ /lang=('|")(.*?)\1/i
          $2
        else
          :ruby
        end


      type =
        if code =~ /\n/
          :pre
        else
          :code
        end

      html = CodeRay.scan(code, lang).html(:css => :style)

      %{<#{type} class="code"#{atts}>#{html}</#{type}>}
    end
  end

  def to_html
    redcloth.coderay
  end

  def escape_html
    CGI.escapeHTML self
  end

  def unescape_html
    CGI.unescapeHTML self
  end
end

