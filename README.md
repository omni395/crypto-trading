



<!--
  Crypto Trading App — Архитектура и Концепция
-->

<h2>Концепция приложения</h2>
<p>
  <strong>Crypto Trading App</strong> — это современное трейдинг-приложение, построенное на <b>Ruby on Rails</b> с использованием <b>Hotwire</b>, <b>Stimulus</b> и <b>TailwindCSS</b>. Проект реализован в формате fullstack-монолита для максимальной простоты поддержки и быстрой разработки.<br>
  <br>
  <b>Ключевые фишки:</b>
</p>
<ul>
  <li><b>Fullstack монолит</b> — всё в одном проекте: backend, frontend, realtime, фоновые задачи.</li>
  <li><b>Rails 7+</b> — современный стек, поддержка Turbo/Stimulus, удобная архитектура.</li>
  <li><b>Hotwire (Turbo + Stimulus)</b> — быстрый UI без сложного SPA, но с возможностью динамики и realtime.</li>
  <li><b>TailwindCSS</b> — современная верстка и кастомизация интерфейса.</li>
  <li><b>Realtime-график</b> — интеграция JS-графика (например, lightweight-charts) через Stimulus-контроллер, с обновлением данных через ActionCable (WebSocket).</li>
  <li><b>PostgreSQL</b> — основное хранилище данных (история свечей, пользователи, ордера и т.д.).</li>
  <li><b>Redis</b> — кеш и pub/sub для realtime (ActionCable, Sidekiq).</li>
  <li><b>Sidekiq</b> — фоновые задачи, обработка данных, интеграция с биржами.</li>
  <li><b>Docker/Docker Compose</b> — быстрая разработка, деплой и масштабирование (web, sidekiq, redis, postgres — всё в контейнерах).</li>
  <li><b>HAML</b> — лаконичные шаблоны для вьюх.</li>
</ul>

<h3>Архитектурные особенности</h3>
<ul>
  <li>Вся логика, realtime и UI — в одном Rails-проекте.</li>
  <li>Turbo-стримы и ActionCable для мгновенного обновления графика и данных.</li>
  <li>Stimulus-контроллеры для интеграции JS-компонентов (например, графика, алертов, виджетов).</li>
  <li>TailwindCSS для быстрой стилизации и кастомизации интерфейса.</li>
  <li>Масштабирование: можно вынести Sidekiq/ActionCable/Redis в отдельные сервисы при росте нагрузки.</li>
</ul>

<h3>Преимущества подхода</h3>
<ul>
  <li>Минимум интеграционных багов — всё работает “из коробки”.</li>
  <li>Быстрая доставка новых фич.</li>
  <li>Лёгкая поддержка и развитие.</li>
  <li>Возможность быстро подключить новые JS-фичи или фреймворки.</li>
  <li>Удобный dev/prod workflow через Docker Compose.</li>
</ul>

<h3>Технологии</h3>
<ul>
  <li><b>Ruby on Rails</b> — основной backend и frontend.</li>
  <li><b>Hotwire (Turbo/Stimulus)</b> — динамика и realtime.</li>
  <li><b>TailwindCSS</b> — стилизация интерфейса.</li>
  <li><b>PostgreSQL</b> — база данных.</li>
  <li><b>Redis</b> — кеш и pub/sub.</li>
  <li><b>Sidekiq</b> — фоновые задачи.</li>
  <li><b>Docker Compose</b> — контейнеризация и масштабирование.</li>
  <li><b>HAML</b> — шаблоны.</li>
</ul>

<p><i>Проект легко расширяется: можно добавить мобильный клиент, вынести фронт отдельно или подключить сторонние сервисы без смены архитектуры.</i></p>

<!-- END OF CONCEPT -->
