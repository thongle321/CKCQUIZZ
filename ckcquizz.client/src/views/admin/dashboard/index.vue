<template>
  <div class="container mt-4">
    <a-row :gutter="16">
      <a-col :span="8">
        <a-card>
          <div class="text-center">
            <Users :size="36" class="mb-2" />
            <h3>{{ statistics.totalUsers }}</h3>
            <p>Tổng người dùng</p>
          </div>
        </a-card>
      </a-col>
      <a-col :span="8">
        <a-card>
          <div class="text-center">
            <GraduationCap :size="36" class="mb-2" />
            <h3>{{ statistics.totalStudents }}</h3>
            <p>Tổng học sinh</p>
          </div>
        </a-card>
      </a-col>
      <a-col :span="8">
        <a-card>
          <div class="text-center">
            <BookOpen :size="36" class="mb-2" />
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
            <HelpCircle :size="36" class="mb-2" />
            <h3>{{ statistics.totalQuestions }}</h3>
            <p>Tổng câu hỏi</p>
          </div>
        </a-card>
      </a-col>
      <a-col :span="8">
        <a-card>
          <div class="text-center">
            <Play :size="36" class="mb-2" />
            <h3>{{ statistics.activeExams }}</h3>
            <p>Đề thi đang hoạt động</p>
          </div>
        </a-card>
      </a-col>
      <a-col :span="8">
        <a-card>
          <div class="text-center">
            <CheckCircle :size="36" class="mb-2" />
            <h3>{{ statistics.completedExams }}</h3>
            <p>Đề thi đã hoàn thành</p>
          </div>
        </a-card>
      </a-col>
    </a-row>

    <a-row :gutter="16" class="mt-3">
      <a-col :span="24">
        <a-card title="Thống kê người dùng hàng tháng">
          <div class="chart-container">
            <apexchart type="bar" :options="monthlyUserRegistrationChartOptions" :series="monthlyUserRegistrationSeries"></apexchart>
          </div>
        </a-card>
      </a-col>
    </a-row>
    <a-row :gutter="16" class="mt-3">
      <a-col :span="24">
        <a-card title="Tỷ lệ hoàn thành bài thi">
          <div class="chart-container">
            <apexchart type="donut" :options="examCompletionRatesChartOptions" :series="examCompletionRatesSeries"></apexchart>
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
import { Users, GraduationCap, BookOpen, HelpCircle, Play, CheckCircle } from 'lucide-vue-next';


const statistics = ref({
  totalUsers: 0,
  totalStudents: 0,
  totalExams: 0,
  totalQuestions: 0,
  activeExams: 0,
  completedExams: 0,
  monthlyUserRegistrations: {},
  monthlyStudentRegistrations: {},
  monthlyTeacherRegistrations: {},
  examCompletionRates: {}
});


const monthlyUserRegistrationSeries = computed(() => {
  return [
    { name: 'Tổng số người dùng', data: Object.values(statistics.value.monthlyUserRegistrations) },
    { name: 'Học sinh', data: Object.values(statistics.value.monthlyStudentRegistrations) },
    { name: 'Giáo viên', data: Object.values(statistics.value.monthlyTeacherRegistrations) }
  ];
});

const monthlyUserRegistrationChartOptions = computed(() => {
  return {
    chart: {
      type: 'bar', 
      height: '300',
      toolbar: {
        show: false 
      },
    },
    plotOptions: {
      bar: {
        horizontal: false,
        columnWidth: '55%',
        endingShape: 'rounded'
      },
    },
    dataLabels: {
      enabled: false,
    },
    stroke: {
      show: true,
      width: 2,
      colors: ['transparent']
    },
    xaxis: {
      categories: Object.keys(statistics.value.monthlyUserRegistrations),
      title: {
        text: 'Tháng'
      }
    },
    yaxis: {
      title: {
        text: 'Số lượng đăng ký'
      }
    },
    fill: {
      opacity: 1
    },
    tooltip: {
      y: {
        formatter: function (val) {
          return val + " người"
        }
      }
    },
    colors: ['#00E396', '#008FFB', '#FEB019'], 
    legend: {
      position: 'top',
      horizontalAlign: 'center',
    }
  }
});

const examCompletionRatesSeries = computed(() => {
  return Object.values(statistics.value.examCompletionRates);
});

const examCompletionRatesChartOptions = computed(() => {
  return {
    chart: {
      type: 'donut', 
      height: '300', 
      width: '100%'
    },
    labels: Object.keys(statistics.value.examCompletionRates), 
    colors: ['#00E396', '#F44336'], 
    legend: {
      position: 'right', 
    },
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
    dataLabels: {
        enabled: true,
        formatter: function (val) {
          return val.toFixed(1) + "%" 
        },
    }
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
  margin-top: 1.5rem;
}
.chart-container {
  width: 100%;
}
.ant-card {
  border-radius: 8px; 
  box-shadow: 0 4px 8px rgba(0,0,0,0.05); 
}
.mb-2 {
  margin-bottom: 0.5rem;
}
</style>