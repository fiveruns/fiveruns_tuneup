module TuneupHelper #:nodoc:

  def tuneup_signin_url
    "#{Fiveruns::Tuneup.collector_url}/users"
  end
  
  def tuneup_signup_url
    "#{Fiveruns::Tuneup.frontend_url}/signup"
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
    most_recent_data = Fiveruns::Tuneup.stack.first
    most_recent_data.blank? ? most_recent_data : most_recent_data['stack']
  end
  
  def tuneup_step_link(step)
    link = link_to_function(tuneup_style_step_name(tuneup_truncate_step_name(step)), "$('#{dom_id(step, :children)}').toggle();$('#{dom_id(step)}').toggleClassName('tuneup-opened');")
    link << sql_link(step)
  end
  
  def sql_link(step)
    return '' unless step.sql
    link_to_function(image_tag('/images/tuneup/magnify.png', :alt => 'Query'), :class => 'tuneup-sql tuneup-halo', :title => 'View Query') { |p| p[dom_id(step, :sql)].toggle }
  end
  
  def tuneup_truncate_step_name(step)
    chars = 50 - (step.depth * 2)
    tuneup_truncate(step.name, chars)
  end
  
  def tuneup_bar(step=tuneup_data, options={})
    width = options.delete(:width) || 200
    bars = Fiveruns::Tuneup::Step.layers.map do |layer|
      percent = step.percentages_by_layer[layer]
      if percent == 0
        next
      else
        size = (percent * width).to_i
      end
      size = 1 if size.zero?
      content_tag(:li, (size >= 10 ? layer.to_s[0, 1].capitalize : ''),
        :class => "tuneup-layer-#{layer}",
        :style => "width:#{size}px",
        :title => layer.to_s.titleize)
    end
    content_tag(:ul, bars.compact.join, options.merge(:class => 'tuneup-bar'))
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
      begin
        text.sub(/^(.{#{component}}).*?(.{#{component + remainder}})$/s, '\1...\2')
      rescue
        text
      end
    else
      text
    end
  end
  
  def tuneup_open_run(token)
    %[window.open("#{Fiveruns::Tuneup.frontend_url}/runs/#{token}", 'fiveruns_tuneup');]
  end
  
  def tuneup_reload_panel
    update_page do |page|
      page['tuneup-flash'].removeClassName('tuneup-show');
      page['tuneup-content'].replace_html(render(:partial => "tuneup/panel/#{@config.state}"))
    end
  end
  
  def tuneup_show_flash(type, locals)
    types = [:error, :notice].reject { |t| t == type }
    update_page do |page|
      page['tuneup-flash'].replace_html(render(:partial => 'flash', :locals => locals.merge(:type => type)))
      page['tuneup-flash'].addClassName('tuneup-show');
      types.each do |other_type|
        page['tuneup-flash'].removeClassName("tuneup-#{other_type}")
      end
      page['tuneup-flash'].addClassName("tuneup-#{type}");
    end
  end
  
  def link_to_edit_step(step)
    return nil unless step.file && step.line && RUBY_PLATFORM.include?('darwin')
    link_to(image_tag('/images/tuneup/edit.png', :alt => 'Edit'), "txmt://open?url=file://#{CGI.escape step.file}&line=#{step.line}", :class => 'tuneup-edit tuneup-halo', :title => 'Open in TextMate')
  end
    
end