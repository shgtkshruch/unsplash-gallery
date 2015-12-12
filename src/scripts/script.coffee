getRandomInt = (min, max) ->
  return Math.floor(Math.random() * (max - min + 1)) + min

ids = []
imageNum = 0
$fragment = $ document.createDocumentFragment()
galleryTemplate = _.template $('#gallery-template').text()

async.waterfall [
  (cb1) ->
    $.ajax
      url: 'https://unsplash.it/list'
      success: (data, status, xhr) ->
        cb1 null, data.length

  (unsplashImagesNum, cb1) ->
    async.whilst (->
      imageNum < 12
    ), ((cb2) ->
      id = getRandomInt 1, unsplashImagesNum
      if ids.indexOf(id) > -1
        cb2 null, imageNum
        return
      ids.push id

      $ '<img/>'
        .attr 'src', 'https://unsplash.it/300?image=' + id
        .on 'load', ->
          $fragment.append galleryTemplate {id: id}
          cb2 null, imageNum++
        .on 'error', ->
          cb2 null, imageNum
    ), (err, n) ->
      $ '#gallery'
        .append $fragment
        cb1 null
], (err, results) ->
  console.log 'Initial rendering end'
