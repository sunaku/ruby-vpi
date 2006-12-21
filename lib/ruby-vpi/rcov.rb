=begin
  Copyright (c) 2004-2006 Mauricio Fernandez <mfp@acm.org>
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

require 'rcov'

# satisfy dependencies of 'rcov/report'
  require 'xx'

  module XX
    module XMLish
      include Markup

      def xmlish_ *a, &b
        xx_which(XMLish){ xx_with_doc_in_effect(*a, &b)}
      end
    end
  end

  require 'cgi'

require 'rcov/report'


module RubyVpi
  COVERAGE_ANALYSIS = Rcov::CodeCoverageAnalyzer.new
  COVERAGE_ANALYSIS.install_hook

  COVERAGE_ANALYSIS_HANDLERS = []

  at_exit do
    COVERAGE_ANALYSIS.remove_hook

    COVERAGE_ANALYSIS_HANDLERS.each do |a|
      a.call COVERAGE_ANALYSIS
    end
  end

  # Invokes the given block after code coverage analysis has completed.
  def RubyVpi.with_coverage_analysis &aBlock # :yields: Rcov::CodeCoverageAnalyzer
    if aBlock
      COVERAGE_ANALYSIS_HANDLERS << aBlock
    end
  end
end
