module Fiveruns
  module Tuneup
    
    class << self
      attr_accessor :collecting
      attr_writer
      def data
        @data ||= returning RootStep.new do |r|
          r << Step.new('Item#find', :model, 2.3)
          r << (bar = Step.new('ActionView::Base#render', :view, 1.4))
          bar << Step.new('ActionView::Base#render_file', :view, 0.2)
          bar << Step.new('ActionView::Base#render_partial', :view, 0.4, __FILE__, __LINE__)
          bar << Step.new('Item.count', :model, 0.1)
          bar << Step.new('ActionView::Base#render_partial', :view, 0.7)
          r << Step.new('ActionController::Base#process', :controller, 0.4)
        end
      end
    end
  
  end
end
  