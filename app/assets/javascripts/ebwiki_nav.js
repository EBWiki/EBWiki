document.addEventListener("DOMContentLoaded", function () {
  var header = document.getElementById("ebwiki-site-header");
  var toggle = document.querySelector("[data-ebwiki-nav-toggle]");
  if (!header || !toggle) {
    return;
  }

  toggle.addEventListener("click", function () {
    var open = header.classList.toggle("is-nav-open");
    toggle.setAttribute("aria-expanded", open ? "true" : "false");
  });
});
