import "@hotwired/turbo-rails";
import "flowbite";
import "./controllers";
import "./toastr_hotwire";

document.addEventListener('DOMContentLoaded', () => {
    const refreshBtn = document.getElementById('refresh-coins-btn');
    if (refreshBtn) {
      refreshBtn.addEventListener('click', function (event) {
        event.preventDefault();
        if (confirm('Вы уверены, что хотите обновить монеты? Это может занять время и ресурсы.')) {
          window.toastr && toastr.info('Запущен процесс обновления монет на сервере...');
          fetch('/main/refresh_cryptocurrencies', {
            method: 'POST',
            headers: {
              'Accept': 'text/vnd.turbo-stream.html',
              'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
            }
          }).then(r => {
            if (r.ok) {
              window.toastr && toastr.success('Обновление монет успешно запущено!');
            } else {
              window.toastr && toastr.error('Ошибка при запуске обновления монет!');
            }
          }).catch(() => {
            window.toastr && toastr.error('Ошибка сети при запуске обновления монет!');
          });
        }
      });
    }
  });

  document.addEventListener('DOMContentLoaded', () => {
    const settingsBtn = document.getElementById('settings-btn');
    const modal = document.getElementById('settings-modal');
  
    if (modal && settingsBtn) {
      // Отслеживаем событие скрытия модалки от Flowbite
      modal.addEventListener('hidden.tw.modal', () => {
        settingsBtn.focus();
      });
    }
  });

document.addEventListener('DOMContentLoaded', () => {
  const toastr = document.getElementById('toastr');
  if (toastr) {
    setTimeout(() => {
      toastr.style.display = 'none';
    }, 3000);
  }
});