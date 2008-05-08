require 'ostruct'

class TuneupController < ActionController::Base
    
  before_filter :find_config, :except => :index
    
  def index
    redirect_to :action => 'show'
  end
  
  def show
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