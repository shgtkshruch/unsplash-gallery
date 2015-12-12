galleryTemplate = _.template $('#gallery-template').text()

$fragment = $ document.createDocumentFragment()
i = 0
while i < 12
  $fragment.append galleryTemplate {i: i}
  i++

$ '#gallery'
  .append $fragment
