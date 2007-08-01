# A template to simplify running multiple tests for an examples.
# This file is meant to be embedded in another Rakefile.
#--
# Copyright 2006 Suraj N. Kurapati
# See the file named LICENSE for details.

# supress errors about nonexistent tasks
  task :default

  ARGV.each do |t|
    task t
  end

# invoke each test runner with the command-line args
  at_exit do
    FileList['**/*.rake'].each do |path|
      parent, runner = File.dirname(path), File.basename(path)

      cd parent do
        sh 'rake', '-f', runner, *ARGV
      end
    end
  end
