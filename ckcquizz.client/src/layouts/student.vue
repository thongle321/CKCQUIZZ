<template>
  <a-layout class="student-quiz-layout">
    <StudentHeader />
    <a-layout-content class="content-area">
      <div class="container-fluid py-4">
        <router-view></router-view>
      </div>
    </a-layout-content>
  </a-layout>
</template>

<script setup>
import StudentHeader from '@/components/Student/StudentHeader.vue';
</script>
