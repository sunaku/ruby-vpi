# Bootstraps the RSpec library from within Ruby.

require 'rubygems'
require_gem 'rspec'
require 'spec'

# prevent RSpec termination when no arguments are provided
ARGV.unshift ''

context_runner = Spec::Runner::ContextRunner.new(ARGV)
Spec::Runner::Context.context_runner = context_runner
at_exit {context_runner.run}
