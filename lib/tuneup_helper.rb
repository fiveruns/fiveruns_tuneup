module TuneupHelper #:nodoc:
  
  include BumpsparkHelper

  def tuneup_signin_url
    "#{Fiveruns::Tuneup.collector_url}/users"
  end
  
  def tuneup_signup_url
    "#{Fiveruns::Tuneup.frontend_url}/signup"
  end
  
  def tuneup_collection_link
    state = tuneup_collecting? ? :off : :on
    %|<a onclick="new TuneUpSandbox.Ajax.Request('/tuneup/#{state}', {asynchronous:true, evalScripts:true}); return false;" href="#">Turn #{state.to_s.titleize}</a>|
  end
  
  def tuneup_recording?
    Fiveruns::Tuneup.recording?
  end
  
  def tuneup_css_class_for_step(step)
    returning [] do |classes|
      if step.children.any?
        classes << 'with-children'
        classes << 'tuneup-opened' if step.depth == 1 || open_step?(step)
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
  
  def tuneup_schemas
    Fiveruns::Tuneup.stack.first['schemas']
  end
  
  def trend
    numbers= if Fiveruns::Tuneup.trend.size > 50
      Fiveruns::Tuneup.trend[-50..-1]
    else
      Fiveruns::Tuneup.trend
    end
    return unless numbers.size > 1
    tag(:img,
      :src => build_data_url("image/png",bumpspark(numbers)), :alt => '',
      :title => "Trend over last #{pluralize(numbers.size, 'run')}")
  end
  
  def open_step?(step)
     [/^Around filter/, /^Invoke/].any? { |pattern| step.name =~ pattern }
  end
  
  def tuneup_step_link(step)
    name = tuneup_style_step_name(tuneup_truncate_step_name(step))
    link = if step.children.any?
      link_to_function(name, "TuneUpSandbox.$('#{dom_id(step, :children)}').toggle();TuneUpSandbox.$('#{dom_id(step)}').toggleClassName('tuneup-opened');", :class => "tuneup-step-link", :title => step.name)
    else
      content_tag(:span, name, :title => step.name)
    end
    link << additional_step_links(step)
  end
  
  def link_to_upload
    if @config.state == :registered
      %|<a onclick="new TuneUpSandbox.Ajax.Request('/tuneup/upload?uri=#{CGI.escape(session['fiveruns_tuneup_last_uri'])}', {asynchronous:true, evalScripts:true, onComplete:function(request){ TuneUp.Spinner.stop(); TuneUpSandbox.$('tuneup-top').show();}, onLoading:function(request){TuneUpSandbox.$('tuneup-top').hide(); TuneUp.Spinner.start()}}); return false;" id="tuneup-save-link" href="#">Share this Run</a>|
    else
      %|<a onclick="new TuneUpSandbox.Ajax.Request('/tuneup/register', {asynchronous:true, evalScripts:true}); return false;" id="tuneup-save-link" href="#">Login to Share this Run</a>|
    end
  end
  
  def link_to_show
    %|<a id="tuneup-back-to-run-link" onclick="#{redisplay_last_run} return false;" href="#">&lt;&lt;&lt; Back to Run</a>|
  end
  
  def redisplay_last_run(namespaced=true)
    namespace_js = lambda { |fun| namespaced ? "TuneUpSandbox.#{fun}" : fun }
    "#{namespace_js['$']}('tuneup-panel').show(); #{namespace_js['$']}('tuneup-signin-form').remove();"
  end

  
  def additional_step_links(step)
    returning '' do |text|
      text << sql_link(step) if step.sql
      text << schema_link(step) if step.table_name
    end
  end
  
  def schema_link(step)
    link_to_schema(image_tag('/images/tuneup/schema.png', :alt => 'Schema'), step.table_name,  :class => 'tuneup-schema tuneup-halo')
  end
  
  def sql_link(step)
    link_to_function(image_tag('/images/tuneup/magnify.png', :alt => 'Query'), :class => 'tuneup-sql tuneup-halo', :title => 'View Query') do |page| 
      page << %(TuneUpSandbox.$("#{dom_id(step, :sql)}").toggle(); return false;)
    end
  end
  
  def link_to_schema(text, table, html_options={})
    link_to_function(text, "TuneUp.switchSchema('#{table}')", html_options.merge(:title => "View Schema"))
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
        begin
          size = (percent * width).to_i
        rescue
          raise "Can't find percent for #{layer.inspect} from #{step.percentages_by_layer.inspect}"\
        end
      end
      size = 1 if size.zero?
      content_tag(:li, ((size >= 10 && layer != :other) ? layer.to_s[0, 1].capitalize : ''),
        :class => "tuneup-layer-#{layer}",
        :style => "width:#{size}px",
        :title => layer.to_s.titleize)
    end
    content_tag(:ul, bars.compact.join, options.merge(:class => 'tuneup-bar'))
  end
  
  def tuneup_style_step_name(name)
    case name
    when /^Perform (\S+) action in (\S+Controller)$/
      "Perform <strong>#{h $1}</strong> action in <strong>#{h $2}</strong>"
    when /^Invoke (\S+) action$/
      "Invoke <strong>#{h $1}</strong> action"
    when /^(Find|Create|Delete|Update) ([A-Z]\S*)(.*?)$/
      "#{h $1} <strong>#{h $2}</strong>#{h $3}"
    when /^(Render.*?)(\S+)$/
      "#{h $1}<strong>#{h $2}</strong>"
    when /^(\S+ filter )(.*?)$/
      "#{h $1}<strong>#{h $2}</strong>"
    when 'Other'
      "(<i>Other</i>)"
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
      page << "$('tuneup-flash').removeClassName('tuneup-show');"
      page << %[$('tuneup-content').update("#{escape_javascript(render(:partial => 'tuneup/panel/show.html.erb'))}");]
      page << 'TuneUp.adjustAbsoluteElements(_document.body);'
      page << 'TuneUp.adjustFixedElements();'
    end
  end
  
  def tuneup_show_flash(type, locals)
    types = [:error, :notice].reject { |t| t == type }
    update_page do |page|
      page << %[$('tuneup-flash').update("#{escape_javascript(render(:partial => 'flash.html.erb', :locals => locals.merge(:type => type)))}");]
      page << "$('tuneup-flash').addClassName('tuneup-show')"
      types.each do |other_type|
        page << "$('tuneup-flash').removeClassName('tuneup-#{other_type}')"
      end
      page << "$('tuneup-flash').addClassName('tuneup-#{type}')"
      page << 'TuneUp.adjustAbsoluteElements(_document.body);'
      page << 'TuneUp.adjustFixedElements();'
    end
  end
  
  def link_to_edit_step(step)
    return nil unless step.file && step.line && RUBY_PLATFORM.include?('darwin')
    link_to(image_tag('/images/tuneup/edit.png', :alt => 'Edit'), "txmt://open?url=file://#{CGI.escape step.file}&amp;line=#{step.line}", :class => 'tuneup-edit tuneup-halo', :title => 'Open in TextMate')
  end
    
end