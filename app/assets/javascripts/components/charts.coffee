@surveyReportCharts = ->
  $("[data-object~=survey-report-chart]").each((index, element) ->
    $(element).highcharts
      credits: enabled: false
      chart:
        borderColor: "transparent"
        plotBackgroundColor: null
        plotBorderWidth: 0
        plotShadow: false
      title: $(element).data("title")
      tooltip: pointFormat: "<b>{point.y}</b> {series.name}"
      series: $(element).data("series")
      xAxis: $(element).data("x-axis")
      yAxis: $(element).data("y-axis")
  )

@chartsReady = ->
  # Highcharts.setOptions(
  #   lang:
  #     thousandsSep: ","
  #   colors: [
  #     "#7cb5ec"
  #     "#90ed7d"
  #     "#f7a35c"
  #     "#8085e9"
  #     "#f15c80"
  #     "#e4d354"
  #     "#2b908f"
  #     "#f45b5b"
  #     "#91e8e1"
  #   ]
  # )
  surveyReportCharts()
