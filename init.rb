# For Rails < 2.0.991
init_path = File.dirname(__FILE__) << "/rails/init.rb"
eval(File.read(init_path), binding, init_path,  __LINE__)