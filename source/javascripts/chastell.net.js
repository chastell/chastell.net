document.addEventListener('keydown', function(key) {
  switch (key.which) {
    case 74:
      document.getElementById('prev').click();
      break;
    case 75:
      document.getElementById('next').click();
      break;
  }
});
