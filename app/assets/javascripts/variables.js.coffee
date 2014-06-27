# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@drawChart = (chartName) ->
  json = $("#charts-info").data('charts')['charts'][chartName] if $("#charts-info").data('charts') and $("#charts-info").data('charts')['charts']
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
        title:
          text: json['x_axis_title']
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
  chart_type = $('#chart_type').val() || 'histogram'
  drawChart(chart_type)
  $("[data-chart-name~='#{chart_type}']").show()

$(document)
  .on('click', "[data-chart-type]", () ->
    toggleVariableButtonClasses(this)
    chart_type = $(this).data('chart-type')
    drawChart(chart_type)
    $("[data-chart-name]").hide()
    $("[data-chart-name~='#{chart_type}']").show()
    false
  )
  .on('click', "[data-link]", (e) ->
    if $(e.target).is('a')
      # Do nothing, propagate standard behavior
    else if nonStandardClick(e)
      window.open($(this).data("link"))
      return false
    else
      Turbolinks.visit($(this).data("link"))
  )
