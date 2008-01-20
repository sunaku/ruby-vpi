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
        xx_which(XMLish) { xx_with_doc_in_effect(*a, &b) }
      end
    end
  end

require 'rcov/report'


module RubyVPI
  module Coverage #:nodoc:
    @@analyzer = Rcov::CodeCoverageAnalyzer.new

    def Coverage.start
      @@analyzer.install_hook
    end

    def Coverage.stop
      @@analyzer.remove_hook
    end


    @@handlers = []

    # Invokes the given block after code coverage analysis has completed.
    def Coverage.attach &aBlock # :yield: Rcov::CodeCoverageAnalyzer
      raise ArgumentError unless block_given?
      @@handlers << aBlock if aBlock
    end

    at_exit do
      Coverage.stop

      @@handlers.each do |h|
        h.call @@analyzer
      end
    end
  end
end
