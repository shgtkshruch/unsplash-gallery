(() => {
  'use strict';

  var ids = [];
  var imageNum = 0;
  var imagesData = '';
  var $fragment = $(document.createDocumentFragment());
  var $gallery = $('#gallery');
  var $loading = $('#loading');
  var $body = $('body');
  var $window = $(window);
  var $lightbox = $('#lightbox');
  var duration = 400;
  var galleryTemplate = _.template($('#gallery-template').text());
  var lightboxTemplate = _.template($('#lightbox-template').text());

  // 画像を12枚読み込む関数
  var renderImages = cb => {
    async.whilst(() => {
      return imageNum < 12;
    }, cb1 => {
      var image = {};
      image.id = Math.floor(Math.random() * imagesData.length) + 1;

      // 既に読み込んだ画像だったら処理を終了
      if (ids.indexOf(image.id) > -1) {
        cb1(null, imageNum);
        return;
      }

      ids.push(image.id);

      var imageData = imagesData.filter((element, index, array) => {
        return element.id === image.id;
      });

      if (imageData.length === 1) {
        image.author = imageData[0].author;
        image.authorUrl = imageData[0].author_url;
        image.postUrl = imageData[0].post_url;
      }

      // 画像をロードして成功したらフラグメントに追加
      // 失敗したら次の画像に処理を移す
      $('<img/>')
        .attr('src', 'https://unsplash.it/300?image=' + image.id)
        .on('load', () => {
          $fragment.append(galleryTemplate(image));
          cb1(null, imageNum++);
        })
        .on('error', () => {
          cb1(null, imageNum);
        });
    }, (err, n) => {
      cb();
    });
  }

  // 最初の12枚の写真を描画
  async.series([
    cb => {
      $.ajax({
        url: 'https://unsplash.it/list',
        success: (data, status, xhr) => {
          imagesData = data;
          cb(null);
        }
      })
    },
    cb => {
      renderImages(() => {
        $gallery.append($fragment);
        $loading.fadeOut(duration);
        cb(null);
      });
    }
  ]);

  // 無限スクロール
  new Steady({
    conditions: {
      'max-bottom': 500
    },
    throttle: 500,
    handler: (values, done) => {
      $loading.fadeIn(duration);
      imageNum = 0;
      renderImages(() => {
        $gallery.append($fragment);
        $loading.fadeOut(duration);
        done();
      });
    }
  });

  // 画像をクリックしたらライトボックスを表示
  $gallery.on('click', '.js-gallery__img', function (e) {
    var image = {};
    var src = $(this).find('img').attr('src');
    image.src = src.replace(/300\?/, $window.width() + '/' + $window.height() + '/?');
    image.url = $(this).data('posturl');
    image.author = $(this).data('author');
    image.authorUrl = $(this).data('authorurl');

    $('<img/>;')
      .attr('src', image.src)
      .on('load', () => {
        $lightbox.append(lightboxTemplate(image)).fadeIn(duration);
        $body.css({
          overflow: 'hidden',
          height: '100%'
        });
      });
  });

  // ライトボックスを削除
  $lightbox.on('click', '#lightboxBtn', function (e) {
    $lightbox.fadeOut(duration, function () {
      $(this).empty();
      $body.css({
        overflow: 'auto',
        height: 'auto'
      });
    });
  });

})();
