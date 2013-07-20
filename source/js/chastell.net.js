document.getElementById('main_nav').insertAdjacentHTML('afterBegin',
    '<ul><li><a href="#" id="lang_toggle" lang="xx">hide non-English content</a></li></ul>');

document.getElementById('lang_toggle').onclick = function() {
  var lang = this.lang;

  Array.prototype.forEach.call(
      document.getElementsByClassName('next_prev_en'),
      function(element) {
          element.style.display = lang == 'xx' ? 'block' : 'none';
      }
  );
  Array.prototype.forEach.call(
      document.getElementsByClassName('next_prev_xx'),
      function(element) {
          element.style.display = lang == 'en' ? 'block' : 'none';
      }
  );

  var hide_show = lang == 'en' ? 'hide' : 'show';
  this.innerHTML = hide_show + ' non-English content';
  this.lang = lang == 'en' ? 'xx' : 'en';

  return false;
};
