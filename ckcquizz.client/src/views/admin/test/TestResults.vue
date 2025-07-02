<template>
  <div>
    <!-- Phần Header hiển thị Tên Đề Thi -->
    <a-page-header :title="`Kết quả thi: ${deThiInfo.tende}`"
                   :sub-title="`Môn học: ${deThiInfo.tenMonHoc}`"
                   @back="() => router.back()">
      <template #extra>
        <a-button type="primary" size="middle" @click="exportToExcel" :loading="isExporting">
          <template #icon>
            <Download />
          </template>
          Xuất bảng điểm
        </a-button>
      </template>
    </a-page-header>

    <div style="padding: 0 24px 24px 24px;">
      <a-card :bordered="false">
        <a-tabs v-model:activeKey="activeTab">
          <!-- TAB 1: BẢNG ĐIỂM -->
          <a-tab-pane key="1" tab="Bảng điểm">
            <!-- Thanh Filter và Hành động -->
            <a-row :gutter="[16, 16]" class="mb-4">
              <a-col :xs="24" :sm="12" :md="8">
                <a-select v-model:value="filters.selectedLop"
                          placeholder="Lọc theo lớp học phần"
                          :options="lopOptions"
                          allow-clear
                          style="width: 100%;"></a-select>
              </a-col>
              <a-col :xs="24" :sm="12" :md="6">
                <a-select v-model:value="filters.selectedStatus"
                          placeholder="Lọc theo trạng thái"
                          :options="statusOptions"
                          allow-clear
                          style="width: 100%;"></a-select>
              </a-col>
              <a-col :xs="24" :sm="12" :md="10">
                <a-input v-model:value="filters.searchText" placeholder="Tìm kiếm theo tên hoặc MSSV..." allow-clear>
                  <template #prefix>
                    <Search size="14" />
                  </template>
                </a-input>
              </a-col>
            </a-row>

            <!-- Bảng Dữ liệu -->
            <a-table :columns="columns"
                     :dataSource="filteredData"
                     :loading="tableState.isLoading"
                     :scroll="{ x: 1000 }"
                     rowKey="mssv">
              <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'hoten'">
                  <span>{{ record.ho }} {{ record.ten }}</span>
                </template>
                <template v-if="column.key === 'trangthai'">
                  <a-tag :color="getStatusColor(record.trangThai)">
                    {{ record.trangThai }}
                  </a-tag>
                </template>
                <template v-if="column.key === 'diem'">
                  <a-tag v-if="record.diem !== null" :color="record.diem >= 5 ? 'success' : 'error'">
                    {{ record.diem.toFixed(2) }}
                  </a-tag>
                  <span v-else>N/A</span>
                </template>
                <template v-if="column.key === 'thoigianvaothi'">
                  <span>{{ record.thoiGianVaoThi ? dayjs(record.thoiGianVaoThi).format('HH:mm - DD/MM/YYYY') : 'N/A' }}</span>
                </template>
                <template v-if="column.key === 'thoigianthi'">
                  <span>{{ formatDuration(record.thoiGianThi) }}</span>
                </template>
                <template v-if="column.key === 'actions'">
                  <a-tooltip title="Xem chi tiết bài làm" v-if="record.trangThai === 'Đã nộp'">
                    <a-button type="text" shape="circle" @click="viewSubmission(record)">
                      <Eye />
                    </a-button>
                  </a-tooltip>
                </template>
              </template>
            </a-table>
          </a-tab-pane>

          <!-- TAB 2: THỐNG KÊ -->
          <a-tab-pane key="2" tab="Thống kê">
            <div v-if="tableState.isLoading" class="loading-container">
              <a-spin size="large" />
            </div>
            <div v-else-if="tableState.results.length === 0">
              <a-empty description="Không có dữ liệu để thống kê" />
            </div>
            <div v-else>
              <!-- BỘ LỌC -->
              <a-row justify="start" class="mb-4">
                <a-col :xs="24" :sm="12" :md="8" :lg="6">
                  <a-select v-model:value="selectedLopForStats"
                            :options="statsLopOptions"
                            style="width: 100%;">
                  </a-select>
                </a-col>
              </a-row>

              <!-- CÁC THẺ THỐNG KÊ -->
              <a-row :gutter="[16, 16]">
                <a-col :xs="24" :sm="12" :md="6">
                  <a-card :bordered="false">
                    <a-statistic title="Thí sinh đã nộp" :value="statsData.submittedCount" />
                  </a-card>
                </a-col>
                <a-col :xs="24" :sm="12" :md="6">
                  <a-card :bordered="false">
                    <a-statistic title="Thí sinh vắng thi" :value="statsData.absentCount" />
                  </a-card>
                </a-col>
                <a-col :xs="24" :sm="12" :md="6">
                  <a-card :bordered="false">
                    <a-statistic title="Điểm trung bình" :value="statsData.averageScore" />
                  </a-card>
                </a-col>
                <a-col :xs="24" :sm="12" :md="6">
                  <a-card :bordered="false">
                    <a-statistic title="Điểm cao nhất" :value="statsData.highestScore" />
                  </a-card>
                </a-col>
              </a-row>

              <!-- BIỂU ĐỒ -->
              <a-row style="margin-top: 24px;">
                <a-col :span="24">
                  <a-card :bordered="false">
                    <apexchart type="bar" height="350" :options="chartOptions" :series="chartSeries"></apexchart>
                  </a-card>
                </a-col>
              </a-row>
            </div>
          </a-tab-pane>
        </a-tabs>
      </a-card>
    </div>
  </div>
