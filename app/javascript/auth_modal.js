document.addEventListener("DOMContentLoaded", function() {
  const openBtn = document.getElementById("auth-modal-btn");
  const modal = document.getElementById("auth-modal");
  const closeBtns = modal.querySelectorAll("[data-modal-hide='auth-modal']");

  if (openBtn && modal) {
    openBtn.addEventListener("click", function() {
      modal.classList.remove("hidden");
    });
  }
  closeBtns.forEach(btn => {
    btn.addEventListener("click", function() {
      modal.classList.add("hidden");
    });
  });

  // Закрытие по клику вне модального окна
  modal.addEventListener("mousedown", function(e) {
    if (e.target === modal) {
      modal.classList.add("hidden");
    }
  });
});
