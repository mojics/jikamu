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

        afterLoad = ->
          current_handler.properties.after_load.apply()
        
        beforeLoad = ->
          current_handler.properties.before_load.apply()
        
        controllerLoad = (_self, callback) ->
          current_handler.properties.controller.apply(_self, callback)
        console.log current_handler.properties.page_name
        document.title = current_handler.properties.page_name
        #controllerLoad.apply(_this,afterLoad)
        
        $.when(beforeLoad.apply())
          .then ->
            console.log 'Loaded bootstrap files'; 
            $.when(controllerLoad.apply(_this,afterLoad))
              .then ->
                console.log 'Next is the Callback function'; 
                afterLoad.apply();
                
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