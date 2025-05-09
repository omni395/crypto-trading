import Rails from "@rails/ujs";
Rails.start();

import "../toastr";
import "./application.css";
import "flowbite/dist/flowbite.turbo.js";
import "flowbite-datepicker";
import "flowbite/plugin";

// Добавляем CSRF токен в заголовки всех запросов
const token = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')
if (token) {
  // Настраиваем для fetch
  const originalFetch = window.fetch
  window.fetch = function(url, options = {}) {
    options.headers = {
      ...options.headers,
      'X-CSRF-Token': token
    }
    return originalFetch(url, options)
  }
}

console.log('Vite ⚡️ Rails');
