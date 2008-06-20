instrumenting 'ActionController::Base', :class do
  def cache_page_with_fiveruns_tuneup(*args, &block)
    Fiveruns::Tuneup.step "Cache page", :controller do
      cache_page_without_fiveruns_tuneup(*args, &block)
    end
  end
  def expire_page_with_fiveruns_tuneup(*args, &block)
    Fiveruns::Tuneup.step "Expire cached page", :controller do
      expire_page_without_fiveruns_tuneup(*args, &block)
    end
  end
end

instrumenting 'ActionController::Base', :instance do
  def perform_action_with_fiveruns_tuneup(*args, &block)
    Fiveruns::Tuneup.run(self, request) do
      action = (request.parameters['action'] || 'index').to_s
      if Fiveruns::Tuneup.recording?
        Fiveruns::Tuneup.instrument_filters(self) 
        Fiveruns::Tuneup.instrument_action_methods(self) 
        Fiveruns::Tuneup.instrument_custom_methods
      end
      result = Fiveruns::Tuneup.step "Perform #{action.capitalize} action in #{self.class.name}", :controller, false do
        perform_action_without_fiveruns_tuneup(*args, &block)
      end
    end
  end
  def process_with_fiveruns_tuneup(request, response, *args, &block)
    result = process_without_fiveruns_tuneup(request, response, *args, &block)
    if !request.xhr? && response.content_type && response.content_type.include?('html') && controller_name != 'tuneup'
      Fiveruns::Tuneup.add_asset_tags_to(response)
    end
    result
  end
  
  def write_fragment_with_fiveruns_tuneup(*args, &block)
    Fiveruns::Tuneup.step "Cache fragment", :controller do
      write_fragment_without_fiveruns_tuneup(*args, &block)
    end
  end
  def expire_fragment_with_fiveruns_tuneup(*args, &block)
    Fiveruns::Tuneup.step "Expire fragment cache", :controller do
      expire_fragment_without_fiveruns_tuneup(*args, &block)
    end
  end
end