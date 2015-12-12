getRandomInt = (min, max) ->
  return Math.floor(Math.random() * (max - min + 1)) + min

galleryTemplate = _.template $('#gallery-template').text()
$fragment = $ document.createDocumentFragment()

ids = []
i = 0
while i < 12
  id = getRandomInt 1, 100
  if ids.indexOf(id) > -1
    continue

  ids.push id
  $fragment.append galleryTemplate {id: id}

  i++

$ '#gallery'
  .append $fragment

