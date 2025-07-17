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
import { onMounted, onUnmounted } from 'vue';
import connection from '@/services/signalrThongBaoService.js';
import { notification } from 'ant-design-vue';

const handleLogin = (message) => {
  notification.warning({
    message: 'Cảnh báo đăng nhập',
    description: message,
    duration: 5
  });
};

onMounted(() => {
  connection.on("NotifyLogin", handleLogin);
});

onUnmounted(() => {
  connection.off("NotifyLogin", handleLogin);
});
</script>
