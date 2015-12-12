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
      success: (imagesData, status, xhr) ->
        cb1 null, imagesData

  (imagesData, cb1) ->
    async.whilst (->
      imageNum < 9
    ), ((cb2) ->
      image = {}
      image.id = getRandomInt 1, imagesData.length
      if ids.indexOf(image.id) > -1
        cb2 null, imageNum
        return
      ids.push image.id

      imageData = (->
        return imagesData.filter (element, index, array) ->
          element.id is image.id
      )()

      if imageData.length is 1
        image.author = imageData[0].author
        image.authorUrl = imageData[0].author_url
        image.postUrl = imageData[0].post_url

      $ '<img/>'
        .attr 'src', 'https://unsplash.it/300?image=' + image.id
        .on 'load', ->
          $fragment.append galleryTemplate image
          cb2 null, imageNum++
        .on 'error', ->
          cb2 null, imageNum
    ), (err, n) ->
      $ '#gallery'
        .append $fragment
      cb1 null
], (err, results) ->
  console.log 'Initial rendering end'
