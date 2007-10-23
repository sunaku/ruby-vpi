# = Environment variables
# CFLAGS:: Arguments to the compiler.
# LDFLAGS:: Arguments to the linker.
#--
# Copyright 2006 Suraj N. Kurapati
# See the file named LICENSE for details.

require 'rake/clean'
require 'rake/rdoctask'
require 'rake/gempackagetask'

require 'tempfile'
require 'rbconfig'

PROJECT_LIBS = File.join(File.dirname(__FILE__), 'lib')

$:.unshift PROJECT_LIBS
require 'ruby-vpi'
require 'ruby-vpi/rake'
require 'ruby-vpi/util'

task :default => :build


# load project information
  include RubyVPI
  PROJECT_SSH_URL  = "snk@rubyforge.org:/var/www/gforge-projects/#{PROJECT_ID}"

  load 'doc/history.rb'
  head = @history.first
  PROJECT_VERSION  = head['Version']
  PROJECT_BIRTHDAY = head['Date']


# utility

  # Returns a temporary, unique path ready for
  # use. No file exists at the returned path.
  def generate_temp_path
    path = Tempfile.new($$).path
    rm_f path
    path
  end

  # uploads the given sources to the given destination URL
  def upload aDestUrl, *aSources
    sh 'rsync', '-avz', '--delete', aSources, aDestUrl
  end

  # propogate cleaning tasks recursively to lower levels
  %w[clean clobber].each do |t|
    task t do
      files = FileList['**/Rakefile'].exclude('_darcs')
      files.shift # avoid infinite loop on _this_ file

      # allows propogation to lower levels when gem not installed
      ENV['RUBYLIB'] = PROJECT_LIBS

      files.each do |f|
        cd File.dirname(f) do
          sh 'rake', t
        end
      end
    end
  end


# extension

  desc "Builds object files for all simulators."
  task :build

  directory 'obj'
  CLOBBER.include 'obj'

  ccFlags = ENV['CFLAGS']
  ldFlags = ENV['LDFLAGS']

  SIMULATORS.each do |sim|
    taskName = "build_#{sim.id}"

    desc "Builds object files for #{sim.name}."
    task taskName => ['obj', 'ext'] do
      src = PROJECT_ID + '.' + Config::CONFIG['DLEXT']
      dst = File.expand_path(File.join('obj', "#{sim.id}.so"))

      unless File.exist? dst
        cd 'ext' do
          ENV['CFLAGS']  = [ccFlags, sim.compiler_args].compact.join(' ')
          ENV['LDFLAGS'] = [ldFlags, sim.linker_args].compact.join(' ')

          sh "rake SIMULATOR=#{sim.id}"
          mv src, dst
          sh 'rake clean'
        end
      end
    end

    task :build => taskName
  end


