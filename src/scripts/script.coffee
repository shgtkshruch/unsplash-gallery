getRandomInt = (min, max) ->
  return Math.floor(Math.random() * (max - min + 1)) + min

galleryTemplate = _.template $('#gallery-template').text()
$fragment = $ document.createDocumentFragment()

i = 0
while i < 12
  id = getRandomInt 1, 100
  $fragment.append galleryTemplate {id: id}
  i++

$ '#gallery'
  .append $fragment