</template>

<script setup>
  import { ref, reactive, computed, onMounted } from 'vue';
  import { useRoute, useRouter } from 'vue-router';
  import { message } from 'ant-design-vue';
  import { Search, Download, Eye } from 'lucide-vue-next';
  import apiClient from "@/services/axiosServer";
  import dayjs from 'dayjs';
  import duration from 'dayjs/plugin/duration';
  dayjs.extend(duration);

  // --- SETUP ---
  const route = useRoute();
  const router = useRouter();
  const deThiId = ref(route.params.id);
  const activeTab = ref('1');
  const isExporting = ref(false);

  // --- STATE MANAGEMENT ---
  const deThiInfo = reactive({
    tende: 'Đang tải...',
    tenMonHoc: '...',
  });

  const tableState = reactive({
    results: [], // Dữ liệu gốc từ API
    isLoading: true,
  });

  const filters = reactive({
    searchText: '',
    selectedLop: undefined,
    selectedStatus: undefined,
  });

  const lopOptions = ref([]);
  const statusOptions = ref([
    { value: 'Đã nộp', label: 'Đã nộp' },
    { value: 'Vắng thi', label: 'Vắng thi' },
  ]);
  // --- TABLE COLUMNS DEFINITION ---
  const columns = [
    { title: 'MSSV', dataIndex: 'mssv', key: 'mssv', sorter: (a, b) => a.mssv.localeCompare(b.mssv), fixed: 'left', width: 120 },
    { title: 'Họ tên', key: 'hoten', sorter: (a, b) => `${a.ho} ${a.ten}`.localeCompare(`${b.ho} ${b.ten}`), fixed: 'left', width: 200 },
    { title: 'Trạng thái', dataIndex: 'trangThai', key: 'trangthai', sorter: (a, b) => a.trangThai.localeCompare(b.trangThai), width: 120, align: 'center' },
    { title: 'Điểm', dataIndex: 'diem', key: 'diem', sorter: (a, b) => (a.diem ?? -1) - (b.diem ?? -1), width: 100, align: 'center' },
    { title: 'Thời gian vào thi', dataIndex: 'thoiGianVaoThi', key: 'thoigianvaothi', sorter: (a, b) => dayjs(a.thoiGianVaoThi).unix() - dayjs(b.thoiGianVaoThi).unix(), width: 180 },
    { title: 'Thời gian thi', dataIndex: 'thoiGianThi', key: 'thoigianthi', sorter: (a, b) => (a.thoiGianThi ?? 0) - (b.thoiGianThi ?? 0), width: 150 },
    { title: 'Số lần thoát', dataIndex: 'solanthoat', key: 'solanthoat', sorter: (a, b) => a.solanthoat - b.solanthoat, width: 130, align: 'center' },
    { title: 'Hành động', key: 'actions', fixed: 'right', width: 100, align: 'center' },
  ];

  // --- API CALL ---
  const fetchData = async () => {
    tableState.isLoading = true;
    try {
      const response = await apiClient.get(`/DeThi/results/${deThiId.value}`);
      const data = response.data;
      console.log(data);

      // Cập nhật state với dữ liệu từ API
      Object.assign(deThiInfo, data.deThiInfo);
      tableState.results = data.results;

      // Chuyển đổi danh sách lớp thành định dạng cho a-select
      lopOptions.value = data.lops.map(lop => ({
        value: lop.malop,
        label: lop.tenlop,
      }));

    } catch (error) {
      console.error("Lỗi khi tải dữ liệu kết quả thi:", error);
      message.error("Không thể tải dữ liệu kết quả thi. Vui lòng thử lại.");
      // Có thể điều hướng về trang trước nếu lỗi nghiêm trọng
      // router.back();
    } finally {
      tableState.isLoading = false;
    }
  };

  // --- COMPUTED PROPERTIES ---
  const filteredData = computed(() => {
    let data = [...tableState.results];

    // 1. Lọc theo lớp học phần
    if (filters.selectedLop) {
      data = data.filter(item => item.malop === filters.selectedLop);
    }
    // Lọc theo trạng thái
    if (filters.selectedStatus) {
      data = data.filter(item => item.trangThai === filters.selectedStatus);
    }

    // 2. Lọc theo text search
    if (filters.searchText) {
      const lowercasedFilter = filters.searchText.toLowerCase();
      data = data.filter(item =>
        item.mssv.toLowerCase().includes(lowercasedFilter) ||
        `${item.ho} ${item.ten}`.toLowerCase().includes(lowercasedFilter)
      );
    }

    return data;
  });
  const getStatusColor = (status) => {
    switch (status) {
      case 'Đã nộp':
        return 'green';
      case 'Chưa nộp':
        return 'orange';
      case 'Vắng thi':
        return 'default';
      default:
        return 'default';
    }
  };
  // --- METHODS / HANDLERS ---
  const formatDuration = (seconds) => {
    if (seconds === null || seconds === undefined) return 'N/A';
    const d = dayjs.duration(seconds, 'seconds');
    const hours = Math.floor(d.asHours());
    const mins = d.minutes();
    const secs = d.seconds();
    let result = '';
    if (hours > 0) result += `${hours} giờ `;
    if (mins > 0) result += `${mins} phút `;
    if (secs > 0 || result === '') result += `${secs} giây`;
    return result.trim();
  };

  const viewSubmission = (record) => {
    console.log("Xem chi tiết bài làm của:", record);
    message.info("Chức năng xem chi tiết bài làm đang được phát triển.");
  };

  const exportToExcel = () => {
    console.log("Xuất dữ liệu ra Excel:", filteredData.value);
    isExporting.value = true;
    message.loading({ content: 'Đang xuất file...', key: 'exporting' });
    // Logic xuất file excel ở đây (ví dụ dùng thư viện 'xlsx')
    setTimeout(() => {
      message.success({ content: 'Xuất bảng điểm thành công!', key: 'exporting', duration: 2 });
      isExporting.value = false;
    }, 1500);
  };
  //Thống kê
  const selectedLopForStats = ref(null); // null nghĩa là 'Tất cả'

  // --- COMPUTED PROPERTIES CHO TAB THỐNG KÊ ---

  // 1. Tạo options cho bộ lọc lớp, thêm lựa chọn "Tất cả"
  const statsLopOptions = computed(() => {
    return [
      { value: null, label: 'Tất cả các lớp' },
      ...lopOptions.value
    ];
  });

  // 2. Lọc danh sách kết quả dựa trên lớp được chọn
  const filteredResultsForStats = computed(() => {
    if (!selectedLopForStats.value) {
      return tableState.results; // Trả về tất cả nếu không chọn lớp nào
    }
    return tableState.results.filter(item => item.malop === selectedLopForStats.value);
  });

  // 3. Tính toán tất cả các chỉ số thống kê
  const statsData = computed(() => {
    const results = filteredResultsForStats.value;
    if (!results || results.length === 0) {
      return {
        submittedCount: 0,
        absentCount: 0,
        averageScore: 'N/A',
        highestScore: 'N/A',
        scoreDistribution: Array(11).fill(0), // Mảng 11 số 0 cho điểm từ 0-10
      };
    }

    const submittedExams = results.filter(r => r.trangThai === 'Đã nộp' && r.diem !== null);
    const totalStudents = results.length;
    const submittedCount = submittedExams.length;
    const absentCount = totalStudents - submittedCount;

    let averageScore = 'N/A';
    let highestScore = 'N/A';

    // Mảng để đếm số lượng sinh viên cho mỗi mức điểm (0-10)
    const scoreDistribution = Array(11).fill(0);

    if (submittedCount > 0) {
      const totalScore = submittedExams.reduce((sum, exam) => sum + exam.diem, 0);
      averageScore = (totalScore / submittedCount).toFixed(2);

      highestScore = Math.max(...submittedExams.map(exam => exam.diem)).toFixed(2);

      // Tính toán phân bổ điểm cho biểu đồ
      submittedExams.forEach(exam => {
        const score = Math.round(exam.diem);
        if (score >= 0 && score <= 10) {
          scoreDistribution[score]++;
        }
      });
    }

    return {
      submittedCount,
      absentCount,
      averageScore,
      highestScore,
      scoreDistribution,
    };
  });


  // 4. Chuẩn bị dữ liệu cho Biểu đồ Cột
  const chartSeries = computed(() => [
    {
      name: 'Số lượng sinh viên',
      data: statsData.value.scoreDistribution,
    },
  ]);

  const chartOptions = computed(() => ({
    chart: {
      type: 'bar',
      height: 350,
      toolbar: {
        show: true, // Cho phép người dùng tải ảnh biểu đồ
      },
    },
    plotOptions: {
      bar: {
        horizontal: false,
        columnWidth: '55%',
        endingShape: 'rounded',
        distributed: true, // Mỗi cột một màu
      },
    },
    dataLabels: {
      enabled: true, // Hiển thị số liệu trên cột
    },
    stroke: {
      show: true,
      width: 2,
      colors: ['transparent'],
    },
    xaxis: {
      categories: ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10'],
      title: {
        text: 'Mức điểm',
      }
    },
    yaxis: {
      title: {
        text: '',
      },
    },
    fill: {
      opacity: 1,
    },
    legend: {
      show: false // Ẩn chú thích vì đã dùng distributed colors
    },
    tooltip: {
      y: {
        formatter: function (val) {
          return val + " sinh viên";
        },
      },
    },
    title: {
      text: 'Thống kê điểm thi',
      align: 'center',
      style: {
        fontSize: '16px'
      }
    }
  }));
  // --- LIFECYCLE HOOKS ---
  onMounted(() => {
    fetchData();
  });
</script>

<style scoped>
  .mb-4 {
    margin-bottom: 16px;
  }
  .loading-container {
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 400px;
  }

  /* Làm cho card thống kê đẹp hơn */
  :deep(.ant-card-body) {
    padding: 16px;
  }

  :deep(.ant-statistic-title) {
    font-size: 14px;
    color: rgba(0, 0, 0, 0.65);
  }

  :deep(.ant-statistic-content) {
    font-size: 24px;
    font-weight: 600;
  }
</style>