# documentation

  desc 'Generate user documentation.'
  task :doc do |t|
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

  desc "Generate API documentation for dynamic code."
  file '../ruby-vpi-dynamic.rb' => 'ext/vpi_user.h' do |t|
    File.open t.name, 'w' do |f|
      f.puts "# This module encapsulates all functionality provided by the C-language Application Programming Interface (API) of the Verilog Procedural Interface (VPI).  See the ext/vpi_user.h file for details."
      f.puts "module VPI"
        body = File.read(t.prerequisites[0])

        # constants
        body.scan %r{^#define\s+(vpi\S+)\s+(\S+)\s+/\*+(.*?)\*+/} do |var, val, info|
          const = var.to_ruby_const_name
          f.puts '# ' << info
          f.puts "#{const}=#{val}"

          f.puts "# Returns the #{const} constant: #{info}"
          f.puts "def self.#{var}; end"
        end

        # functions
        body.scan /^XXTERN\s+(\S+\s+\*?)(\S+)\s+PROTO_PARAMS\(\((.*?)\)\);/m do |type, func, args|
          meth = func.gsub(/\W/, '')
          args = args.gsub(/[\r\n]/, ' ')

          [
            [ /PLI_BYTE8(\s*)\*(\s*data)/ , 'Object\1\2'  ],
            [ /PLI_BYTE8(\s*)\*?/         , 'String\1'    ],
            [ /PLI_U?INT32(\s*)\*/        , 'Array\1'     ],
            [ /PLI_U?INT32/               , 'Integer'     ],
            [ /\b[ps]_/                   , 'VPI::S_'     ],
            [ 'vpiHandle'                 , 'VPI::Handle' ],
            [ /va_list\s+\w+/             , '...'         ],
            [ /\bvoid(\s*)\*/             , 'Object\1'    ],
            [ 'void'                      , 'nil'         ],
          ].each do |(a, b)|
            args.gsub! a, b
            type.gsub! a, b
          end

          f.puts "# #{func}(#{args}) returns #{type}"
          f.puts "def self.#{meth}; end"
        end

        # VPI::Handle methods
        f.puts "class Handle"
          load 'lib/ruby-vpi/core/edge-methods.rb'
          DETECTION_METHODS.each do |m|
            f.puts "# #{m.info}"
            f.puts "def #{m.name}; end"
          end
        f.puts "end"
      f.puts "end"
    end
  end
  CLOBBER.include '../ruby-vpi-dynamic.rb'

  desc 'Generate reference for Ruby.'
  Rake::RDocTask.new 'ref/ruby' do |t|
    t.rdoc_dir = t.name
    t.title    = "#{PROJECT_NAME}: #{PROJECT_SUMMARY}"
    t.options.concat %w(--charset utf-8 --line-numbers)

    Rake::Task['../ruby-vpi-dynamic.rb'].invoke
    t.rdoc_files.include 'bin/{ruby-vpi,*.rb}', 'lib/**/*.rb', '../ruby-vpi-dynamic.rb'
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


# distribution

  desc 'Publish documentation to website.'
  task :web => ['ref/web', 'doc/web']

  desc "Publish reference documentation."
  task 'ref/web' => 'ref' do |t|
    upload PROJECT_SSH_URL, *t.prerequisites
  end

  desc "Publish user documentation."
  task 'doc/web' => 'doc' do |t|
    upload PROJECT_SSH_URL, *t.prerequisites
  end

  desc 'Connect to website FTP.'
  task :ftp do
    sh 'lftp', "sftp://#{PROJECT_SSH_URL}"
  end

  desc 'Generate release announcement.'
  task :ann => 'doc/history.rb' do |t|
    require t.prerequisites[0]

    $: << File.join(File.dirname(__FILE__), 'doc', 'lib')
    require 'doc_proxy'

    text = [
      PROJECT_DETAIL,
      "* See #{PROJECT_URL} for details.",
      "---",
      @history.first
    ].join "\n\n"

    IO.popen('w3m -T text/html -dump -cols 60', 'w+') do |pipe|
      pipe.write text.to_html
      pipe.close_write
      puts pipe.read
    end
  end


# packaging

  desc "Generate release packages."
  task :release => [:ref, :doc] do
    sh 'rake package'
  end

  spec = Gem::Specification.new do |s|
    s.name              = PROJECT_ID
    s.rubyforge_project = PROJECT_ID
    s.summary           = PROJECT_SUMMARY
    s.description       = PROJECT_DETAIL
    s.homepage          = PROJECT_URL
    s.version           = PROJECT_VERSION

    s.add_dependency 'rake',       '>= 0.7.0'
    s.add_dependency 'rspec',      '>= 1.0.0'
    s.add_dependency 'rcov',       '>= 0.7.0'
    s.add_dependency 'xx'           # needed by rcov
    s.add_dependency 'ruby-debug', '>= 0.5.2'
    s.add_dependency 'ruby-prof'

    s.requirements << "POSIX threads library"
    s.requirements << "C language compiler"

    s.files       = FileList['**/*'].exclude('_darcs')
    s.autorequire = PROJECT_ID
    s.extensions << 'gem_extconf.rb'
    s.executables = PROJECT_ID
  end

  Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_tar = true
  end


# installation

  desc "Configures the gem during installation."
  task :gem_config_inst do |t|
    # make documentation available to gem_server
    gemDir  = File.dirname(__FILE__)
    gemName = File.basename(gemDir)
    docDir  = File.join('..', '..', 'doc', gemName)

    mkdir_p docDir
    ln_s gemDir, File.join(docDir, 'rdoc')
  end


# testing

  desc "Ensure that examples work with $SIMULATOR"
  task :test => :build do
    # ensures that current sources are tested instead of the installed gem
    ENV['RUBYLIB'] = PROJECT_LIBS

    sim = ENV['SIMULATOR'] || 'cver'

    FileList['examples/**/*.rake'].each do |runner|
      sh 'rake', '-f', runner, sim
    end
  end
