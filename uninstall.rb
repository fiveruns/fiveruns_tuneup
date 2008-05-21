# Remove Assets
Dir[File.join(RAILS_ROOT, 'public', '*', 'tuneup')].each do |asset_dir|
  show_name = asset_dir.split(File::SEPARATOR)[-3, 3].join(File::SEPARATOR)
  FileUtils.rm_rf(asset_dir) rescue nil
  STDERR.puts "FiveRuns TuneUp: Removed #{show_name}"
end