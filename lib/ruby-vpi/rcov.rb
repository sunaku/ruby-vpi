# Code coverage analysis.
#--
# Copyright 2006 Suraj N. Kurapati
# See the file named LICENSE for details.

require 'rcov'

# satisfy dependencies of 'rcov/report'
  require 'xx'

  module XX # :nodoc: all
    module XMLish
      include Markup

      def xmlish_ *a, &b
        xx_which(XMLish){ xx_with_doc_in_effect(*a, &b)}
      end
    end
  end

  require 'cgi'

require 'rcov/report'


module RubyVPI
  COVERAGE_ANALYSIS = Rcov::CodeCoverageAnalyzer.new
  COVERAGE_ANALYSIS.install_hook

  COVERAGE_ANALYSIS_HANDLERS = []

  at_exit do
    COVERAGE_ANALYSIS.remove_hook

    COVERAGE_ANALYSIS_HANDLERS.each do |a|
      a.call COVERAGE_ANALYSIS
    end
  end

  # Invokes the given block, which yields COVERAGE_ANALYSIS,
  # after code coverage analysis has completed.
  def RubyVPI.with_coverage_analysis &aBlock # :nodoc:
    COVERAGE_ANALYSIS_HANDLERS << aBlock if aBlock
  end
end
