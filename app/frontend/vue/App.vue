<template>
  <div class="flex flex-row h-full min-h-0 bg-gray-700 min-w-0">
    <!-- Левая часть: основная информация по монете -->
    <div class="flex-auto min-w-0 p-2">
      <MainView :instrument="selectedInstrument" />
      <div class="mt-6">
        <!-- Дополнительные графики (плейсхолдер) -->
      </div>
    </div>
    <!-- Правая часть: инструменты -->
    <div class="flex-shrink-0 w-1/5 min-w-[180px] max-w-[15vw] p-2 border-l border-gray-200" style="width:15vw; min-width:180px; max-width:15vw;">
      <!--
      <div class="rounded shadow text-white mb-2 flex items-center justify-between">
        <span>Список криптовалют <i class="fa-brands fa-bitcoin"></i></span>
      </div>
      -->
      <Instruments @select-instrument="handleSelectInstrument" />
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import MainView from './MainView.vue'
import Instruments from './Instruments.vue'

const selectedInstrument = ref(null)

function handleSelectInstrument(ins) {
  selectedInstrument.value = ins
}
</script>
