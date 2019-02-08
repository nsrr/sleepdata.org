@numberWithCommas = (n) ->
  parts = n.toString().split('.')
  parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',') + (if parts[1] then '.' + parts[1] else '')

@reportsReady = ->
  $("[data-object~=reports-data-requests-chart]").each((index, element) ->
    $(element).highcharts
      credits: enabled: false
      chart:
        backgroundColor: "transparent"
      title: text: $(element).data("title")
      subtitle: text: $(element).data("subtitle")
      series: $(element).data("series")
      xAxis: $(element).data("x-axis")
      yAxis: $(element).data("y-axis")
      tooltip:
        shared: true
        crosshairs: true
  )
  $("[data-object~=report-number]").each((index, element) ->
    decimal_places = $(element).data("decimal") || 0
    decimal_factor = if decimal_places == 0 then 1 else 10 ** decimal_places
    append = $(element).data("append") || ""
    $(element).animateNumber {
      number: $(element).data("number") * decimal_factor
      numberStep: (now, tween) ->
        rounded_number = Math.round(now) / decimal_factor
        target = $(tween.elem)
        if decimal_places > 0
          # force decimal places even if they are 0
          rounded_number = rounded_number.toFixed(decimal_places)
        rounded_number = numberWithCommas(rounded_number)
        target.text rounded_number + append
        return
    }, 500
  )
