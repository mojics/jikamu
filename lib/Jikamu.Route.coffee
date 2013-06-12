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
  @