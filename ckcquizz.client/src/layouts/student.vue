<template>
  <a-layout class="student-quiz-layout">
    <StudentHeader />
      <div class="container-fluid py-4">
        <router-view></router-view>
      </div>
  </a-layout>
</template>

<style scoped>
.student-quiz-layout {
  min-height: 100vh;
}
</style>
<script setup>
import StudentHeader from '@/components/Student/StudentHeader.vue';
</script>
