require 'rho/rhocontroller'
require 'helpers/browser_helper'

class EngineController < Rho::RhoController
  include BrowserHelper
   
  def showR_setup
    # Prompts user to choose engine before associating
    # values from barcode with attribute variables
    init(@params['Name'] = 'Pubmed', @params['URL'] = "http://www.ncbi.nlm.nih.gov/pubmed?", @params['search query'] = 'term')
    init(@params['Name'] = 'Bing', @params['URL'] = "http://www.bing.com/search?", @params['search query'] = 'q')
    init(@params['Name'] = 'Google', @params['URL'] = "http://www.google.com/search?", @params['search query'] = 'as_q')
    @engines = Engine.find(:all)
    $current_engine=""
    render :back => '/app/Engine/index'
  end
  
  def showR
    # Displays values from QR code to user.  This method
    # pulls the variables in the engine to a usable hash
    $engine_params = Hash.new
    $array = Array.new
    if $current_engine
      $engine_params.replace($current_engine.vars)
      $engine_params.delete(:source_id)
      $engine_params.delete(:object)
      $engine_params.delete(:count)
      $engine_params.delete(:URL)
      $engine_params.delete(:Name)
      $engine_params.each_pair do |key, val|
        $array.push(key)
      end
    end
    render :back => url_for(:action => :camera)
  end
  
  # GET /Engine
  def engindex
    init(@params['Name'] = 'Pubmed', @params['URL'] = "http://www.ncbi.nlm.nih.gov/pubmed?", @params['search query'] = 'term')
    init(@params['Name'] = 'Bing', @params['URL'] = "http://www.bing.com/search?", @params['search query'] = 'q')
    init(@params['Name'] = 'Google', @params['URL'] = "http://www.google.com/search?", @params['search query'] = 'as_q')
    
    @engines = Engine.find(:all)
    
    render :back => '/app/Engine/index'
  end
  
  ##################################
  def camera
    # Takes a picture and redirects to show_barcode
    
    if  $current_engine==''
      @engine = Engine.find(@params['engin'])
      Alert.show_popup("The engine you chose is looking for "+@engine.count+" attributes")
      $current_engine = @engine
      $engine_params = Hash.new
      $array = Array.new
      if $current_engine
        $engine_params.replace($current_engine.vars)
        $engine_params.delete(:source_id)
        $engine_params.delete(:object)
        $engine_params.delete(:count)
        $engine_params.delete(:URL)
        $engine_params.delete(:Name)
        $engine_params.each_pair do |key, val|
          $array.push(key)
        end
      end
      Camera::take_picture(url_for(:action => :show_barcode))
      #redirect :action => :index
    else 
      Camera::take_picture(url_for(:action => :show_barcode))
      #redirect :action => :index
    end
  end
  
  def show_barcode
    # Interprets a picture of a QR code into strings
    barcode = Barcode::barcode_recognize(Rho::RhoApplication::get_blob_path(@params['image_uri'])) 
    if barcode.length <= 0
      Alert.show_popup('The QR code was not recognized...please try again')
      WebView.navigate(url_for :action => :camera )
    else
      #save the value of the barcode in an array
      lines = barcode.split(/\r?\n/)
      #take each value form the the barcode and store it in a global variable
    
      #so there's a problem where hash codes sort everything in them alphabetically,
      #but this assigns all information from the QR code to the values contained in
      #the engine alphabetically.  I am unsure as to how to make this ordered in a 
      #different way as this is simply how the information is stored in the database
      
      $barcode = Hash.new

      if $array.length != lines.length
        Alert.show_popup("The QR code scanned does not match the specified engine")
        WebView.navigate(url_for :action => :showR_setup) 
      else
        (0..(lines.length - 1)).each do |line|
          $barcode[$array[line].to_s] = lines[line]
        end
        # redirects to showR, which allows the user to select
        # which variables to use
        WebView.navigate(url_for :action => :showR ) 
      end          
    end
  end
  
  def enter_setup
    # Prompts user to choose engine before manually 
    # filling fields
    init(@params['name'] = 'Pubmed', @params['url'] = "http://www.ncbi.nlm.nih.gov/pubmed?", @params['search query'] = 'term')
    init(@params['name'] = 'Bing', @params['url'] = "http://www.bing.com/search?", @params['search query'] = 'q')
    init(@params['name'] = 'Google', @params['url'] = "http://www.google.com/search?", @params['search query'] = 'as_q')
    @engines = Engine.find(:all)
    render :back => "app/Engine/index"
  end
  
  def enter
    # Takes the selected engine and places wanted attributes into a 
    # hash.  These are supplied to the html, where values are entered
    # for each field
    @engine = Engine.find(@params['engin'])
    $current_engine = @engine
    @hash = Hash.new
    if @engine
      @hash.replace(@engine.vars)
      @hash.delete(:source_id)
      @hash.delete(:object)
      @hash.delete(:count)
      @hash.delete(:URL)
      @hash.delete(:Name)
    end
    render :back => url_for(:action => :enter_setup)
  end
  
  def values   
    ##create a url based off of the dynamic information provided
    @engine = $current_engine
    @link=@engine.URL 
  
    hash = Hash.new
    hash.replace(@params["engine"])
    hash.each_pair do |name, value|
      @link = @link + (@engine.send(name)) + "=" + value  + "&"
    end
    @link = @link.strip
    ##navigate to the selected page
    WebView.navigate(@link)
   
  end
  

  def search
    # Creates a url from the information gathered from code and user
    # selection and redirects to said url, unless an error is found, 
    # in which case redirects to showR_setup (where the engine was 
    # intially chosen)
    if $current_engine
      @link = $current_engine.URL
      $barcode.each do |name, value|
        if @params[name.to_s] == 'on'
          @link = @link+($current_engine.send(name)) + "=" + ($barcode[name.to_s]) + "&"
        end
      end
      @link = @link.strip
      WebView.navigate(@link) 
    else
      Alert.show_popup('Engine was not found to start search')
      redirect_to :action => showR_setup
    end
    render :back => url_for(:action => :showR)
  end

  def init(name, url, query) 
    # method used to quickly add a simple engine to database
    f = Engine.find(:all, :conditions => { :Name => name} )
    if f == []
      p = Engine.new
      p.Name=name
      p.URL=url
      p.Query = query
      p.count="1"
      p.save
      
    end
  end

  # GET /Engine/{1}
  def show
    @engine = Engine.find(@params['id'])
    if @engine
      @hash = Hash.new
      @hash.replace(@engine.vars)
      @hash.delete(:source_id)
      @hash.delete(:object)
      @hash.delete(:count)
      render :action => :show, :back => url_for(:action => :engindex)
    else
      redirect :action => :engindex
    end
  end

  # GET /Engine/new
  def new
    $engine.count = @params['engine']['count']
    render :action => :new, :back => url_for(:action => :configure)
  end
  
  def new_setup
    # setup method that prompts user to select engine with which
    # to search
    $engine = Engine.new
    render :action => :new_setup, :back => url_for(:action => :configure)
  end

  # GET /Engine/configure
  def configure 
    @engines = Engine.find(:all)
   render :action => :configure, :back => url_for(:action => :engindex)
  end
  
  # GET /Engine/{1}/edit
  def edit
    # can not add new arguments to a search, but can update the 
    # variables as they will appear in the url
    @engine = Engine.find(@params['id'])
    @hash = Hash.new
    if @engine
      @hash.replace(@engine.vars)
      @hash.delete(:source_id)
      @hash.delete(:object)
      @hash.delete(:count)
      render :action => :edit, :back => url_for(:action => :configure)
    else
      redirect :action => :engindex
    end
  end

  # POST /Engine/create
  def create
    # setup arguments to pass to create
    @params['engine']['count'] = $engine.count
    
    (1..@params['engine']['count'].to_i).each do |i|
      @params['engine'][@params['engine']['key' + i.to_s]] = @params['engine']['val' + i.to_s]
      @params['engine'].delete('key' + i.to_s)
      @params['engine'].delete('val' + i.to_s)
    end 
    
    @engine = Engine.create(@params['engine'])
    redirect :action => :engindex
  end

  # POST /Engine/{1}/update
  def update
    @engine = Engine.find(@params['id'])
    @engine.update_attributes(@params['engine']) if @engine
    redirect :action => :engindex
  end

  # POST /Engine/{1}/delete
  def delete
    @engine = Engine.find(@params['id'])
    @engine.destroy if @engine
    redirect :action => :engindex  
  end
end
