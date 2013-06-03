###
Global Variables for Jikamu
###
window.Jikamu ?= {}

Jikamu = (config) -> 
	@

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
	routes: []		
	addPage: (_page) -> 		
		@routes.push  "deposit/onlinedebit/(*)":_page
		@	
	handleRequest: () ->
		@
	loadPage: (current_controller) ->	 	
		@routes[1]
		

###
Jikamu.Page - Handles Routing for pages in Cashier 
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
Cashier Router
Requires a Page object and this will be serve as the page for the Apps, and it will add the URL rules that will be needed by the Router Class later on
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
	
	page: (new_page) ->
		if new_page instanceof Jikamu.Page
			@properties.page = new_page	
			@
		else
			throw "Jikamu.Route Error: Invalid data type on adding page"

	convertUrlPathtoRegExp: (path) ->
		if path not instanceof RegExp
			str = path.replace(pathNameRegex, pathNameReplacement)
							 .replace(splatNameRegex, splatNameReplacement)
			path.lastIndex = 0;
			log "Converts #{path} and it converts to #{str}"
			new RegExp("^" + str + "$", "gi");
		else 
			log "Pass the original path variable"
			path







###
Test Jikamu Page
###

cashier_page = new Jikamu.Page()
				.page_name('deposit')
				.controller(-> log "Main page")
				.after_load(-> log "after loading")
				.before_load(-> log "before loading page")


cashier_page_summary = new Jikamu.Page()
				.page_name('summary')
				.controller(-> log "Main page")
				.after_load(-> log "after loading")
				.before_load(-> log "before loading page")
cashier_route = new Jikamu.Route()
			.urlpath('/test/')
			.page(
				new Jikamu.Page()
			)
			
###
Test CashierAPP
###

log "#### JIKAMUJS ####"
cashier_app = new Jikamu.App;
cashier_app.addPage cashier_page
cashier_app.addPage cashier_page_summary
log cashier_app 

log "#### Route TEST ####"
log cashier_route.properties
log "#### Jikamu jQuery Address ####"
log Jikamu.$.address.path.call()
