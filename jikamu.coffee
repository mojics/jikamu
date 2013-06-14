###
Global Variables for EcommApp
###

window.EcommApp ?= {}


EcommApp = (config) -> 
  _app = new EcommApp.App();
  EcommApp.$ ->
    _app.start()
  _app


###
Debug Mode - Set false hide log messages
@author Ronald Allan Mojica
###

window.EcommApp.DEBUG = true


###
JS Tools
###

log = (log_message) -> 
  window.EcommApp.DEBUG && window.console and console.log log_message

###
Check if jQuery library exists along with jQuery Address
###
EcommApp.$ = if window.jQuery 
  jQuery 

EcommApp.$.address = if EcommApp.$.address
  EcommApp.$.address 


###
EcommApp Application
###

class EcommApp.App  
    running: false
    listener: false

    ###
    HandleRequest - will pass all possible parameters from Route to Page or 
    another
    ###
    @handleRequest: () ->
      status = false
      for route in EcommApp.routes
        route.urlpath.lastIndex = 0
        if route.urlpath.test(EcommApp.$.address.path()) 
            EcommApp.App.launcher(@,route.handler)
            if window.EcommApp.DEBUG then console.log "call controller for the url #{route.urlpath}"
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
      if current_handler instanceof EcommApp.Page
        
        afterLoad = (_self,_d) ->
          current_handler.properties.after_load.call(_self,_d)
        
        beforeLoad = () ->
          _deferred = new EcommApp.$.Deferred();
          EcommApp.$.when(current_handler.properties.before_load.call())
            .then -> _deferred.resolve();
          _deferred.promise();
        
        controllerLoad = ->
          _deferred = new EcommApp.$.Deferred();
          EcommApp.$.when(current_handler.properties.controller.call())
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
        throw "EcommApp.App : Invalid Page Controller"
      return
      
    ###
    startListener - With the help of jQuery address we will handle all 
    URL change with it.
    ###
    startListener: ->
      #JQUERY ADDRESS Initialization
      url_handler = EcommApp.App.handleRequest
      if window.location.hash 
        @listener = EcommApp.$(document).ready -> 
                      EcommApp.$.address.init ->
                        EcommApp.$('._address').address()
                        return
                      .bind 'change', ->
                        url_handler.call();
                        return
                      return
      return
    
    ###
    start App - the main function in order EcommApp to run
    ###
    start: ->
      if @running is true
        @handleRequest
        @
      else
        @running = true
        @startListener.call()
    ###
    Stop App - the main function in order EcommApp to run
    ###
    stop: ->
      @listener = null
      return
   
###
EcommApp.Page - provide the page template for EcommApp App 
  

###

class EcommApp.Page
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
      throw "EcommApp.Page: Invalid page_name"
    
  controller: (new_controller) ->
    #console.log @
    if typeof new_controller is "function"
      @properties.controller = new_controller
      @
    else
      throw "EcommApp.Page: Invalid controller this should be a function"
  ###
  @deprecated
  ###
  before_load: (new_before_load) ->
    if typeof new_before_load is "function"
      @properties.before_load = new_before_load
      @
    else
      throw "EcommApp.Page: Invalid before load callback this should be a function"
  
  ###
  @deprecated
  ###
  after_load: (new_after_load) ->
    if typeof new_after_load is "function"
      @properties.after_load = new_after_load
      @
    else 
      throw "EcommApp.Page: Invalid after load callback this should be a function"
 
 
 
###
EcommApp Router - Requires a Page object and this will be serve as the page for 
the Apps, and it will add the URL rules that will be needed by the Router Class 
later on.

Thanks to DavisJS and I got an idea how to match or create pattern for EcommApp.AppListener
###

  
EcommApp.routes = []

###
Regex pattern from DavisJS.coms
###
pathNameRegex = /:([\w\d]+)/g
pathNameReplacement = "([^/]+)"
splatNameRegex = /\*([\w\d]+)/g
splatNameReplacement = "(.*)"
nameRegex = /[:|\*]([\w\d]+)/g


class EcommApp.Route
  constructor: (route_config) ->
    @properties = 
      urlpath: false
      page: ->
  urlpath: (new_urlpath) ->
    if new_urlpath 
        @properties.urlpath = @convertUrlPathtoRegExp new_urlpath
        @
    else
        throw "EcommApp.Route: Empty or Invalid url path"
  
  page: (obj) ->
    @properties.page = new EcommApp.Page()
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
      if window.EcommApp.DEBUG then  console.log "Converts #{path} and it converts to #{new RegExp("^" + str + "$", "gi")}"
      new RegExp("^#{str}$","gi");
    else 
      if window.EcommApp.DEBUG then  console.log "Pass the original path variable"
      path
 
 ###
 Save Route - saves the current route object to the global variable EcommApp.routes

 @method: save
 
 ###
 save: ->
  _arr = {}
  _arr.urlpath = @properties.urlpath
  _arr.handler = @properties.page
  EcommApp.routes.push _arr
  
 