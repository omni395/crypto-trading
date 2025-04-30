<template>
  <div class="flex flex-row h-full min-h-0 bg-gray-700 min-w-0">
    <!-- Левая часть: основная информация по монете -->
    <div class="flex-auto min-w-0 p-2">
      <MainView :instrument="selectedInstrument" />
    </div>
    <!-- Правая часть: инструменты -->
    <div class="flex-shrink-0 w-1/5 min-w-[200px] max-w-[16vw] p-2 border-l border-gray-200" style="width:16vw; min-width:200px; max-width:16vw;">
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
