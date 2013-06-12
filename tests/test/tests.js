var _page = new Jikamu.Page();
var _route = new Jikamu.Route();
test( "Creating a new Page", function() {
	function Error( message ) {
    this.message = message;
  }
 
  Error.prototype.toString = function() {
    return this.message;
  };
 

  	ok(_page.page_name('Test'), "Create a page with page name Test with controller" );
	ok(_page.page_name('Test').controller(function(){}), "Create a page with page name and a controller" );
	ok(_page.page_name('Test').controller(function(){}).before_load(function(){})
		, "Create a page with page name, controller and before_load" );
  	throws(
  		function(){
  			try{
  				_page.page_name('Test').controller();
  			}catch(e){
  				console.log(e);
  				throw new Error(e);
  			}
  			
  		},
  		/Invalid controller/,
  		"Throws Error with blank controller" );

  	throws(
  		function(){
  			try{
  				_page.page_name('Test').controller('s');
  			}catch(e){
  				console.log(e);
  				throw new Error(e);
  			}
  			
  		},
  		/should be a function/,
  		"Throws Error with invalid format type this should be a function" );

  	throws(
  		function(){
  			try{
  				_page.page_name('Test').controller(function(){}).before_load();
  			}catch(e){
  				console.log(e);
  				throw new Error(e);
  			}
  			
  		},
  		/Invalid before load callback/,
  		"Throws Error with blank before_load" );

  	throws(
  		function(){
  			try{
  				_page.page_name('Test').controller(function(){}).before_load('test');
  			}catch(e){
  				console.log(e);
  				throw new Error(e);
  			}
  			
  		},
  		/Invalid before load callback/,
  		"Throws Error with blank before_load with a text input not a function" );


});

test( "Creating a new Route", function() {
  	ok(_route.urlpath('/'), "Added / route" );
  	ok(_route.urlpath('/blog'), "Route for /blog" );
  	ok(_route.urlpath('/blog/:name'), "Route for /blog/:name" );
  	ok(_route.urlpath('/posts/*postname'), "Route for /posts/*splats format" );
});
