<template>
  <div class="container mt-4">
    <a-row :gutter="16">
      <a-col :span="8">
        <a-card>
          <div class="text-center">
            <h3>{{ statistics.totalUsers }}</h3>
            <p>Tổng người dùng</p>
          </div>
        </a-card>
      </a-col>
      <a-col :span="8">
        <a-card>
          <div class="text-center">
            <h3>{{ statistics.totalStudents }}</h3>
            <p>Tổng học sinh</p>
          </div>
        </a-card>
      </a-col>
      <a-col :span="8">
        <a-card>
          <div class="text-center">
            <h3>{{ statistics.totalExams }}</h3>
            <p>Tổng đề thi</p>
          </div>
        </a-card>
      </a-col>
    </a-row>
    <a-row :gutter="16" class="mt-3">
      <a-col :span="8">
        <a-card>
          <div class="text-center">
            <h3>{{ statistics.totalQuestions }}</h3>
            <p>Tổng câu hỏi</p>
          </div>
        </a-card>
      </a-col>
      <a-col :span="8">
        <a-card>
          <div class="text-center">
            <h3>{{ statistics.activeExams }}</h3>
            <p>Đề thi đang hoạt động</p>
          </div>
        </a-card>
      </a-col>
      <a-col :span="8">
        <a-card>
          <div class="text-center">
            <h3>{{ statistics.completedExams }}</h3>
            <p>Đề thi đã hoàn thành</p>
          </div>
        </a-card>
      </a-col>
    </a-row>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { dashboardApi } from '@/services/dashboardService';

const statistics = ref({
  totalUsers: 0,
  totalStudents: 0,
  totalExams: 0,
  totalQuestions: 0,
  activeExams: 0,
  completedExams: 0
});

onMounted(async () => {
  const data = await dashboardApi.getAll();
  statistics.value = data;
});
</script>

<style scoped>
.text-center {
  text-align: center;
}
.mt-3 {
  margin-top: 1rem;
}
</style>