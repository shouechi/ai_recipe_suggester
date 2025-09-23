// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

document.addEventListener("DOMContentLoaded", () => {
  const form = document.querySelector("form");
  const submitButton = document.getElementById("recipe-submit-button");
  const loadingIndicator = document.getElementById("loading-indicator")

  if (form) {
    form.addEventListener("submit", () => {
      submitButton.disabled = true;
      submitButton.value = "考え中...";
      loadingIndicator.classList.remove("hidden");
    });
  }
})