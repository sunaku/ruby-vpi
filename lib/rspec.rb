# Bootstraps the RSpec library from within Ruby.

require 'rubygems'
require_gem 'rspec', '>= 0.5.4'
require 'spec'

$context_runner = ::Spec::Runner::OptionParser.create_context_runner(ARGV, true, STDERR, STDOUT)
at_exit {$context_runner.run false}
