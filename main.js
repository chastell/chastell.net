document.addEventListener('keydown', function(event) {
  if (event.altKey || event.ctrlKey) return;
  const id = Number(window.location.hash.substring(1)) || 0;
  let target;
  switch (event.key) {
    case 'ArrowLeft':
    case 'h':
      document.getElementsByClassName('next')[0].click();
      return;
    case 'ArrowRight':
    case 'l':
      document.getElementsByClassName('previous')[0].click();
      return;
    case 'ArrowUp':
    case 'PageUp':
    case 'k':
      target = id - 1;
      break;
    case 'ArrowDown':
    case 'PageDown':
    case 'j':
      target = id + 1;
      break;
    case 'End':
    case 'Home':
      history.replaceState(null, null, ' ');
      return;
    default:
      return;
  }
  const element = document.getElementById(target);
  if (!element) return;
  event.preventDefault();
  if (!target) {
    window.scrollTo({ behavior: 'smooth', top: 0 });
  } else {
    element.scrollIntoView({ behavior: 'smooth' });
  }
  history.replaceState(null, null, '#' + target);
});
