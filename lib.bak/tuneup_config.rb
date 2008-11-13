require 'yaml'

class TuneupConfig
  
  delegate :[], :[]=, :each, :update, :to => :data

  def self.defaults
    { 'api_key' => nil }
  end
  
  def save!
    File.open(config_file, 'w') { |f| f.puts data.to_yaml }
  end
  
  def data
    @data ||= begin
      YAML.load(File.read(config_file)) rescue self.class.defaults
    end
  end
    
  def config_file
    File.join(RAILS_ROOT, 'config', 'fiveruns_tuneup.yml')
  end
  
  def state
    data['api_key'] ? :registered : :unregistered
  end
  
end