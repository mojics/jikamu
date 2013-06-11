/*
Global Variables for Jikamu
*/

var Jikamu, log, nameRegex, pathNameRegex, pathNameReplacement, splatNameRegex, splatNameReplacement, _ref;

if ((_ref = window.Jikamu) == null) {
  window.Jikamu = {};
}

Jikamu.routes = [];

/*
Regex pattern from DavisJS.coms
*/


pathNameRegex = /:([\w\d]+)/g;

pathNameReplacement = "([^/]+)";

splatNameRegex = /\*([\w\d]+)/g;

splatNameReplacement = "(.*)";

nameRegex = /[:|\*]([\w\d]+)/g;

/*
Debug Mode - Set false hide log messages
*/


window.Jikamu.DEBUG = true;

/*
JS Tools
*/


log = function(log_message) {
  return window.Jikamu.DEBUG && window.console && console.log(log_message);
};

/*
Check if jQuery library exists along with jQuery Address
*/


Jikamu.$ = window.jQuery ? jQuery : void 0;

Jikamu.$.address = Jikamu.$.address ? Jikamu.$.address : void 0;

Jikamu = function(config) {
  return this;
};

/*
Jikamu Application
*/


Jikamu.App = (function() {

  function App() {}

  App.prototype.running = false;

  App.prototype.listener = false;

  /*
      HandleRequest - will pass all possible parameters from Route to Page or 
      another
  */


  App.handleRequest = function() {
    var route, status, _i, _len, _ref1;
    status = false;
    _ref1 = Jikamu.routes;
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      route = _ref1[_i];
      route.urlpath.lastIndex = 0;
      if (route.urlpath.test(Jikamu.$.address.path())) {
        Jikamu.App.launcher(this, route.handler);
        if (window.Jikamu.DEBUG) {
          console.log("call controller for the url " + route.urlpath);
        }
        status = true;
        break;
      }
    }
    if (status === false) {
      document.title = 'Not Found';
      console.log("Handle not found route rule");
    }
  };

  /*
      loadPage
  */


  App.launcher = function(_this, current_handler) {
    var afterLoad, beforeLoad, controllerLoad;
    if (current_handler instanceof Jikamu.Page) {
      afterLoad = function() {
        return current_handler.properties.after_load.apply();
      };
      beforeLoad = function() {
        return current_handler.properties.before_load.apply();
      };
      controllerLoad = function(_self, callback) {
        return current_handler.properties.controller.apply(_self, callback);
      };
      console.log(current_handler.properties.page_name);
      document.title = current_handler.properties.page_name;
      $.when(beforeLoad.apply()).then(function() {
        console.log('Loaded bootstrap files');
        return $.when(controllerLoad.apply(_this, afterLoad)).then(function() {
          console.log('Next is the Callback function');
          return afterLoad.apply();
        });
      });
      return;
    } else {
      throw "Jikamu.App : Invalid Page Controller";
    }
  };

  /*
      startListener - With the help of jQuery address we will handle all 
      URL change with it.
  */


  App.prototype.startListener = function() {
    var url_handler;
    url_handler = Jikamu.App.handleRequest;
    if (window.location.hash) {
      this.listener = Jikamu.$(document).ready(function() {
        Jikamu.$.address.init(function() {
          Jikamu.$('._address').address();
        }).bind('change', function() {
          url_handler.call();
        });
      });
    }
  };

  /*
      start App - the main function in order Jikamu to run
  */


  App.prototype.start = function() {
    if (this.running === true) {
      this.handleRequest;
      return this;
    } else {
      this.running = true;
      return this.startListener.call();
    }
  };

  /*
      Stop App - the main function in order Jikamu to run
  */


  App.prototype.stop = function() {
    this.listener = null;
  };

  return App;

})();

/*
Jikamu.Page - provide the page template for Jikamu App
*/


Jikamu.Page = (function() {

  function Page() {
    this.properties = {
      page_name: false,
      controller: function() {},
      before_load: function() {
        return true;
      },
      after_load: function() {
        return true;
      }
    };
  }

  Page.prototype.page_name = function(new_page_name) {
    if (new_page_name) {
      this.properties.page_name = new_page_name;
      return this;
    } else {
      throw "Jikamu.Page: Invalid page_name";
    }
  };

  Page.prototype.controller = function(new_controller) {
    if (typeof new_controller === "function") {
      this.properties.controller = new_controller;
      return this;
    } else {
      throw "Jikamu.Page: Invalid controller this should be a function";
    }
  };

  /*
    @deprecated
  */


  Page.prototype.before_load = function(new_before_load) {
    if (typeof new_before_load === "function") {
      this.properties.before_load = new_before_load;
      return this;
    } else {
      throw "Jikamu.Page: Invalid before load callback this should be a function";
    }
  };

  /*
    @deprecated
  */


  Page.prototype.after_load = function(new_after_load) {
    if (typeof new_after_load === "function") {
      this.properties.after_load = new_after_load;
      return this;
    } else {
      throw "Jikamu.Page: Invalid after load callback this should be a function";
    }
  };

  return Page;

})();

/*
Cashier Router - Requires a Page object and this will be serve as the page for 
the Apps, and it will add the URL rules that will be needed by the Router Class 
later on.

Thanks to DavisJS and I got an idea how to match or create pattern for Jikamu.AppListener
*/


Jikamu.Route = (function() {

  function Route(route_config) {
    this.properties = {
      urlpath: false,
      page: function() {}
    };
  }

  Route.prototype.urlpath = function(new_urlpath) {
    if (new_urlpath) {
      this.properties.urlpath = this.convertUrlPathtoRegExp(new_urlpath);
      return this;
    } else {
      throw "Jikamu.Route: Empty or Invalid url path";
    }
  };

  Route.prototype.page = function(new_page) {
    if (new_page instanceof Jikamu.Page) {
      this.properties.page = new_page;
      return this;
    } else {
      throw "Jikamu.Route Error: Invalid data type on adding page, this requires a Page object";
    }
  };

  Route.prototype.convertUrlPathtoRegExp = function(path) {
    var str;
    if (!(path instanceof RegExp)) {
      str = path.replace(pathNameRegex, pathNameReplacement).replace(splatNameRegex, splatNameReplacement);
      path.lastIndex = 0;
      if (window.Jikamu.DEBUG) {
        console.log("Converts " + path + " and it converts to " + (new RegExp("^" + str + "$", "gi")));
      }
      return new RegExp("^" + str + "$", "gi");
    } else {
      if (window.Jikamu.DEBUG) {
        console.log("Pass the original path variable");
      }
      return path;
    }
  };

  /*
   Save Route - saves the current route object to the global variable Jikamu.routes
  
   @method: save
  */


  Route.prototype.save = function() {
    var _arr;
    _arr = {};
    _arr.urlpath = this.properties.urlpath;
    _arr.handler = this.properties.page;
    Jikamu.routes.push(_arr);
    return this;
  };

  return Route;

})();
