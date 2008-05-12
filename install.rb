# Clear, just in case
require File.dirname(__FILE__) << "/uninstall"
# Allow linking (for development)
method = ENV['LINK'] ? :ln_s : :cp
Dir[File.dirname(__FILE__) << "/public/*"].each do |location|
  directory = File.basename(location)
  destination = File.join(RAILS_ROOT, 'public', directory)
  Dir[File.join(location, '*')].each do |file|
    STDERR.puts "plugin public/#{directory}/#{File.basename(file)} -> (#{method}) app public/#{directory}/#{File.basename(file)}"
    FileUtils.send(method, file, destination)
  end
end
TuneupConfig.new.save!