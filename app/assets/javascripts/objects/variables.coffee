@drawChart = (chartName) ->
  json = $('#charts-info').data('charts')['charts'][chartName] if $('#charts-info').data('charts') and $('#charts-info').data('charts')['charts']
  if json
    $('#chart-container').highcharts(
      credits:
        enabled: false
      chart:
        type: 'column'
      title:
        text: json['title']
        style:
          fontSize: "14px"
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
        headerFormat: '<span style="font-size: 16px"><b>{point.key}</b></span><table>'
        pointFormat: '<tr><td style="font-size: 14px;color:{series.color};padding:0">{series.name}: </td>' + "<td style=\"font-size: 14px;padding:0\"><b>{point.y}</b> #{(if json['stacking'] then '({point.percentage:.0f}%)' else json['units'])}</td></tr>"
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
  $('[data-object~="variable-chart-button"]').removeClass('btn-primary').addClass('btn-light')
  $("[data-object~='variable-chart-button'][data-chart-type~='#{$(element).data('chart-type')}']").addClass('btn-primary')

@variablesReady = ->
  Highcharts.setOptions(
    lang:
      thousandsSep: ','
    colors: ['#7cb5ec', '#90ed7d', '#f7a35c', '#8085e9',
      '#f15c80', '#e4d354', '#2b908f', '#f45b5b', '#91e8e1']
  )
  chart_type = $('#chart_type').val() || 'histogram'
  drawChart(chart_type)
  $("[data-chart-name~='#{chart_type}']").show()

@nonStandardClick = (event) ->
  event.which > 1 or event.metaKey or event.ctrlKey or event.shiftKey or event.altKey

$(document)
  .on('click', '[data-chart-type]', () ->
    toggleVariableButtonClasses(this)
    chart_type = $(this).data('chart-type')
    drawChart(chart_type)
    $('[data-chart-name]').hide()
    $("[data-chart-name~='#{chart_type}']").show()
    false
  )
  .on('click', '[data-link]', (e) ->
    if $(e.target).is('a')
      # Do nothing, propagate standard behavior
    else if nonStandardClick(e)
      window.open($(this).data('link'))
      return false
    else
      Turbolinks.visit($(this).data('link'))
  )
  .keydown((e) ->
    if e.which == 39 and not $('input, textarea, select, a').is(':focus')
      $('#next-variable')[0].click() if $('#next-variable')[0]
    else if e.which == 37 and not $('input, textarea, select, a').is(':focus')
      $('#previous-variable')[0].click() if $('#previous-variable')[0]
  )
