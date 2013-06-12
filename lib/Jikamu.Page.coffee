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
 
 