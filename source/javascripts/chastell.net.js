document.addEventListener('keydown', function(event) {
  if (event.altKey || event.ctrlKey) return;
  switch (event.key) {
    case 'ArrowRight':
    case 'l':
      document.getElementById('prev').click();
      break;
    case 'ArrowLeft':
    case 'h':
      document.getElementById('next').click();
      break;
  }
});
