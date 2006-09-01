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
require 'rbconfig'

$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'ruby-vpi/rake'


PROJECT_ID = 'ruby-vpi'
PROJECT_NAME = 'Ruby-VPI'
PROJECT_URL = "http://#{PROJECT_ID}.rubyforge.org"
PROJECT_SUMMARY = "Ruby interface to Verilog VPI."
PROJECT_DETAIL = "#{PROJECT_NAME} is a #{PROJECT_SUMMARY}. It lets you create complex Verilog test benches easily and wholly in Ruby."
PROJECT_SSH_URL = "snk@rubyforge.org:/var/www/gforge-projects/#{PROJECT_ID}"


# Returns a temporary, unique path ready for use. No file exists at the returned path.
def generate_temp_path
  rm_f path = Tempfile.new($$).path
  path
end

# uploads the given sources without their SVN meta-data to the given destination URL
def upload_without_svn aDestUrl, *aSources
  tmpDir = generate_temp_path
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


task :default => :build

task :clobber do |t|
  files = FileList['**/Rakefile'].reject {|f| File.expand_path(f) == __FILE__}

  files.each do |f|
    cd File.dirname(f) do
      sh 'rake', t.name
    end
  end
end



##
# extension
#

desc "Builds object files for all simulators."
task :build

DEFAULT_SHARED_OBJ = "#{PROJECT_ID}.so"
DEFAULT_NORMAL_OBJ = "#{PROJECT_ID}.o"

directory 'obj'
CLOBBER.include 'obj'

{
  :cver => ['-DPRAGMATIC_CVER', '-export-dynamic'],
  :ivl => ['-DICARUS_VERILOG'],
  :vcs => ['-DSYNOPSYS_VCS'],
  :vsim => ['-DMENTOR_MODELSIM'],
}.each_pair do |target, (cflags, ldflags)|

  # object files that are needed to be built
  objFiles = [DEFAULT_NORMAL_OBJ, DEFAULT_SHARED_OBJ].inject({}) do |memo, src|
    dstName = src.sub(/#{File.extname src}$/, ".#{target}\\&")
    dst = File.expand_path(File.join('obj', dstName))

    memo[src] = dst
    memo
  end

  # task to build the object files
  targetTask = "build_#{target}"

  desc "Builds object files for #{target} simulator."
  task targetTask => ['obj', 'ext'] do |t|
    unless objFiles.values.reject {|f| File.exist? f}.empty?
      cd t.prerequisites[1] do
        ENV['CFLAGS'], ENV['LDFLAGS'] = cflags, ldflags
        sh %w(rake clean default)

        objFiles.each_pair do |src, dst|
          mv src, dst
        end
      end
    end
  end

  task :build => targetTask
end



##
# documentation
#

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
  t.title = "#{PROJECT_NAME}: #{PROJECT_SUMMARY}"
  t.options.concat %w(--charset utf-8 --line-numbers)
  t.rdoc_files.include '{bin,lib/**}/*.rb'
  t.main = 'SWIG::TYPE_p_unsigned_int'
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



##
# distribution
#

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
  cd t.prerequisites[0] do
    sh 'rake swig'
  end
end


desc 'Publish documentation to website.'
task :web => [:web_dist, :web_ref, :web_doc]

desc "Publish distribution info."
task :web_dist => ['style.css', *distDocs] do |t|
  upload_without_svn PROJECT_SSH_URL, *t.prerequisites
end

desc "Publish reference documentation."
task :web_ref => 'ref' do |t|
  upload_without_svn PROJECT_SSH_URL, *t.prerequisites
end

desc "Publish user documentation."
task :web_doc => :doc do |t|
  upload_without_svn "#{PROJECT_SSH_URL}/doc/", *FileList['doc/xhtml/*']
end

desc 'Connect to website FTP.'
task :ftp do
  sh 'lftp', "sftp://#{PROJECT_SSH_URL}"
end


desc "Generate release packages."
task :pkg => ['HISTORY', 'gem_extconf.rb'] do |t|
  # determine release version
    File.read(t.prerequisites[0]) =~ /Version\s+([\d\.]+)/
    releaseVersion = $1
    puts "release version is: #{releaseVersion}"

  mkdir tmpDir = generate_temp_path
  cp_r '.', tmpDir

  cd tmpDir do
    # clean up
      sh "svn st | awk '/^\\?/ {print $2}' | xargs rm -rf"
      sh "svn up"
      sh "find -name .svn | xargs rm -rf"

    sh "rake dist"

    # make gem package
      spec = Gem::Specification.new do |s|
        s.name = s.rubyforge_project = PROJECT_ID
        s.summary = PROJECT_SUMMARY
        s.description = PROJECT_DETAIL
        s.homepage = PROJECT_URL
        s.version = releaseVersion

        s.add_dependency 'rspec', '>= 0.5.4'
        s.add_dependency 'rake', '>= 0.7.0'

        s.requirements << "POSIX threads library"
        s.requirements << "C language compiler"

        s.files = FileList['**/*']
        s.autorequire = PROJECT_ID
        s.executables = FileList['bin/*'].select {|f| File.executable?(f) && File.file?(f)}.map {|f| File.basename f}
        s.extensions << t.prerequisites[1]
      end

      Gem::manage_gems
      Gem::Builder.new(spec).build

      mv *(FileList['*.gem'] << File.dirname(__FILE__))
  end

  rm_r tmpDir
end


desc "Configures the gem during installation."
task :config_gem_install => 'readme.html' do |t|
  # makes documentation available to gem_server
    gemDir = File.dirname(__FILE__)
    gemName = File.basename(gemDir)
    docDir = File.join('..', '..', 'doc', gemName)

    mkdir_p docDir
    ln_s gemDir, File.join(docDir, 'rdoc')

    # gem_server doesn't dynamically generate directory index
    cp t.prerequisites[0], 'index.html'
end



##
# testing
#

desc "Ensure that examples work with $SIMULATOR"
task :test => :build do
  FileList['samp/*/'].each do |s|
    cd s do
      sh 'rake', ENV['SIMULATOR'] || 'cver'
    end
  end
end
