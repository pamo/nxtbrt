ETD_URL = "http://api.bart.gov/api/etd.aspx"
API_KEY="MW9S-E7SL-26DU-VV8V"

parseMinutes = (minutesString)->
  mins = parseInt(minutesString)
  if isNaN(mins) then 0 else mins

parseEtds = (doc)->
  allEstimates = []
  for etd in doc.getElementsByTagName('etd')
    do (etd)->
      dest = pluckTextFromNode(etd, 'abbreviation')
      for estimates in etd.getElementsByTagName('estimate')
        allEstimates.push(
          dest: dest
          minutes: parseMinutes(pluckTextFromNode(estimates,'minutes'))
          platform: pluckTextFromNode(estimates,'minutes')
          length: pluckTextFromNode(estimates,'length')
        )
  allEstimates.sort (a,b)->
    a.minutes - b.minutes
  allEstimates

loadEtds = (stationAbbr)->
  Q($.get( ETD_URL, {cmd: 'etd', orig: stationAbbr, key: API_KEY} ))
    .then(parseEtds)

displayEtds = (estimates)->
  $list = $("<ul>")
  estimates.forEach (e)->
    $("<li>").text("#{e.dest}: #{e.minutes}").appendTo($list)
  $('.etds').empty().append($list).show()


window.NxtBrt ?= {}
window.NxtBrt.displayEtdsFor = (station)->
  NxtBrt.showToast('finding departure times...')
  loadEtds(station.abbr)
    .then( displayEtds )
    .then( NxtBrt.hideToast )
