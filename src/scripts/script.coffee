ids = []
imageNum = 0
imagesData = ''
$fragment = $ document.createDocumentFragment()
$gallery = $ '#gallery'
$loading = $ '#loading'
$body = $ 'body'
$window = $ window
$lightbox = $ '#lightbox'
$lightboxBtn = $ '#lightboxBtn'
duration = 400
galleryTemplate = _.template $('#gallery-template').text()

renderImages = (cb) ->
  async.whilst (->
    imageNum < 12
  ), ((cb1) ->
    image = {}
    image.id = (->
      return Math.floor(Math.random() * (imagesData.length - 1 + 1)) + 1
    )()

    if ids.indexOf(image.id) > -1
      cb1 null, imageNum
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
        cb1 null, imageNum++
      .on 'error', ->
        cb1 null, imageNum
  ), (err, n) ->
    cb()

async.series [
  (cb) ->
    $loading.fadeIn()
    $.ajax
      url: 'https://unsplash.it/list'
      success: (data, status, xhr) ->
        imagesData = data
        cb null
  (cb) ->
    renderImages ->
      $gallery.append $fragment
      $loading.fadeOut()
      cb null

], (err, results) ->
  console.log 'Initial rendering end'

new Steady
  conditions:
    "max-bottom": 500
  throttle: 500
  handler: (values, done) ->
    $loading.fadeIn()
    imageNum = 0
    renderImages ->
      console.log 'renderng by scroll'
      $gallery.append $fragment
      $loading.fadeOut()
      done()

$gallery.on 'click', '.js-gallery__img', (e) ->
  src = $(@).find('img').attr('src')
  src = src.replace /300\?/, $window.width() + '/' + $window.height() + '/?'
  $ '<img/>'
    .attr 'src', src
    .on 'load', ->
      $(@)
        .appendTo $lightbox
        .hide()
        .fadeIn duration
      $lightbox.fadeIn duration
      $body.css
        overflow: 'hidden'
        height: '100%'

$lightboxBtn.click (e) ->
  $lightbox
    .find 'img'
    .fadeOut duration, ->
      $(@).remove()
      $body.css
        overflow: 'auto'
        height: 'auto'
    $lightbox.fadeOut duration
