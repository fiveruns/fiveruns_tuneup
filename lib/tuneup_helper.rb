module TuneupHelper

  # Insert in +<head>+ to include the FiveRuns TuneUp panel on application pages
  def tuneup
    javascript_include_tag('prototype', 'fiveruns-tuneup') + stylesheet_link_tag('fiveruns-tuneup')
  end
  
  def tuneup_signin_url
    # TODO: Collector URL during collector development, staging, etc
    "https://tuneup-collector.fiveruns.com/session/new"
  end
  
  def tuneup_signup_url
    # TODO: Registration URL during development, staging, etc
    "https://tuneup.fiveruns.com/signup"
  end
  
  def tuneup_collection_link
    state = tuneup_collecting? ? :off : :on
    link_to_remote "Turn #{state.to_s.titleize}", :url => "/tuneup/#{state}"
  end
  
  def tuneup_collecting?
    Fiveruns::Tuneup.collecting
  end
  
end