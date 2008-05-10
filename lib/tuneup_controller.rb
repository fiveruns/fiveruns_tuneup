require 'ostruct'

class TuneupController < ActionController::Base
    
  before_filter :find_config, :except => :index
  
  def show
    render :update do |page|
      page['fiveruns-tuneup-content'].replace_html(render :partial => "tuneup/panel/#{@config.state}")
    end
  end
  
  def edit
  end
  
  def update
    @config.update(params[:config])
    @config.save!
    redirect_to :action => 'show'
  end
  
  #######
  private
  #######

  def find_config
    @config = TuneupConfig.new
  end
  
end