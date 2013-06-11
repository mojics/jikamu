#JikamuJS - A very simple JS App

##A very simple Introduction
JikamuJS will be built using Coffeescript, and requires jQuery and jQuery.address for the URL Routing.

The main inspiration of this simple application is DavisJS which currently support HTML5 browsers. DavisJS is a router application that use HTML5 history.pushState.

With the help of jQuery.address url routing api, JikamuJS will target not only new browser but also older browsers(I'm talking to you Internet Explorer).

##Requirements

JikamuJS requires jQuery 1.7.2+ and the latest jQuery Address

##Usage

###Adding a new Route with your page

    new Jikamu.Route()
        .urlpath('/blog')
        .page(
            {
                page_name: "Blog Page",
                controller: function(){
                    $("#container").html('Blog Page');
                },
                before_load:function(){
                    console.log('Before loading Blog page');
                },
                after_load:function(){
                    console.log('After loading blog page');
                }
            }
        )
        .save();

 ###Starting your App

    new Jikamu.App().start();