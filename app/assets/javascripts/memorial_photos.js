(function memorialPhotosLoading() {
  function bindMemorialPhotos(root) {
    if (!root || root.dataset.memorialPhotosBound === 'true') {
      return;
    }

    root.dataset.memorialPhotosBound = 'true';
    var form = root.querySelector('[data-memorial-photos-target="form"]');
    if (!form) {
      return;
    }

    form.addEventListener('submit', function onSubmit() {
      root.classList.add('memorial-photos--loading');
      var skeleton = root.querySelector('[data-memorial-photos-target="skeleton"]');
      if (skeleton) {
        skeleton.classList.remove('memorial-photos__skeleton--hidden');
        skeleton.setAttribute('aria-hidden', 'false');
      }
    });
  }

  document.addEventListener('DOMContentLoaded', function onReady() {
    document.querySelectorAll('.memorial-photos').forEach(bindMemorialPhotos);
  });
})();
