// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

// jQueryが動作してるかの確認は以下をコメントインしてリロードした画面のconsoleで確認
import jquery from 'jquery'
window.jQuery = jquery
window.$ = jquery

// $(function () {
//     console.log('Hello, jQuery')
// })

document.addEventListener("turbo:load", function() {
  $(function () {
    $('.check-all').on('click', function () {
      $('.check').prop('checked', !allChecked());
      updateView();
    });

    $('.check').on('click', function (e) {
      $('.check-all').prop('checked', allChecked());
      updateView();
    });

    function allChecked() {
      let result = true;

      $('.check').each(function () {
        if (!$(this).prop('checked')) {
          result = false;
          return false;
        }
      });

      return result;
    }

    function updateView() {
      let ids = [];

      $('.check:checked').each(function () {
        ids.push($(this).val());
      });

      $('input[name="ids"]').val(ids.join(','));

      if (ids.length > 0) {
        $('.button-delete-all').show();
      } else {
        $('.button-delete-all').hide();
      }
    }
  });
});
