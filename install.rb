# Install Assets
Dir[File.dirname(__FILE__) << "/public/*"].each do |location|
  directory = File.basename(location)
  destination = File.join(RAILS_ROOT, 'public', directory)
  Dir[File.join(location, '*')].each do |file|
    FileUtils.cp file, destination
  end
end