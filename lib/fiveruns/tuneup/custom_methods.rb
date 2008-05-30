module Fiveruns::Tuneup::CustomMethods
  
  def tuneup(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    Fiveruns::Tuneup.add_custom_methods(self, *args)
  end
  
end
