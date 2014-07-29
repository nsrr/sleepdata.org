# UserVoice Javascript SDK developer documentation:
# https://www.uservoice.com/o/javascript-sdk

showuservoice = ->
  return unless UserVoice?

  # Set colors
  UserVoice.push ['set', {
    accent_color: '#6aba2e'
    trigger_color: 'white'
    trigger_background_color: '#6aba2e'
  }]

  # Identify the user and pass traits
  UserVoice.push ['identify', {
    email: $('body').data('email') # User's email address
    name:  $('body').data('fullname') # User's real name
  }]

  # Add default trigger to the bottom-right corner of the window:
  UserVoice.push ['addTrigger', { mode: 'contact', trigger_position: 'bottom-right' }]

  # Autoprompt for Satisfaction and SmartVote (only displayed under certain conditions)
  UserVoice.push ['autoprompt', {}]

$ ->
  $.getScript "//widget.uservoice.com/Tzs6afFRyv54dMJ18t1zg.js", showuservoice

$(document).on 'page:change', showuservoice
