<template>
  <div class="main-view min-h-[320px]">
    <div v-if="instrument" class="text-2xl font-bold text-white mb-4">
      {{ instrument.base_asset }}
    </div>
    <div v-else class="flex items-center justify-center h-full">
      <i class="fa-solid fa-coins text-gray-400 text-6xl mx-auto mt-24" title="Выберите монету из списка справа"></i>
    </div>
  </div>
</template>

<script setup>
const props = defineProps({
  instrument: {
    type: Object,
    required: false,
    default: null
  }
})
</script>

<style scoped>
.main-view {
  min-height: 320px;
  position: relative;
}
</style>
