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
  
  def tuneup_recording?
    Fiveruns::Tuneup.recording?
  end
  
  def tuneup_collecting?
    Fiveruns::Tuneup.collecting
  end
  
  def tuneup_data
    Fiveruns::Tuneup.data
  end
  
  def tuneup_step_link(step)
    if step.file
      link_to step.name, "txmt://open?url=file://#{CGI.escape step.file}&line=#{step.line}"
    else
      step.name
    end
  end
  
  def tuneup_bars
    bars = Fiveruns::Tuneup::Step.layers.map do |layer|
      size = (Fiveruns::Tuneup.data.percentages_by_layer[layer] * 200).to_i
      next if size == 0
      content_tag(:li, layer.to_s[0, 1].capitalize,
        :id => "fiveruns-tuneup-bar-#{layer}",
        :style => "width:#{size}px" )
    end
    bars.compact.join
  end
  
  def tuneup_step_bar(step)
    size = (step.time / tuneup_data.time * 400).to_i
    margin = 400 - size
    content_tag(:div, '', :class => "bar #{step.layer}", :style => "width:#{size}px;margin-right:#{margin}px")
  end
  
end