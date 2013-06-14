/*
Global Variables for EcommApp
*/

var EcommApp, log, nameRegex, pathNameRegex, pathNameReplacement, splatNameRegex, splatNameReplacement;

if (window.EcommApp == null) {
  window.EcommApp = {};
}

EcommApp = function(config) {
  var _app;
  _app = new EcommApp.App();
  EcommApp.$(function() {
    return _app.start();
  });
  return _app;
};

/*
Debug Mode - Set false hide log messages
@author Ronald Allan Mojica
*/


window.EcommApp.DEBUG = true;

/*
JS Tools
*/


log = function(log_message) {
  return window.EcommApp.DEBUG && window.console && console.log(log_message);
};

/*
Check if jQuery library exists along with jQuery Address
*/


EcommApp.$ = window.jQuery ? jQuery : void 0;

EcommApp.$.address = EcommApp.$.address ? EcommApp.$.address : void 0;

/*
EcommApp Application
*/


EcommApp.App = (function() {
  function App() {}

  App.prototype.running = false;

  App.prototype.listener = false;

  /*
  HandleRequest - will pass all possible parameters from Route to Page or 
  another
  */


  App.handleRequest = function() {
    var route, status, _i, _len, _ref;
    status = false;
    _ref = EcommApp.routes;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      route = _ref[_i];
      route.urlpath.lastIndex = 0;
      if (route.urlpath.test(EcommApp.$.address.path())) {
        EcommApp.App.launcher(this, route.handler);
        if (window.EcommApp.DEBUG) {
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
    if (current_handler instanceof EcommApp.Page) {
      afterLoad = function(_self, _d) {
        return current_handler.properties.after_load.call(_self, _d);
      };
      beforeLoad = function() {
        var _deferred;
        _deferred = new EcommApp.$.Deferred();
        EcommApp.$.when(current_handler.properties.before_load.call()).then(function() {
          return _deferred.resolve();
        });
        return _deferred.promise();
      };
      controllerLoad = function() {
        var _deferred;
        _deferred = new EcommApp.$.Deferred();
        EcommApp.$.when(current_handler.properties.controller.call()).then(function() {
          return _deferred.resolve();
        });
        return _deferred.promise();
      };
      console.log(current_handler.properties.page_name);
      document.title = current_handler.properties.page_name;
      $.when(beforeLoad.call()).then(function() {
        console.log('Loaded bootstrap files');
        return $.when(controllerLoad.call()).then(function() {
          console.log('Next is the Callback function');
          return afterLoad.call();
        });
      });
      return;
    } else {
      throw "EcommApp.App : Invalid Page Controller";
    }
  };

  /*
  startListener - With the help of jQuery address we will handle all 
  URL change with it.
  */


  App.prototype.startListener = function() {
    var url_handler;
    url_handler = EcommApp.App.handleRequest;
    if (window.location.hash) {
      this.listener = EcommApp.$(document).ready(function() {
        EcommApp.$.address.init(function() {
          EcommApp.$('._address').address();
        }).bind('change', function() {
          url_handler.call();
        });
      });
    }
  };

  /*
  start App - the main function in order EcommApp to run
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
  Stop App - the main function in order EcommApp to run
  */


  App.prototype.stop = function() {
    this.listener = null;
  };

  return App;

})();

/*
EcommApp.Page - provide the page template for EcommApp App
*/


EcommApp.Page = (function() {
  function Page() {
    this.properties = {
      page_name: false,
      controller: function() {},
      before_load: function() {},
      after_load: function() {}
    };
  }

  Page.prototype.page_name = function(new_page_name) {
    if (new_page_name) {
      this.properties.page_name = new_page_name;
      return this;
    } else {
      throw "EcommApp.Page: Invalid page_name";
    }
  };

  Page.prototype.controller = function(new_controller) {
    if (typeof new_controller === "function") {
      this.properties.controller = new_controller;
      return this;
    } else {
      throw "EcommApp.Page: Invalid controller this should be a function";
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
      throw "EcommApp.Page: Invalid before load callback this should be a function";
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
      throw "EcommApp.Page: Invalid after load callback this should be a function";
    }
  };

  return Page;

})();

/*
EcommApp Router - Requires a Page object and this will be serve as the page for 
the Apps, and it will add the URL rules that will be needed by the Router Class 
later on.

Thanks to DavisJS and I got an idea how to match or create pattern for EcommApp.AppListener
*/


EcommApp.routes = [];

/*
Regex pattern from DavisJS.coms
*/


pathNameRegex = /:([\w\d]+)/g;

pathNameReplacement = "([^/]+)";

splatNameRegex = /\*([\w\d]+)/g;

splatNameReplacement = "(.*)";

nameRegex = /[:|\*]([\w\d]+)/g;

EcommApp.Route = (function() {
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
      throw "EcommApp.Route: Empty or Invalid url path";
    }
  };

  Route.prototype.page = function(obj) {
    this.properties.page = new EcommApp.Page().page_name(obj.page_name).controller(obj.controller).before_load(obj.before_load).after_load(obj.after_load);
    return this;
  };

  Route.prototype.convertUrlPathtoRegExp = function(path) {
    var str;
    if (!(path instanceof RegExp)) {
      str = path.replace(pathNameRegex, pathNameReplacement).replace(splatNameRegex, splatNameReplacement);
      path.lastIndex = 0;
      if (window.EcommApp.DEBUG) {
        console.log("Converts " + path + " and it converts to " + (new RegExp("^" + str + "$", "gi")));
      }
      return new RegExp("^" + str + "$", "gi");
    } else {
      if (window.EcommApp.DEBUG) {
        console.log("Pass the original path variable");
      }
      return path;
    }
  };

  return Route;

})();

({
  /*
  Save Route - saves the current route object to the global variable EcommApp.routes
  
  @method: save
  */

  save: function() {
    var _arr;
    _arr = {};
    _arr.urlpath = this.properties.urlpath;
    _arr.handler = this.properties.page;
    return EcommApp.routes.push(_arr);
  }
});
