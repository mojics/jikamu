###
Global Variables for Jikamu
###

window.Jikamu ?= {}


Jikamu = (config) -> 
  _app = new Jikamu.App();
  Jikamu.$ ->
    _app.start()
  _app


###
Debug Mode - Set false hide log messages
@author Ronald Allan Mojica
###

window.Jikamu.DEBUG = true


###
JS Tools
### 

log = (log_message) -> 
  window.Jikamu.DEBUG && window.console and console.log log_message

###
Check if jQuery library exists along with jQuery Address
###
Jikamu.$ = if window.jQuery 
  jQuery 

Jikamu.$.address = if Jikamu.$.address
  Jikamu.$.address 


###
Jikamu Application
###

class Jikamu.App  
    running: false
    listener: false

    ###
    HandleRequest - will pass all possible parameters from Route to Page or 
    another
    ###
    @handleRequest: () ->
      status = false
      for route in Jikamu.routes
        route.urlpath.lastIndex = 0
        if route.urlpath.test(Jikamu.$.address.path()) 
            Jikamu.App.launcher(@,route.handler)
            if window.Jikamu.DEBUG then console.log "call controller for the url #{route.urlpath}"
            status = true
            break
      if status is false
        document.title = 'Not Found'
        console.log "Handle not found route rule"
      
      return
    
    
    
    ###
    loadPage     
    ### 
    @launcher: (_this, current_handler) ->   
      if current_handler instanceof Jikamu.Page
        
        afterLoad = (_self,_d) ->
          current_handler.properties.after_load.call(_self,_d)
        
        beforeLoad = () ->
          _deferred = new Jikamu.$.Deferred();
          Jikamu.$.when(current_handler.properties.before_load.call())
            .then -> _deferred.resolve();
          _deferred.promise();
        
        controllerLoad = ->
          _deferred = new Jikamu.$.Deferred();
          Jikamu.$.when(current_handler.properties.controller.call())
            .then -> _deferred.resolve();
          _deferred.promise();
        
        console.log current_handler.properties.page_name
        document.title = current_handler.properties.page_name
        #controllerLoad.apply(_this,afterLoad)
        
        $.when(beforeLoad.call())
          .then ->
            console.log 'Loaded bootstrap files'; 
            $.when(controllerLoad.call())
              .then ->
                console.log 'Next is the Callback function'; 
                afterLoad.call();
                
        return

      else
        throw "Jikamu.App : Invalid Page Controller"
      return
      
    ###
    startListener - With the help of jQuery address we will handle all 
    URL change with it.
    ###
    startListener: ->
      #JQUERY ADDRESS Initialization
      url_handler = Jikamu.App.handleRequest
      if window.location.hash 
        @listener = Jikamu.$(document).ready -> 
                      Jikamu.$.address.init ->
                        Jikamu.$('._address').address()
                        return
                      .bind 'change', ->
                        url_handler.call();
                        return
                      return
      return
    
    ###
    start App - the main function in order Jikamu to run
    ###
    start: ->
      if @running is true
        @handleRequest
        @
      else
        @running = true
        @startListener.call()
    ###
    Stop App - the main function in order Jikamu to run
    ###
    stop: ->
      @listener = null
      return
   
###
Jikamu.Page - provide the page template for Jikamu App 
  

###

class Jikamu.Page
  constructor: ->
    @properties = 
      page_name: false
      controller: -> 
      before_load:  -> 
      after_load: -> 

  page_name: (new_page_name) ->
    if new_page_name
      @properties.page_name = new_page_name;
      @
    else
      throw "Jikamu.Page: Invalid page_name"
    
  controller: (new_controller) ->
    #console.log @
    if typeof new_controller is "function"
      @properties.controller = new_controller
      @
    else
      throw "Jikamu.Page: Invalid controller this should be a function"
  ###
  @deprecated
  ###
  before_load: (new_before_load) ->
    if typeof new_before_load is "function"
      @properties.before_load = new_before_load
      @
    else
      throw "Jikamu.Page: Invalid before load callback this should be a function"
  
  ###
  @deprecated
  ###
  after_load: (new_after_load) ->
    if typeof new_after_load is "function"
      @properties.after_load = new_after_load
      @
    else 
      throw "Jikamu.Page: Invalid after load callback this should be a function"
 
 
 
###
Jikamu Router - Requires a Page object and this will be serve as the page for 
the Apps, and it will add the URL rules that will be needed by the Router Class 
later on.

Thanks to DavisJS and I got an idea how to match or create pattern for Jikamu.AppListener
###

  
Jikamu.routes = []

###
Regex pattern from DavisJS.coms
###
pathNameRegex = /:([\w\d]+)/g
pathNameReplacement = "([^/]+)"
splatNameRegex = /\*([\w\d]+)/g
splatNameReplacement = "(.*)"
nameRegex = /[:|\*]([\w\d]+)/g


class Jikamu.Route
  constructor: (route_config) ->
    @properties = 
      urlpath: false
      page: ->
  urlpath: (new_urlpath) ->
    if new_urlpath 
        @properties.urlpath = @convertUrlPathtoRegExp new_urlpath
        @
    else
        throw "Jikamu.Route: Empty or Invalid url path"
  
  page: (obj) ->
    @properties.page = new Jikamu.Page()
      .page_name(obj.page_name)
      .controller(obj.controller)
      .before_load(obj.before_load)
      .after_load(obj.after_load)
    @
    
    
  
  convertUrlPathtoRegExp: (path) ->
    if path not instanceof RegExp
      str = path.replace(pathNameRegex, pathNameReplacement)
               .replace(splatNameRegex, splatNameReplacement)
      path.lastIndex = 0;
      if window.Jikamu.DEBUG then  console.log "Converts #{path} and it converts to #{new RegExp("^" + str + "$", "gi")}"
      new RegExp("^#{str}$","gi");
    else 
      if window.Jikamu.DEBUG then  console.log "Pass the original path variable"
      path

  ###
  Save Route - saves the current route object to the global variable Jikamu.routes

  @method: save

  ###
  save: ->
    _arr = {}
    _arr.urlpath = @properties.urlpath
    _arr.handler = @properties.page
    Jikamu.routes.push _arr

 