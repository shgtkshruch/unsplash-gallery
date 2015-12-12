getRandomInt = (min, max) ->
  return Math.floor(Math.random() * (max - min + 1)) + min

galleryTemplate = _.template $('#gallery-template').text()
$fragment = $ document.createDocumentFragment()

ids = []
i = 0
async.whilst (->
  i < 12
), ((callback) ->
  id = getRandomInt 1, 100
  if ids.indexOf(id) > -1
    callback null, i
    return
  ids.push id

  $ '<img/>'
    .attr 'src', 'https://unsplash.it/300?image=' + id
    .on 'load', ->
      $fragment.append galleryTemplate {id: id}
      callback null, i++
    .on 'error', ->
      callback null, i
), (err, n) ->
  $ '#gallery'
    .append $fragment

