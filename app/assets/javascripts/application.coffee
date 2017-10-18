# This is a manifest file that'll be compiled into application.js, which will
# include all the files listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts,
# vendor/assets/javascripts, or any plugin's vendor/assets/javascripts directory
# can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at
# the bottom of the compiled file. JavaScript code in this file should be added
# after the last require_* statement.
#
# Read Sprockets README
# (https://github.com/rails/sprockets#sprockets-directives)
# for details about supported directives.
#
#= require jquery3
#= require rails-ujs
#= require turbolinks
#= require popper
#= require bootstrap

# Main JS initializer
#= require global

# External
#= require external/bootstrap-datepicker.js
#= require external/clipboard-1.5.9.js
#= require external/colorpicker
#= require external/google_analytics
#= require external/highcharts-4.1.9.src.js
#= require external/jquery-fieldselection.js
#= require external/jquery.textcomplete
# require external/json2.min.js # TODO: Remove line
#= require external/signature_pad-2.3.1.src.js
#= require external/typeahead-0.11.1-corejavascript.src.js

# Components
#= require components/cookies
#= require components/expandable_text_input
#= require components/graphs
#= require components/headings
#= require components/legal_documents
#= require components/links
#= require components/previews
#= require components/ratings
#= require components/search
#= require components/text_area_autocomplete

# Extensions
#= require extensions/clipboard
#= require extensions/datepicker
#= require extensions/filedrag
#= require extensions/recaptcha
#= require extensions/signatures
#= require extensions/slug
#= require extensions/tooltips
#= require extensions/turbolinks
#= require extensions/typeahead

# Objects
#= require objects/agreement_events
#= require objects/agreements
#= require objects/datasets
#= require objects/files
#= require objects/images
#= require objects/replies
#= require objects/requests
#= require objects/supporting_documents
#= require objects/tags
#= require objects/topics
#= require objects/variables
