installed = false
Dir[File.dirname(__FILE__) << "/assets/*"].each do |location|
  directory = File.basename(location)
  destination = File.join(RAILS_ROOT, 'public', directory, 'tuneup')
  FileUtils.rm_rf(destination) rescue nil
  FileUtils.mkdir_p(destination)
  Dir[File.join(location, '*')].each do |file|
    new_filename = File.join(destination, File.basename(file))
    unless File.exists?(new_filename)
      FileUtils.cp file, new_filename
    end
  end
end