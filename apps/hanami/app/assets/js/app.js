import "../css/app.css";

document.addEventListener("click", (event) => {
  const button = event.target.closest("[data-add]");
  if (!button) return;

  const container = document.getElementById(button.dataset.add);
  if (!container) return;

  const prototype = container.querySelector(".repeatable");
  if (!prototype) return;

  const clone = prototype.cloneNode(true);
  clone.querySelectorAll("input").forEach((input) => {
    input.value = "";
  });
  container.appendChild(clone);
});
