getRandomInt = (min, max) ->
  return Math.floor(Math.random() * (max - min + 1)) + min

ids = []
imageNum = 0
imagesData = ''
$fragment = $ document.createDocumentFragment()
$gallery = $ '#gallery'
galleryTemplate = _.template $('#gallery-template').text()

async.waterfall [
  (cb1) ->
    $.ajax
      url: 'https://unsplash.it/list'
      success: (imagesData, status, xhr) ->
        cb1 null, imagesData
  (imagesDataTmp, cb1) ->
    imagesData = imagesDataTmp

    async.whilst (->
      imageNum < 12
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
      $gallery.append $fragment
      cb1 null
], (err, results) ->
  console.log 'Initial rendering end'

new Steady
  conditions:
    "max-bottom": 2000
  throttle: 500
  handler: (values, done) ->
    imageNum = 0
    async.whilst (->
      imageNum < 12
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
      console.log 'render'
      $gallery.append $fragment
      done()
