<template>
  <div class="relative max-w-[180px]" v-click-outside="closeDropdown">
    <button
      id="user-dropdown-btn"
      type="button"
      class="flex items-center gap-2 py-2 px-3 text-white rounded-sm hover:bg-gray-600 focus:outline-none cursor-pointer"
      @click="toggleDropdown">
      <i class="fa-solid fa-user text-lg"></i>
      <span class="sr-only">Управление аккаунтом</span>
      <svg class="w-2.5 h-2.5 ms-2" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 10 6">
        <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m1 1 4 4 4-4"/>
      </svg>
    </button>
    <div
      v-show="visible"
      class="z-50 bg-white divide-y divide-gray-100 rounded-lg shadow w-44 dark:bg-gray-700 absolute right-0 mt-2 overflow-x-auto"
      style="min-width: 160px;">
      <ul class="py-2 text-sm text-gray-700 dark:text-gray-200">
        <li>
          <a href="/users/edit" class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white">Профиль</a>
        </li>
        <li v-if="isAdmin">
          <a href="/admin/roles" class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white">Роли</a>
        </li>
        <li v-if="isAdmin">
          <a href="/admin/exchanges" class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white">Биржи</a>
        </li>
        <li v-if="isAdmin">
          <a href="/admin/user_roles" class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white">Назначения ролей</a>
        </li>
        <li>
          <a href="/users/sign_out" data-method="delete" class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white">Выйти</a>
        </li>
      </ul>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const visible = ref(false)
const isAdmin = document.getElementById('vue-user-dropdown')?.dataset.admin === 'true'

function toggleDropdown() {
  visible.value = !visible.value
}
function closeDropdown() {
  visible.value = false
}

// Локальная директива click-outside
function clickOutside(el, binding) {
  function handler(e) {
    if (!el.contains(e.target)) {
      binding.value()
    }
  }
  document.addEventListener('mousedown', handler)
  el._clickOutside = handler
}
function unbindClickOutside(el) {
  document.removeEventListener('mousedown', el._clickOutside)
}

// Локальная регистрация директивы для <script setup>
const vClickOutside = {
  mounted: clickOutside,
  unmounted: unbindClickOutside
}

defineExpose({ directives: { clickOutside: vClickOutside } })
</script>
