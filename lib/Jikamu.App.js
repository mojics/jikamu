// Generated by CoffeeScript 1.6.2
/*
Global Variables for Jikamu
*/

var Jikamu, log, _ref;

if ((_ref = window.Jikamu) == null) {
  window.Jikamu = {};
}

Jikamu = function(config) {
  var _app;

  _app = new Jikamu.App();
  Jikamu.$(function() {
    return _app.start();
  });
  return _app;
};

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
