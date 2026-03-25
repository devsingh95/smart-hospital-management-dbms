document.addEventListener("DOMContentLoaded", () => {
  const revealEls = document.querySelectorAll("[data-reveal]");
  revealEls.forEach((el, idx) => {
    setTimeout(() => {
      el.classList.add("show");
    }, 90 * idx);
  });

  const alerts = document.querySelectorAll(".flash");
  alerts.forEach((alert) => {
    setTimeout(() => {
      alert.style.opacity = "0";
      alert.style.transform = "translateY(-6px)";
    }, 2800);
  });
});
