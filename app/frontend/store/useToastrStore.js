import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useToastrStore = defineStore('toastr', () => {
  const queue = ref([])

  function show(message, type = 'success', options = {}) {
    queue.value.push({ message, type, ...options })
  }

  function clear() {
    queue.value = []
  }

  return { queue, show, clear }
})
