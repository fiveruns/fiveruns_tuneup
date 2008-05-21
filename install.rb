# Allow linking (for development)
method = ENV['LINK'] ? :ln_s : :cp
installed = false
Dir[File.dirname(__FILE__) << "/assets/*"].each do |location|
  directory = File.basename(location)
  destination = File.join(RAILS_ROOT, 'public', directory, 'tuneup')
  FileUtils.mkdir_p(destination) rescue nil
  Dir[File.join(location, '*')].each do |file|
    new_filename = File.join(destination, File.basename(file))
    unless File.exists?(new_filename)
      FileUtils.send(method, file, new_filename)
      installed = true
    end
  end
end
if installed
  STDERR.puts "FiveRuns TuneUp: Installed assets in public/" 
end