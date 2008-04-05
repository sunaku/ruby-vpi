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
DYNAMIC_DOCS = 'ruby-vpi-dynamic.rb'

$:.unshift PROJECT_LIBS
require 'ruby-vpi'
require 'ruby-vpi/rake'
require 'ruby-vpi/util'

task :default => :build

# utility

  # Returns a temporary, unique path ready for
  # use. No file exists at the returned path.
  def generate_temp_path
    path = Tempfile.new($$).path
    rm_f path
    path
  end

  # propogate cleaning tasks recursively to lower levels
  %w[clean clobber].each do |t|
    task t do
      files = FileList['**/Rakefile'].exclude('_darcs') - %w[Rakefile]

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

  RubyVPI::SIMULATORS.each do |sim|
    taskName = "build_#{sim.id}"

    desc "Builds object files for #{sim.name}."
    task taskName => ['obj', 'ext'] do
      src = RubyVPI::Project[:name] + '.' + Config::CONFIG['DLEXT']
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
  desc "Build the documentation."
  task :doc

  # the user guide
  file 'doc/guide.html' => 'doc/guide.erb' do |t|
    sh "gerbil html #{t.prerequisites} > #{t.name}"
  end
  task :doc => 'doc/guide.html'
  CLOBBER.include 'doc/guide.html'

# API reference
  directory 'doc/api'
  CLOBBER.include 'doc/api'

  desc "Build API reference."
  task :ref => ['doc/api/ruby', 'doc/api/c']

  file DYNAMIC_DOCS => 'ext/vpi_user.h' do |t|
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
        body.scan %r{^XXTERN\s+(\S+\s+\*?)(\S+)\s+PROTO_PARAMS\(\((.*?)\)\);}m do |type, func, args|
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
          require 'lib/ruby-vpi/core/edge-methods.rb'
          RubyVPI::EdgeClass::DETECTION_METHODS.each do |m|
            f.puts "# #{m.info}"
            f.puts "def #{m.name}; end"
          end
        f.puts "end"
      f.puts "end"
    end
  end
  CLOBBER.include DYNAMIC_DOCS

  Rake::RDocTask.new 'doc/api/ruby' do |t|
    Rake::Task['doc/api'].invoke
    t.rdoc_dir = t.name

    Rake::Task[DYNAMIC_DOCS].invoke
    t.rdoc_files.include 'bin/{ruby-vpi,*.rb}', 'lib/**/*.rb', DYNAMIC_DOCS
  end


  desc 'Build API reference for C.'
  file 'doc/api/c' => 'doc/api' do |t|
    # doxygen outputs to this temporary destination
    tempDest = 'ext/html'

    cd File.dirname(tempDest) do
      sh "doxygen"
    end

    mv tempDest, t.name
  end

# packaging
  spec = Gem::Specification.new do |s|
    s.name              = RubyVPI::Project[:name].downcase
    s.version           = RubyVPI::Project[:version]
    s.summary           = "Ruby interface to IEEE 1364-2005 Verilog VPI"
    s.description       = "Ruby-VPI is a #{s.summary} and a platform for unit testing, rapid prototyping, and systems integration of Verilog modules through Ruby. It lets you create complex Verilog test benches easily and wholly in Ruby."
    s.homepage          = RubyVPI::Project[:website]
    s.rubyforge_project = s.name

    s.files       = FileList['**/*'].exclude('_darcs', DYNAMIC_DOCS)
    s.autorequire = s.name
    s.extensions << 'gem_extconf.rb'
    s.executables = s.name

    s.requirements << "POSIX threads library"
    s.requirements << "C language compiler"

    s.add_dependency 'rake',       '>= 0.7.0'
    s.add_dependency 'rspec',      '>= 1.0.0'
    s.add_dependency 'rcov',       '>= 0.7.0'
    s.add_dependency 'xx'           # needed by rcov
    s.add_dependency 'ruby-debug', '>= 0.5.2'
    s.add_dependency 'ruby-prof'
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

# releasing
  desc 'Build release packages.'
  task :dist => [:clobber, :doc, :ref] do
    system 'rake package'
  end

# utility
  desc 'Upload to project website.'
  task :upload => [:doc, :ref] do
    sh "rsync -av doc/ ~/www/lib/#{spec.name}"
    sh "rsync -av doc/api/ ~/www/lib/#{spec.name}/api/ --delete"
  end

  desc "Ensure that examples work with $SIMULATOR"
  task :test => :build do
    # ensures that current sources are tested instead of the installed gem
    ENV['RUBYLIB'] = PROJECT_LIBS

    sim = ENV['SIMULATOR'] || 'cver'

    FileList['examples/**/*.rake'].each do |runner|
      sh 'rake', '-f', runner, sim
    end
  end
