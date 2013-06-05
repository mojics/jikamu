###
Global Variables for Jikamu
###

window.Jikamu ?= {}

Jikamu = (config) -> 
	@

Jikamu.routes = []

pathNameRegex = /:([\w\d]+)/g
pathNameReplacement = "([^/]+)"
splatNameRegex = /\*([\w\d]+)/g
splatNameReplacement = "(.*)"
nameRegex = /[:|\*]([\w\d]+)/g


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
Check if jQuery library exists
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
    AddPage
    @params - Jikamu.RoutePage
    ###
    addPage: (new_page) -> 		
      Jikamu.routes.push  "/deposit/onlinedebit/(*)":new_page
      @
    ###
    HandleRequest - will pass all possible parameters from Route to Page or another
    ###
    @handleRequest: () ->
      console.log "Handling Request ... "
      console.log Jikamu.$.address.pathNames()
      @
    ###
    loadPage 
    @deprecated
    ###
    loadPage: (current_controller) ->	 	
  		@routes
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
      console.log "@running"
      console.log @running
      if @running is true
        console.log "Jikamu.App Status : Running... "
        @handleRequest
        @
      else
        @running = true
        @startListener.call()
    ###
    start App - the main function in order Jikamu to run
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
		@properties.page_name = new_page_name;
		@
	controller: (new_controller) ->
		@properties.controller = new_controller
		@
	before_load: (new_before_load) ->
		@properties.before_load = new_before_load
		@
	after_load: (new_after_load) ->
		@properties.after_load = new_after_load
		@
 
 
 
 
 
 
###
Cashier Router - Requires a Page object and this will be serve as the page for the Apps, 
  and it will add the URL rules that will be needed by the Router Class later on
  
Thanks to DavisJS and I got an idea how to match or create pattern for Jikamu.AppListener
###

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
	
	page: (new_page) ->
		if new_page instanceof Jikamu.Page
			@properties.page = new_page	
			@
		else
			throw "Jikamu.Route Error: Invalid data type on adding page, this requires a Page object"

	convertUrlPathtoRegExp: (path) ->
		if path not instanceof RegExp
			str = path.replace(pathNameRegex, pathNameReplacement)
							 .replace(splatNameRegex, splatNameReplacement)
			path.lastIndex = 0;
			console.log "Converts #{path} and it converts to #{str}"
			new RegExp("^" + str + "$", "gi");
		else 
			console.log "Pass the original path variable"
			path


###
Jikamu Request

This will just inherit Jquery Address methods and properties
###
class Jikamu.Request 
  constructor: (route_config) ->
      @address = Jikamu.$.address
      @
  concatPathNames: ->  
      console.log "oh yeah123444"
      console.log @address.path()
      return
    
 




###
Test Jikamu Page
###

cashier_page = new Jikamu.Page()
				.page_name('deposit')
				.controller(-> console.log "Main page")
				.after_load(-> console.log "after loading")
				.before_load(-> console.log "before loading page")


cashier_page_summary = new Jikamu.Page()
				.page_name('summary')
				.controller(-> console.log "Main page")
				.after_load(-> console.log "after loading")
				.before_load(-> console.log "before loading page")
cashier_route = new Jikamu.Route()
			.urlpath('/test/')
			.page(
				new Jikamu.Page()
			)
			
###
Test CashierAPP
###

console.log "#### JIKAMUJS ####"
cashier_app = new Jikamu.App;
cashier_app.addPage cashier_page
cashier_app.addPage cashier_page_summary
console.log cashier_app 

console.log "#### Route TEST ####"
console.log cashier_route.properties
console.log "#### Jikamu jQuery Address ####"
console.log Jikamu.$.address



console.log "#### Jikamu App ####"

jikamu_app = new Jikamu.App()
jikamu_app.start();
console.log jikamu_app

jikamu_app.start();

console.log "#### Jikamu Request####"
console.log new Jikamu.Request().concatPathNames()
