// Автоматический вызов toastr для Hotwire Turbo Stream
import { Turbo } from "@hotwired/turbo-rails";

window.addEventListener("turbo:before-stream-render", function(event) {
  const template = event.target.firstElementChild;
  if (template && template.dataset.toastrMessage) {
    const type = template.dataset.toastrType || 'info';
    toastr[type](template.dataset.toastrMessage);
    event.preventDefault();
  }
});