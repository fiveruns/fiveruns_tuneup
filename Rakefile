unless File.file?(File.dirname(__FILE__) << "/../../../config/environment.rb")
  abort "FiveRuns TuneUp tests can only be run when the plugin is installed in a Rails application"
end

require 'rake'
require 'rake/testtask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the fiveruns-tuneup plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end