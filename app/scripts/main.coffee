# global require*/
'use strict'

require.config
  shim:
    underscore:
      exports: '_'
    backbone:
      deps: ['underscore','jquery']
      exports: 'Backbone'
    bootstrap:
      deps: ['jquery']
      exports: 'jquery'
    d3:
      exports: 'd3'

  paths:
    d3: '../bower_components/d3/d3',
    jquery: '../bower_components/jquery/jquery',
    backbone: '../bower_components/backbone/backbone',
    underscore: '../bower_components/underscore/underscore',
    bootstrap: 'vendor/bootstrap'

require ['jquery', 'd3', 'bubble_graph'], ($, d3, BubbleGraph)->
  $(document).ready ->
    window.graph = new BubbleGraph(document.getElementById("visualization"), "data/beervana.csv")
