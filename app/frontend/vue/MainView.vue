<template>
  <div class="main-view min-h-[320px]">
    <div v-if="instrument" class="text-2xl font-bold text-white mb-4">
      {{ instrument.base_asset }}
    </div>
    <div v-else class="text-gray-400 text-xl">
      Выберите монету из списка справа
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
}
</style>
