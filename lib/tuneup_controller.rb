require 'net/https'
require 'ostruct'
require 'open-uri'

class TuneupController < ActionController::Base
      
  def show
    render :update do |page|
      page << tuneup_reload_panel
    end
  end
  
  def update
    @config.update(params[:config])
    @config.save!
    redirect_to :action => 'show'
  end
  
  def signin
    if api_key = retrieve_api_key
      @config['api_key'] = api_key
      @config.save!
    end
    render :update do |page|
      if api_key
        page << tuneup_reload_panel
      else
        page << tuneup_show_flash(:error,
                  :header => "TuneUp encountered an error",
                  :message => "Could not access your FiveRuns TuneUp account.")
      end
    end
  end
  
  def upload
    token = upload_run
    render :update do |page|
      if token
        link = link_to_function("here", tuneup_open_run(token))
        page << tuneup_show_flash(:notice,
                  :header => 'Run Uploaded to TuneUp',
                  :message => "View your run #{link}.")
      else
        page << tuneup_show_flash(:error,
                  :header => "TuneUp encountered an error",
                  :message => "Could not upload run to your FiveRuns TuneUp account.")
      end
    end
  end
  
  def asset
    filename = File.basename(params[:file])
    if filename =~ /css$/
      response.content_type = 'text/css'
    end
    send_file File.join(File.dirname(__FILE__) << "/../assets/#{filename}")
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
    render(:update) { |p| p['tuneup-panel'].replace(render(:partial => 'tuneup/panel/registered')) }
  end

  def find_config
    @config = TuneupConfig.new
  end
  
  #
  # HTTP
  #
  
  def upload_run
    safely do
      http = Net::HTTP.new(upload_uri.host, upload_uri.port)
      http.use_ssl = true if Fiveruns::Tuneup.collector_url =~ /^https/
      resp = nil
      # TODO: Support targeted upload
      filename = Fiveruns::Tuneup.last_filename_for_run_uri(params[:uri])
      Fiveruns::Tuneup.log :debug, "Uploading #{filename} for URI #{params[:uri]}"
      File.open(filename, 'rb') do |file|
        multipart = Fiveruns::Tuneup::Multipart.new(file, 'api_key' => @config['api_key'] )
       # Fiveruns::Tuneup.log :debug, multipart.to_s
        resp = http.post(upload_uri.request_uri, multipart.to_s, "Content-Type" => multipart.content_type)
      end
      case resp.code.to_i
      when 201
        return resp.body.strip rescue nil
      else
        Fiveruns::Tuneup.log :error, "Received bad response from service (#{resp.inspect})"
        return false
      end
    end
  end
  
  def retrieve_api_key
    safely do
      http = Net::HTTP.new(api_key_uri.host, api_key_uri.port)
      http.use_ssl = true if Fiveruns::Tuneup.collector_url =~ /^https/
      data = "email=#{CGI.escape(params[:email])}&password=#{CGI.escape(params[:password])}"
      resp = http.post(api_key_uri.path, data, "Content-Type" => "application/x-www-form-urlencoded")
      case resp.code.to_i
      when 200..299
        resp.body.strip rescue nil
      else
        Fiveruns::Tuneup.log :error, "Received bad response from service (#{resp.inspect})"
        false
      end
    end
  end
  
  def safely
    yield
  rescue Exception => e
    Fiveruns::Tuneup.log :error, "Could not access service: #{e.message}"
    false
  end
  
  def api_key_uri
    @api_key_uri ||= URI.parse("#{Fiveruns::Tuneup.collector_url}/users")
  end
    
  def upload_uri
    @upload_uri ||= URI.parse("#{Fiveruns::Tuneup.collector_url}/runs")
  end
  
end