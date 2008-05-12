require 'ostruct'
require 'open-uri'

class TuneupController < ActionController::Base
    
  before_filter :find_config, :except => :index
  
  def show
    render :update do |page|
      page['fiveruns-tuneup-content'].replace_html(render :partial => "tuneup/panel/#{@config.state}")
    end
  end
  
  def update
    @config.update(params[:config])
    @config.save!
    redirect_to :action => 'show'
  end
  
  def upload
    
  end
  
  def on
    collect true
  end
  
  def off
    collect false
  end
  
  #######
  private
  #######
  
  def collect(state)
    Fiveruns::Tuneup.collecting = state
    render(:update) { |p| p['fiveruns-tuneup-panel'].replace(render :partial => 'tuneup/panel/registered') }
  end

  def find_config
    @config = TuneupConfig.new
  end
  
end