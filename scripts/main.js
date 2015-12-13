(function() {
  var $body, $fragment, $gallery, $lightbox, $loading, $window, duration, galleryTemplate, ids, imageNum, imagesData, lightboxTemplate, renderImages;

  ids = [];

  imageNum = 0;

  imagesData = '';

  $fragment = $(document.createDocumentFragment());

  $gallery = $('#gallery');

  $loading = $('#loading');

  $body = $('body');

  $window = $(window);

  $lightbox = $('#lightbox');

  duration = 400;

  galleryTemplate = _.template($('#gallery-template').text());

  lightboxTemplate = _.template($('#lightbox-template').text());

  renderImages = function(cb) {
    return async.whilst((function() {
      return imageNum < 12;
    }), (function(cb1) {
      var image, imageData;
      image = {};
      image.id = (function() {
        return Math.floor(Math.random() * (imagesData.length - 1 + 1)) + 1;
      })();
      if (ids.indexOf(image.id) > -1) {
        cb1(null, imageNum);
        return;
      }
      ids.push(image.id);
      imageData = (function() {
        return imagesData.filter(function(element, index, array) {
          return element.id === image.id;
        });
      })();
      if (imageData.length === 1) {
        image.author = imageData[0].author;
        image.authorUrl = imageData[0].author_url;
        image.postUrl = imageData[0].post_url;
      }
      return $('<img/>').attr('src', 'https://unsplash.it/300?image=' + image.id).on('load', function() {
        $fragment.append(galleryTemplate(image));
        return cb1(null, imageNum++);
      }).on('error', function() {
        return cb1(null, imageNum);
      });
    }), function(err, n) {
      return cb();
    });
  };

  async.series([
    function(cb) {
      $loading.show();
      return $.ajax({
        url: 'https://unsplash.it/list',
        success: function(data, status, xhr) {
          imagesData = data;
          return cb(null);
        }
      });
    }, function(cb) {
      return renderImages(function() {
        $gallery.append($fragment);
        $loading.fadeOut(duration);
        return cb(null);
      });
    }
  ], function(err, results) {});

  new Steady({
    conditions: {
      'max-bottom': 500
    },
    throttle: 500,
    handler: function(values, done) {
      $loading.fadeIn(duration);
      imageNum = 0;
      return renderImages(function() {
        $gallery.append($fragment);
        $loading.fadeOut(duration);
        return done();
      });
    }
  });

  $gallery.on('click', '.js-gallery__img', function(e) {
    var image, src;
    image = {};
    src = $(this).find('img').attr('src');
    image.src = src.replace(/300\?/, $window.width() + '/' + $window.height() + '/?');
    image.url = $(this).data('posturl');
    image.author = $(this).data('author');
    image.authorUrl = $(this).data('authorurl');
    return $('<img/>').attr('src', image.src).on('load', function() {
      $lightbox.append(lightboxTemplate(image)).fadeIn(duration);
      return $body.css({
        overflow: 'hidden',
        height: '100%'
      });
    });
  });

  $lightbox.on('click', '#lightboxBtn', function(e) {
    return $lightbox.fadeOut(duration, function() {
      $(this).empty();
      return $body.css({
        overflow: 'auto',
        height: 'auto'
      });
    });
  });

}).call(this);
