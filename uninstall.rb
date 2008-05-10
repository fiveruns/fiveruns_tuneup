# Remove Assets
Dir[File.dirname(__FILE__) << "/public/*"].each do |location|
  directory = File.basename(location)
  source = File.join(RAILS_ROOT, 'public', directory)
  Dir[File.join(location, '*')].each do |file|
    FileUtils.rm File.join(source, File.basename(file)) rescue nil
  end
end