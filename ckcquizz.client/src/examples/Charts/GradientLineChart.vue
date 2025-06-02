<script setup>
import { onMounted, nextTick } from "vue";
import { Chart } from "chart.js";

const props = defineProps({
  id: {
    type: String,
    required: true,
  },
  height: {
    type: String,
    default: "300",
  },
  title: {
    type: String,
    default: "",
  },
  description: {
    type: String,
    default: "",
  },
  chart: {
    type: Object,
    required: true,
    labels: Array,
    datasets: {
      type: Array,
      label: String,
      data: Array,
    },
  },
});

onMounted(() => {
  nextTick(() => {
    const gradientLineChart = document.getElementById(props.id)?.getContext("2d");

    if (!gradientLineChart) {
      console.error(`Canvas with id "${props.id}" not found.`);
      return;
    }

    var gradientStroke1 = gradientLineChart.createLinearGradient(0, 230, 0, 50);
    gradientStroke1.addColorStop(1, "rgba(203,12,159,0.2)");
    gradientStroke1.addColorStop(0.2, "rgba(72,72,176,0.0)");
    gradientStroke1.addColorStop(0, "rgba(203,12,159,0)");

    var gradientStroke2 = gradientLineChart.createLinearGradient(0, 230, 0, 50);
    gradientStroke2.addColorStop(1, "rgba(20,23,39,0.2)");
    gradientStroke2.addColorStop(0.2, "rgba(72,72,176,0.0)");
    gradientStroke2.addColorStop(0, "rgba(20,23,39,0)");

    let chartStatus = Chart.getChart(props.id); // Check if the chart exists
    if (chartStatus !== undefined) {
      chartStatus.destroy(); // Destroy existing chart if it exists
    }

    const chartData = {
      labels: props.chart.labels,
      datasets: props.chart.datasets.map((dataset, index) => ({
        label: dataset.label,
        tension: 0.4,
        borderWidth: 3,
        pointRadius: 0,
        borderColor: index === 0 ? "#4BB543" : "#3A416F",
        backgroundColor: index === 0 ? gradientStroke1 : gradientStroke2,
        fill: true,
        data: dataset.data,
        maxBarThickness: 6,
      })),
    };

    const chartOptions = {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          display: false,
        },
      },
      interaction: {
        intersect: false,
        mode: "index",
      },
      scales: {
        y: {
          grid: {
            drawBorder: false,
            display: true,
            drawOnChartArea: true,
            drawTicks: false,
            borderDash: [5, 5],
          },
          ticks: {
            display: true,
            padding: 10,
            color: "#fbfbfb",
            font: {
              size: 11,
              family: "Open Sans",
              style: "normal",
              lineHeight: 2,
            },
          },
        },
        x: {
          grid: {
            drawBorder: false,
            display: false,
            drawOnChartArea: false,
            drawTicks: false,
            borderDash: [5, 5],
          },
          ticks: {
            display: true,
            color: "#ccc",
            padding: 20,
            font: {
              size: 11,
              family: "Open Sans",
              style: "normal",
              lineHeight: 2,
            },
          },
        },
      },
    };

    if (props.chart.datasets.length > 0) {
      new Chart(gradientLineChart, {
        type: "line",
        data: chartData,
        options: chartOptions,
      });
    }
  });
});
</script>

<template>
  <div class="card z-index-2">
    <div class="pb-0 card-header mb-0">
      <h6>{{ props.title }}</h6>

      <p v-if="props.description" class="text-sm" v-html="props.description" />
    </div>
    <div class="p-3 card-body">
      <div class="chart">
        <canvas
          :id="props.id"
          class="chart-canvas"
          :height="props.height"
        ></canvas>
      </div>
    </div>
  </div>
</template>
