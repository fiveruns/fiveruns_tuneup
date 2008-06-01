module Fiveruns::Tuneup::CustomMethods
  
  # Manually instrument methods
  def tuneup(*args)
    Fiveruns::Tuneup.add_custom_methods(self, *args)
  end
  
end
