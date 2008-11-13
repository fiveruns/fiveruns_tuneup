require 'rubygems'
require 'rake/gempackagetask'

NAME = "fiveruns_tuneup_rails"
AUTHOR = "FiveRuns Development Team"
EMAIL = "dev@fiveruns.com"
HOMEPAGE = "http://tuneup.fiveruns.com/"
SUMMARY = "Rails plugin that provides the FiveRuns TuneUp Panel (http://tuneup.fiveruns.com)"

# IMPORTANT: Make sure you modify the version number in lib/fiveruns_tuneup_rails.rb
#            as well!
GEM_VERSION = "0.9.0"

spec = Gem::Specification.new do |s|
  s.rubyforge_project = 'fiveruns_tuneup_rails'
  s.name = NAME
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = %w(README.rdoc LICENSE CHANGELOG CONTRIBUTORS)
  s.summary = SUMMARY
  s.description = s.summary
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE
  s.add_dependency('fiveruns_tuneup_core', '>= 0.5.3')
  s.require_path = 'lib'
  s.files = s.extra_rdoc_files + Dir.glob('*.rb') + Dir.glob("{lib,public,rails,tasks}/**/*")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Install as a gem"
task :install => [:package] do
  sh %{gem install pkg/#{NAME}-#{GEM_VERSION} --no-update-sources}
end

namespace :jruby do

  desc "Run :package and install the resulting .gem with jruby"
  task :install => :package do
    sh %{jruby -S gem install #{install_home} pkg/#{NAME}-#{GEM_VERSION}.gem --no-rdoc --no-ri}
  end
  
end