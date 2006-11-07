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

CFLAGS, LDFLAGS = ENV['CFLAGS'], ENV['LDFLAGS']

require 'rake/clean'
require 'rake/rdoctask'
require 'rake/gempackagetask'

require 'tempfile'
require 'rbconfig'

PROJECT_LIBS = File.join(File.dirname(__FILE__), 'lib')

$:.unshift PROJECT_LIBS
require 'ruby-vpi'
require 'ruby-vpi/rake'


include RubyVpi::Config
PROJECT_SSH_URL = "snk@rubyforge.org:/var/www/gforge-projects/#{PROJECT_ID}"

File.read('HISTORY') =~ /Version\s+([\d\.]+)\s*\((.*?)\)/
PROJECT_VERSION = $1
PROJECT_BIRTHDAY = $2


# Returns a temporary, unique path ready for use. No file exists at the returned path.
def generate_temp_path
  rm_f path = Tempfile.new($$).path
  path
end

# uploads the given sources to the given destination URL
def upload aDestUrl, *aSources
  sh 'scp', '-Cr', aSources, aDestUrl
end



task :default => :build

[:clean, :clobber].each do |t|
  task t do
    files = FileList['**/Rakefile'].exclude('_darcs')
    files.shift # avoid infinite loop on _this_ file

    # allows propogation to lower levels when gem not installed
    ENV['RUBYLIB'] = PROJECT_LIBS

    files.each do |f|
      cd File.dirname(f) do
        sh 'rake', t.to_s
      end
    end
  end
end



## extension

desc "Builds object files for all simulators."
task :build

directory 'obj'
CLOBBER.include 'obj'


SIMULATORS.each do |sim|
  taskName = "build_#{sim.id}"

  desc "Builds object files for #{sim.name} simulator."
  task taskName => ['obj', 'ext'] do
    src = "#{PROJECT_ID}.so"
    dst = "#{PROJECT_ID}.#{sim.id}.so"

    dst = File.expand_path(File.join('obj', dst))

    unless File.exist? dst
      cd 'ext' do
        ENV['CFLAGS'] = "#{CFLAGS} #{sim.compiler_args}"
        ENV['LDFLAGS'] = "#{LDFLAGS} #{sim.linker_args}"

        sh 'rake'
        mv src, dst
        sh 'rake clean'
      end
    end
  end

  task :build => taskName
end



## documentation

desc 'Generate user documentation.'
task 'doc' do |t|
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
  t.title = "#{PROJECT_NAME}: #{PROJECT_SUMMARY}"
  t.options.concat %w(--charset utf-8 --line-numbers)
  t.rdoc_files.include '{bin,lib/**}/*.rb'
end


directory 'ref/c'
CLOBBER.include 'ref/c'

desc 'Generate reference for C.'
file 'ref/c' do |t|
  # doxygen outputs to this temporary destination
  tempDest = 'ext/html'

  cd File.dirname(tempDest) do
    sh "doxygen"
  end

  mv FileList[tempDest + '/*'].to_a, t.name
  rmdir tempDest
end



## distribution

DIST_INFO_HEADER = 'HEADER'

distDocs = [DIST_INFO_HEADER, 'README', 'HISTORY', 'MEMO'].map do |src|
  dst = src.downcase << '.html'
  dstPartial = src.downcase << '.part.html'

  file dst => [DIST_INFO_HEADER, src] do
    sh "redcloth #{DIST_INFO_HEADER unless src == DIST_INFO_HEADER} #{src} > #{dst}"
  end

  file dstPartial => src do
    sh "redcloth < #{src} > #{dstPartial}"
  end

  CLOBBER.include dst, dstPartial
  [dst, dstPartial]
end.flatten

desc "Prepare distribution information."
task :dist_info => distDocs


desc "Prepare for distribution."
task :dist => ['ext', :doc, :dist_info] do |t|
  cd 'ext' do
    sh 'rake swig'
  end
end


desc 'Publish documentation to website.'
task :web => [:web_info, :web_ref, :web_doc]

desc "Publish distribution info."
task :web_info => ['style.css', *distDocs] do |t|
  upload PROJECT_SSH_URL, *t.prerequisites
end

desc "Publish reference documentation."
task :web_ref => 'ref' do |t|
  upload PROJECT_SSH_URL, *t.prerequisites
end

desc "Publish user documentation."
task :web_doc => :doc do |t|
  upload PROJECT_SSH_URL, *t.prerequisites
end

desc 'Connect to website FTP.'
task :ftp do
  sh 'lftp', "sftp://#{PROJECT_SSH_URL}"
end


desc "Generate release packages."
task :release => [:clobber, :dist] do
  sh 'rake package'
end

spec = Gem::Specification.new do |s|
  s.name = s.rubyforge_project = PROJECT_ID
  s.summary = PROJECT_SUMMARY
  s.description = PROJECT_DETAIL
  s.homepage = PROJECT_URL
  s.version = PROJECT_VERSION

  s.add_dependency 'rspec', '>= 0.5.4'
  s.add_dependency 'rake', '>= 0.7.0'
  s.add_dependency 'rcov', '>= 0.7.0'

  s.requirements << "POSIX threads library"
  s.requirements << "C language compiler"

  s.files = FileList['**/*'].exclude('_darcs')
  s.autorequire = PROJECT_ID
  s.executables = FileList['bin/*'].select {|f| File.executable?( f ) && File.file?( f )}.map {|f| File.basename f}
  s.extensions << 'gem_extconf.rb'
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end


desc "Configures the gem during installation."
task :gem_config_inst => 'readme.html' do |t|
  # make documentation available to gem_server
    gemDir = File.dirname(__FILE__)
    gemName = File.basename(gemDir)
    docDir = File.join('..', '..', 'doc', gemName)

    mkdir_p docDir
    ln_s gemDir, File.join(docDir, 'rdoc')

    # gem_server doesn't dynamically generate directory index
    cp t.prerequisites[0], 'index.html'
end



## testing

desc "Ensure that examples work with $SIMULATOR"
task :test => :build do
  # ensures that current sources are tested instead of the installed gem
  ENV['RUBYLIB'] = PROJECT_LIBS

  FileList['samp/*/'].each do |s|
    cd s do
      sh 'rake', ENV['SIMULATOR'] || 'cver'
    end
  end
end
