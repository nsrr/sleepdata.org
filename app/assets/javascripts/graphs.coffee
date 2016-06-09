@bytes = (bytes, label, precision) ->
  return '0 bytes' if bytes == 0
  s = ['bytes', 'KB', 'MB', 'GB', 'TB', 'PB']
  e = Math.floor(Math.log(bytes)/Math.log(1024))
  value = ((bytes/Math.pow(1024, Math.floor(e))).toFixed(precision))
  e = if e < 0 then (-e) else e
  value += " #{s[e]}" if label
  value

@draw_downloads_by_month = () ->
  if $('#downloads-chart-container').length > 0
    $('#downloads-chart-container').highcharts(
      credits:
        enabled: false
      chart:
        type: 'column'
      title:
        text: $('#downloads-chart-container').data('title')
      subtitle:
        text: $('#downloads-chart-container').data('subtitle')
      xAxis:
        categories: $('#downloads-chart-container').data('categories')
        title:
          text: $('#downloads-chart-container').data('xaxis')
      yAxis:
        min: 0
        title:
          text: $('#downloads-chart-container').data('yaxis')
        labels:
          formatter: () -> return bytes(this.value, true, (this.value > 1073741824000 ? 1 : 0))
        tickInterval: 549755813888
      tooltip:
        formatter: () -> return bytes(this.y, true, 1)
      plotOptions:
        column:
          pointPadding: 0.2
          borderWidth: 0
          stacking: 'normal'
      series: $('#downloads-chart-container').data('series')
    )

@graphsReady = () ->
  draw_downloads_by_month()
