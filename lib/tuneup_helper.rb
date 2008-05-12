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
  
  def tuneup_css_class_for_step(step)
    returning [] do |classes|
      if step.children.any?
        classes << 'with-children'
        classes << 'tuneup-opened' if step.depth == 1
      end
    end.join(' ')
  end
  
  def tuneup_collecting?
    Fiveruns::Tuneup.collecting
  end
  
  def tuneup_data
    Fiveruns::Tuneup.stack.first
  end
  
  def tuneup_step_link(step)
    link_to_function tuneup_style_step_name(tuneup_truncate_step_name(step)), "$('#{dom_id(step, :children)}').toggle();$('#{dom_id(step)}').toggleClassName('tuneup-opened');"
  end
  
  def tuneup_truncate_step_name(step)
    chars = 50 - (step.depth * 2)
    tuneup_truncate(step.name, chars)
  end
  
  def tuneup_bars
    bars = Fiveruns::Tuneup::Step.layers.map do |layer|
      size = (tuneup_data.percentages_by_layer[layer] * 200).to_i
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
  
  def tuneup_style_step_name(name)
    case name
    when /^(\S+) action in (\S+Controller)$/
      "<strong>#{h $1}</strong> action in <strong>#{h $2}</strong>"
    when /^(Find|Create|Delete|Update) ([A-Z]\S*)(.*?)$/
      "#{h $1} <strong>#{h $2}</strong>#{h $3}"
    when /^(Render.*?)(\S+)$/
      "#{h $1}<strong>#{h $2}</strong>"
    else
      h(name)
    end
  end
  
  def tuneup_truncate(text, max=32)
    if text.size > max
      component = (max - 3) / 2
      remainder = (max - 3) % 2
      text.sub(/^(.{#{component}}).*?(.{#{component + remainder}})$/s, '\1...\2')
    else
      text
    end
  end
  
end