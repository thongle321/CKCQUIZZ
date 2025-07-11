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

    <a-row :gutter="16" class="mt-3">
      <a-col :span="12">
        <a-card title="Đăng ký người dùng hàng tháng">
          <div class="chart-container">
            <apexchart type="line" :options="monthlyUserRegistrationChartOptions" :series="monthlyUserRegistrationSeries"></apexchart>
          </div>
        </a-card>
      </a-col>
      <a-col :span="12">
        <a-card title="Tỷ lệ hoàn thành bài thi">
          <div class="chart-container">
            <apexchart type="pie" :options="examCompletionRatesChartOptions" :series="examCompletionRatesSeries"></apexchart>
          </div>
        </a-card>
      </a-col>
    </a-row>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { dashboardApi } from '@/services/dashboardService';
import apexchart from 'vue3-apexcharts';

const statistics = ref({
  totalUsers: 0,
  totalStudents: 0,
  totalExams: 0,
  totalQuestions: 0,
  activeExams: 0,
  completedExams: 0,
  monthlyUserRegistrations: {},
  examCompletionRates: {}
});

const monthlyUserRegistrationSeries = computed(() => {
  return [{
    name: 'Số lượng đăng ký',
    data: Object.values(statistics.value.monthlyUserRegistrations)
  }];
});

const monthlyUserRegistrationChartOptions = computed(() => {
  return {
    chart: {
      height: 350,
      type: 'line',
      zoom: {
        enabled: false
      }
    },
    dataLabels: {
      enabled: false
    },
    stroke: {
      curve: 'smooth'
    },
    title: {
      text: 'Đăng ký người dùng hàng tháng',
      align: 'left'
    },
    grid: {
      row: {
        colors: ['#f3f3f3', 'transparent'], 
        opacity: 0.5
      },
    },
    xaxis: {
      categories: Object.keys(statistics.value.monthlyUserRegistrations),
      title: {
        text: 'Tháng'
      }
    },
  };
});

const examCompletionRatesSeries = computed(() => {
  return Object.values(statistics.value.examCompletionRates);
});

const examCompletionRatesChartOptions = computed(() => {
  return {
    chart: {
      width: 380,
      type: 'pie',
    },
    labels: Object.keys(statistics.value.examCompletionRates),
    responsive: [{
      breakpoint: 480,
      options: {
        chart: {
          width: 200
        },
        legend: {
          position: 'bottom'
        }
      }
    }],
  };
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
.chart-container {
  height: 350px;
  width: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
}
</style>