<template>
  <div class="fixed top-4 right-4 z-50 space-y-2">
    <transition-group name="fade" tag="div">
      <div v-for="(toast, idx) in store.queue" :key="idx"
           :class="[
             'px-4 py-2 rounded shadow text-sm flex items-center gap-2',
             toast.type === 'success' ? 'bg-green-700 text-white' : '',
             toast.type === 'error' ? 'bg-red-700 text-white' : '',
             toast.type === 'info' ? 'bg-blue-700 text-white' : '',
             toast.type === 'warning' ? 'bg-yellow-600 text-white' : ''
           ]">
        <i v-if="toast.type === 'success'" class="fa-solid fa-check-circle"></i>
        <i v-else-if="toast.type === 'error'" class="fa-solid fa-xmark-circle"></i>
        <i v-else-if="toast.type === 'info'" class="fa-solid fa-info-circle"></i>
        <i v-else-if="toast.type === 'warning'" class="fa-solid fa-exclamation-triangle"></i>
        <span>{{ toast.message }}</span>
      </div>
    </transition-group>
  </div>
</template>

<script setup>
import { useToastrStore } from '../store/useToastrStore'
import { watch } from 'vue'

const store = useToastrStore()

// Автоматически удалять тост через 3 секунды
watch(
  () => store.queue.length,
  (len, prev) => {
    if (len > prev) {
      setTimeout(() => {
        store.queue.shift()
      }, 3000)
    }
  }
)
</script>

<style scoped>
.fade-enter-active, .fade-leave-active {
  transition: opacity 0.3s;
}
.fade-enter-from, .fade-leave-to {
  opacity: 0;
}
</style>
