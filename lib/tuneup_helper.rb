module TuneupHelper

  # Insert in +<head>+ to include the FiveRuns TuneUp panel on application pages
  def tuneup_panel
    javascript_include_tag('prototype', 'fiveruns-tuneup-panel') + stylesheet_link_tag('fiveruns-manage-panel')
  end
  
end