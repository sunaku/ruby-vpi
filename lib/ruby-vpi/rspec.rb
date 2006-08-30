# Bootstraps the RSpec library from within Ruby.

=begin
  Copyright 2006 Suraj N. Kurapati
  Copyright 2006 RSpec project

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

require 'rubygems'
require_gem 'rspec'
require 'spec'

# prevent RSpec termination when no arguments are provided
  ARGV.unshift ''

$context_runner = ::Spec::Runner::OptionParser.create_context_runner(ARGV, false, STDERR, STDOUT)
at_exit {$context_runner.run false}
