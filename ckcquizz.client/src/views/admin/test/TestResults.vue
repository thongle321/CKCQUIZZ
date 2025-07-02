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
            <div style="min-height: 400px; display: flex; align-items: center; justify-content: center;">
              <p>Tính năng thống kê trực quan sẽ được phát triển ở đây.</p>
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

  // --- LIFECYCLE HOOKS ---
  onMounted(() => {
    fetchData();
  });
</script>

<style scoped>
  .mb-4 {
    margin-bottom: 16px;
  }
</style>
