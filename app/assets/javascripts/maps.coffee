@drawWorldMap = (element) ->
  json = $(element).data('info')

  mapData = Highcharts.geojson(Highcharts.maps["custom/world"])

  data = $(element).data('membership')

  $(element).highcharts('Map',
    chart:
      backgroundColor: null
    title:
      text: null
    legend:
      enabled: false
      # layout: 'horizontal'
      # borderWidth: 0
      # backgroundColor: 'rgba(255,255,255,0.85)'
      # floating: true
      # verticalAlign: 'top'
      # y: 25
    credits:
      enabled: false
    mapNavigation:
      enabled: false
    colorAxis:
      min: 0
    series: [{
      name: 'Members'
      data: data
      mapData: mapData
      joinBy: 'hc-key'
      states:
        hover:
          color: '#BADA55'
      dataLabels:
        enabled: false # true
        format: '{point.name}'
      tooltip:
        headerFormat: ''
        pointFormat: '{point.name}: <b>{point.value}</b> Members'
    }]
  )


@drawMap = (element) ->
  json = $(element).data('info')


  mapData = Highcharts.geojson(Highcharts.maps["countries/us/us-all"])

  data = $(element).data('membership')

  $(element).highcharts('Map',
    chart:
      backgroundColor: null
    title:
      text: null
    legend:
      enabled: false
    credits:
      enabled: false
    mapNavigation:
      enabled: false
    colorAxis:
      min: 0
    series: [{
      name: 'Members'
      data: data
      mapData: mapData
      joinBy: 'hc-key'
      states:
        hover:
          color: '#BADA55'
      dataLabels:
        enabled: false # true
        format: '{point.name}'
      tooltip:
        headerFormat: ''
        pointFormat: '{point.name}: <b>{point.value}</b> Members'
    }]
  )



@mapsReady = () ->
  $('[data-object~="draw-map"]').each( (index, element) ->
    drawMap( element )
  )
  $('[data-object~="draw-world-map"]').each( (index, element) ->
    drawWorldMap( element )
  )
