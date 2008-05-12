require 'ostruct'
require 'open-uri'

class TuneupController < ActionController::Base
    
  before_filter :find_config, :except => :index
  
  def show
    render :update do |page|
      page['fiveruns-tuneup-content'].replace_html(render(:partial => "tuneup/panel/#{@config.state}"))
    end
  end
  
  def update
    @config.update(params[:config])
    @config.save!
    redirect_to :action => 'show'
  end
  
  def upload
    token = upload_last_run
    render :update do |page|
      if token
        page << tuneup_open_run(token)
      else
        # FIXME: Replace stubs
        page.alert("STUB: Could not upload run")
      end
    end
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
    render(:update) { |p| p['fiveruns-tuneup-panel'].replace(render(:partial => 'tuneup/panel/registered')) }
  end

  def find_config
    @config = TuneupConfig.new
  end
  
  #
  # HTTP
  #
  
  def upload_last_run
    http = Net::HTTP.new(upload_uri.host, upload_uri.port)
    resp = nil
    File.open(Fiveruns::Tuneup.run_files.last, 'rb') do |file|
      multipart = Fiveruns::Tuneup::Multipart.new(file, 'api_key' => @config['api_key'] )
     # Fiveruns::Tuneup.log :debug, multipart.to_s
      resp = http.post(upload_uri.request_uri, multipart.to_s, "Content-Type" => multipart.content_type)
    end
    case resp.code.to_i
    when 201
      return resp.body.strip rescue nil
    else
      Fiveruns::Tuneup.log :error, "Recieved bad response from service (#{resp.inspect})"
      return false
    end
  rescue Exception => e
    Fiveruns::Tuneup.log :error, "Could not upload: #{e.message}"
    false
  end
    
  def upload_uri
    @upload_uri ||= URI.parse("#{Fiveruns::Tuneup.collector_url}/runs")
  end
  
end