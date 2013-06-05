/*
Global Variables for Jikamu
*/

var Jikamu, cashier_app, cashier_page, cashier_page_summary, cashier_route, jikamu_app, log, nameRegex, pathNameRegex, pathNameReplacement, splatNameRegex, splatNameReplacement, _ref;

if ((_ref = window.Jikamu) == null) {
  window.Jikamu = {};
}

Jikamu = function(config) {
  return this;
};

Jikamu.routes = [];

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
Check if jQuery library exists
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
      AddPage
      @params - Jikamu.RoutePage
  */


  App.prototype.addPage = function(new_page) {
    Jikamu.routes.push({
      "/deposit/onlinedebit/(*)": new_page
    });
    return this;
  };

  /*
      HandleRequest - will pass all possible parameters from Route to Page or another
  */


  App.handleRequest = function() {
    console.log("Handling Request ... ");
    console.log(Jikamu.$.address.pathNames());
    return this;
  };

  /*
      loadPage 
      @deprecated
  */


  App.prototype.loadPage = function(current_controller) {};

  App.routes;

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
    console.log("@running");
    console.log(this.running);
    if (this.running === true) {
      console.log("Jikamu.App Status : Running... ");
      this.handleRequest;
      return this;
    } else {
      this.running = true;
      return this.startListener.call();
    }
  };

  /*
      start App - the main function in order Jikamu to run
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
      before_load: function() {},
      after_load: function() {}
    };
  }

  Page.prototype.page_name = function(new_page_name) {
    this.properties.page_name = new_page_name;
    return this;
  };

  Page.prototype.controller = function(new_controller) {
    this.properties.controller = new_controller;
    return this;
  };

  Page.prototype.before_load = function(new_before_load) {
    this.properties.before_load = new_before_load;
    return this;
  };

  Page.prototype.after_load = function(new_after_load) {
    this.properties.after_load = new_after_load;
    return this;
  };

  return Page;

})();

/*
Cashier Router - Requires a Page object and this will be serve as the page for the Apps, 
  and it will add the URL rules that will be needed by the Router Class later on
  
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
      console.log("Converts " + path + " and it converts to " + str);
      return new RegExp("^" + str + "$", "gi");
    } else {
      console.log("Pass the original path variable");
      return path;
    }
  };

  return Route;

})();

/*
Jikamu Request

This will just inherit Jquery Address methods and properties
*/


Jikamu.Request = (function() {

  function Request(route_config) {
    this.address = Jikamu.$.address;
    this;

  }

  Request.prototype.concatPathNames = function() {
    console.log("oh yeah123444");
    console.log(this.address.path());
  };

  return Request;

})();

/*
Test Jikamu Page
*/


cashier_page = new Jikamu.Page().page_name('deposit').controller(function() {
  return console.log("Main page");
}).after_load(function() {
  return console.log("after loading");
}).before_load(function() {
  return console.log("before loading page");
});

cashier_page_summary = new Jikamu.Page().page_name('summary').controller(function() {
  return console.log("Main page");
}).after_load(function() {
  return console.log("after loading");
}).before_load(function() {
  return console.log("before loading page");
});

cashier_route = new Jikamu.Route().urlpath('/test/').page(new Jikamu.Page());

/*
Test CashierAPP
*/


console.log("#### JIKAMUJS ####");

cashier_app = new Jikamu.App;

cashier_app.addPage(cashier_page);

cashier_app.addPage(cashier_page_summary);

console.log(cashier_app);

console.log("#### Route TEST ####");

console.log(cashier_route.properties);

console.log("#### Jikamu jQuery Address ####");

console.log(Jikamu.$.address);

console.log("#### Jikamu App ####");

jikamu_app = new Jikamu.App();

jikamu_app.start();

console.log(jikamu_app);

jikamu_app.start();

console.log("#### Jikamu Request####");

console.log(new Jikamu.Request().concatPathNames());
