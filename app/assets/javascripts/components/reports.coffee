@reportsReady = ->
  $("[data-object~=reports-data-requests-chart]").each((index, element) ->
    $(element).highcharts
      credits: enabled: false
      chart:
        backgroundColor: "transparent"
      title: $(element).data("title")
      series: $(element).data("series")
      xAxis: $(element).data("x-axis")
      yAxis: $(element).data("y-axis")
      tooltip:
        shared: true
        crosshairs: true
  )
