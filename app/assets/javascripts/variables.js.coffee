# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@drawChart = (chartName) ->
  json = $("#charts-info").data('charts')[chartName] if $("#charts-info").data('charts')
  if json
    $('#chart-container').highcharts(
      credits:
        enabled: false
      chart:
        type: 'column'
      title:
        text: json['title']
      subtitle:
        text: json['subtitle']
      xAxis:
        categories: json['categories']
      yAxis:
        # min: 0
        title:
          text: json['units']
      tooltip:
        headerFormat: '<span style="font-size:10px">{point.key}</span><table>'
        pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' + "<td style=\"padding:0\"><b>{point.y}</b> #{(if json['stacking'] then '({point.percentage:.0f}%)' else json['units'])}</td></tr>"
        footerFormat: '</table>'
        shared: true,
        useHTML: true
      plotOptions:
        column:
          pointPadding: 0.2
          borderWidth: 0
          dataLabels:
            enabled: (if json['stacking'] then false else true)
          # enableMouseTracking: false
          stacking: json['stacking'] #'percent'
      series: json['series']
    )
  else
    $('#chart-container').html('')

@toggleVariableButtonClasses = (element) ->
  $("[data-object~='variable-chart-button']").removeClass('btn-primary').addClass('btn-default')
  $("[data-object~='variable-chart-button'][data-chart-type~='#{$(element).data('chart-type')}']").addClass('btn-primary')

@variablesReady = () ->
  drawChart($('#chart_type').val() || 'histogram')

$(document)
  .on('click', "[data-chart-type]", () ->
    toggleVariableButtonClasses(this)
    drawChart($(this).data('chart-type'))
    false
  )
