# Bootstraps the RSpec library from within Ruby.

require 'rubygems'
require_gem 'rspec', '>= 0.5.4'
require 'spec'

# prevent RSpec termination when no arguments are provided
ARGV.unshift ''

$context_runner = ::Spec::Runner::OptionParser.create_context_runner(ARGV, false, STDERR, STDOUT)
at_exit {$context_runner.run true}
