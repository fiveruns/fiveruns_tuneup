require File.dirname(__FILE__) << "/lib/fiveruns/tuneup/version"

load 'build_tasks/setup.rb'

PROJ.name = 'fiveruns_tuneup'
PROJ.authors = ['Bruce Williams', 'Brian Dainton']
PROJ.email = 'dev@fiveruns.com'
PROJ.url = 'http://fiveruns.rubyforge.org/fiveruns_tuneup'
PROJ.rubyforge_name = 'fiveruns'

PROJ.libs = %w[]
PROJ.ruby_opts = []
PROJ.test_opts = []

PROJ.description = "FiveRuns TuneUp plugin for http://tuneup.fiveruns.com"
PROJ.summary = "FiveRuns TuneUp Plugin"

PROJ.version = Fiveruns::Tuneup::Version::STRING

task 'gem:package' => 'manifest:assert'

# EOF