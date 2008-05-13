module TuneupAssetsHelper
  
  # Insert in +<head>+ to include the FiveRuns TuneUp panel on application pages
  def tuneup
    javascript_include_tag('prototype', 'fiveruns-tuneup') + stylesheet_link_tag('fiveruns-tuneup')
  end
  
end