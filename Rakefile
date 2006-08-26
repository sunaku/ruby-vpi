# Main build specification for Ruby-VPI.
#
# = Environment variables
# CFLAGS:: Arguments to the compiler.
# LDFLAGS:: Arguments to the linker.

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

require 'rake/clean'
require 'rake/rdoctask'
require 'tempfile'


SSH_URL = 'snk@rubyforge.org:/var/www/gforge-projects/ruby-vpi'

task :default => :build


# utility methods
  # Returns a temporary, unique path ready for use. No file exists at the returned path.
  def generateTempPath
    rm_f path = Tempfile.new($$).path
    path
  end

  # uploads the given sources without their SVN meta-data to the given destination URL
  def uploadWithoutSvn aDestUrl, *aSources
    tmpDir = generateTempPath
    mkdir tmpDir

    tmpSources = aSources.map do |src|
      cp_r src, tmpDir, :preserve => true
      File.join(tmpDir, File.basename(src))
    end

    # remove SVN meta-data from sources
      sh "find #{tmpDir} -name .svn | xargs rm -rf"

    # upload sources
      sh 'scp', '-Cr', *(tmpSources + [aDestUrl])

    rm_rf tmpDir
  end


# cleaning
  task :clobber do |t|
    FileList['samp/*/', 'doc'].each do |dir|
      cd dir do
        sh 'rake', t.name
      end
    end
  end

# variables
  require 'rbconfig'

  CFLAGS = "#{Config::CONFIG['CFLAGS']} #{ENV['CFLAGS']} -g -DDEBUG"
  LDFLAGS = "#{Config::CONFIG['LDFLAGS']} #{ENV['LDFLAGS']}"


# extension
  desc 'Builds the Ruby-VPI extension.'
  task :build => 'Makefile' do |t|
    sh "make -f #{t.prerequisites[0]}"
  end

  CLEAN.include 'Makefile', 'mkmf.log', '*.o', '*.so'

  file 'Makefile' => [:swig, 'src/extconf.rb'] do |t|
    ruby "#{t.prerequisites[1]} --with-cflags='#{CFLAGS}' --with-ldflags='#{LDFLAGS}'"
  end


  desc 'Generate Ruby wrapper for VPI.'
  task :swig => 'src/swig_wrap.cin'

  file 'src/swig_wrap.cin' => 'src/swig_vpi.i' do |t|
    sh "swig -ruby -o #{t.name} #{t.prerequisites[0]}"
  end

  file 'src/swig_vpi.i' => 'src/swig_vpi.h'

  file 'src/swig_vpi.h' => 'src/vpi_user.h' do |t|
    # avoid problems with SWIG-generated wrapper for VPI vprintf functions which use va_list
    ruby %{-pe 'gsub /\\bva_list\\b/, "int"' #{t.prerequisites[0]} > #{t.name}}
  end


# documentation
  desc 'Generate documentation.'
  task 'doc' => 'ref' do |t|
    cd t.name do
      sh 'rake'
    end
  end


  directory 'ref'
  CLOBBER.include 'ref'

  desc 'Generate reference documentation.'
  file 'ref' => ['ref/c', 'ref/ruby']


  directory 'ref/ruby'
  CLOBBER.include 'ref/ruby'

  desc 'Generate reference for Ruby.'
  Rake::RDocTask.new 'ref/ruby' do |t|
    t.rdoc_dir = t.name
    t.title = 'Ruby-VPI: Ruby interface to Verilog VPI'
    t.options.concat %w(--charset utf-8 --tab-width 2 --line-numbers)

    t.rdoc_files.include '**/*.rb'
  end


  directory 'ref/c'
  CLOBBER.include 'ref/c'

  desc 'Generate reference for C.'
  file 'ref/c' do |t|
    # doxygen outputs to this temporary destination
    tempDest = 'src/html'

    cd File.dirname(tempDest) do
      sh "doxygen"
    end

    mv FileList[tempDest + '/*'].to_a, t.name
    rmdir tempDest
  end

# distribution
  distDocs = ['HISTORY', 'README', 'MEMO'].map do |src|
    dst = src.downcase << '.html'

    file dst => src do |t|
      sh "redcloth < #{t.prerequisites[0]} > #{t.name}"
    end

    CLOBBER.include dst
    dst
  end


  desc "Prepare for distribution."
  task :dist => [:swig, :doc, *distDocs]

  # website publishing
    desc 'Publish documentation to website.'
    task :web => [:web_dist, :web_doc]

    task :web_dist => ['ref', *distDocs] do |t|
      uploadWithoutSvn SSH_URL, *t.prerequisites
    end

    desc "Publish user documentation."
    task :web_doc => :doc do |t|
      uploadWithoutSvn "#{SSH_URL}/doc/", *FileList['doc/xhtml/*']
    end

    desc 'Connect to website FTP.'
    task :ftp do
      sh 'lftp', "sftp://#{SSH_URL}"
    end

# release
  desc "Prepare release packages."
  task :pkg => ['HISTORY'] do |t|
    # determine release version
      File.read(t.prerequisites[0]) =~ /Version\s+([\d\.]+)/
      version = $1

      # print "Please input the release version (#{version}): "
      # input = STDIN.gets.chomp
      # version = input unless input.empty?

      puts "- Release version is: #{version}"

    mkdir tmpDir = generateTempPath

    pkgName = "ruby-vpi-#{version}"
    pkgDir = File.join(tmpDir, pkgName)

    cp_r '.', pkgDir

    cd pkgDir do |dir|
      # clean up
        sh "svn st | awk '{print $2}' | xargs rm -rf"
        sh "svn up"
        sh "find -name .svn | xargs rm -rf"

      # make release packages
        sh "rake dist"

        src = File.join('..', File.basename(dir))
        dst = File.join(File.dirname(__FILE__), pkgName)

        sh '7z', 'a', dst + '.7z', src
        sh 'tar', 'zcf', dst + '.tgz', src
    end

    rm_r tmpDir
  end

# testing
  desc "Ensure that examples work with $SIMULATOR"
  task :test => FileList['samp/*/'] do |t|
    t.prerequisites.each do |s|
      cd s do
        sh 'rake', ENV['SIMULATOR'] || 'ivl'
      end
    end
  end
