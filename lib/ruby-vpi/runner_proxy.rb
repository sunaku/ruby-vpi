# A template to simplify running multiple tests for an examples. This file is
# meant to be embedded in another Rakefile.

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

# supress errors about nonexistent tasks
  task :default

  ARGV.each do |t|
    task t
  end

# invoke each test runner with the command-line args
  at_exit do
    unless ARGV.empty?
      FileList['**/*.rake'].each do |path|
        parent, runner = File.dirname(path), File.basename(path)

        cd parent do
          sh 'rake', '-f', runner, *ARGV
        end
      end
    end
  end
