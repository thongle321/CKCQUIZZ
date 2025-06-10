<template>
  <div class="page-container">
    <a-card>
      <!-- Tiêu đề và nút Thêm mới -->
      <template #title>
        <h3>Tất cả câu hỏi</h3>
      </template>
      <template #extra>
        <a-button type="primary" @click="addNewQuestion">
          <template #icon>
            <PlusOutlined />
          </template>
          THÊM CÂU HỎI MỚI
        </a-button>
      </template>

      <!-- Khu vực bộ lọc -->
      <div class="filter-section">
        <a-row :gutter="[16, 16]">
          <a-col :xs="24" :sm="12" :md="6">
            <a-select v-model:value="filters.subject"
                      placeholder="Chọn môn học"
                      style="width: 100%"
                      allow-clear>
              <a-select-option value="Lập trình hướng đối tượng">Lập trình hướng đối tượng</a-select-option>
              <a-select-option value="Cơ sở dữ liệu">Cơ sở dữ liệu</a-select-option>
            </a-select>
          </a-col>
          <a-col :xs="24" :sm="12" :md="6">
            <a-select v-model:value="filters.chapter"
                      placeholder="Chọn chương"
                      style="width: 100%"
                      allow-clear>
              <!-- Dữ liệu chương sẽ được load dựa trên môn học đã chọn -->
            </a-select>
          </a-col>
          <a-col :xs="24" :sm="12" :md="6">
            <a-select v-model:value="filters.difficulty"
                      placeholder="Độ khó"
                      style="width: 100%">
              <a-select-option value="Tất cả">Tất cả</a-select-option>
              <a-select-option value="Cơ bản">Cơ bản</a-select-option>
              <a-select-option value="Trung bình">Trung bình</a-select-option>
              <a-select-option value="Nâng cao">Nâng cao</a-select-option>
            </a-select>
          </a-col>
          <a-col :xs="24" :sm="12" :md="6">
            <a-input-search v-model:value="filters.searchText"
                            placeholder="Nội dung câu hỏi..."
                            @search="onSearch" />
          </a-col>
        </a-row>
      </div>

      <!-- Bảng dữ liệu -->
      <a-table :columns="columns"
               :data-source="dataSource"
               :pagination="pagination"
               :loading="loading"
               @change="handleTableChange"
               row-key="id">
        <template #bodyCell="{ column, record }">
          <!-- Custom render cho cột Môn học để có thể click -->
          <template v-if="column.key === 'subject'">
            <a>{{ record.subject }}</a>
          </template>

          <!-- Custom render cho cột Hành động -->
          <template v-if="column.key === 'action'">
            <a-space>
              <a-button type="primary" size="small" @click="editQuestion(record)">
                <template #icon>
                  <EditOutlined />
                </template>
              </a-button>
              <a-button type="danger" size="small" @click="deleteQuestion(record)">
                <template #icon>
                  <DeleteOutlined />
                </template>
              </a-button>
            </a-space>
          </template>
        </template>
      </a-table>
    </a-card>
  </div>
</template>

<script setup>
  import { ref, reactive, onMounted } from 'vue';
  import {
    PlusOutlined,
    EditOutlined,
    DeleteOutlined,
  } from '@ant-design/icons-vue';
  import { message } from 'ant-design-vue';

  // --- TRẠNG THÁI VÀ DỮ LIỆU ---

  // Dữ liệu cho bộ lọc
  const filters = reactive({
    subject: undefined,
    chapter: undefined,
    difficulty: 'Tất cả',
    searchText: '',
  });

  // Cấu hình cột cho bảng
  const columns = [
    { title: 'ID', dataIndex: 'id', key: 'id', width: 80 },
    { title: 'Nội dung câu hỏi', dataIndex: 'content', key: 'content' },
    { title: 'Môn học', dataIndex: 'subject', key: 'subject', width: 220 },
    { title: 'Độ khó', dataIndex: 'difficulty', key: 'difficulty', width: 150 },
    { title: 'Hành động', key: 'action', width: 120, align: 'center' },
  ];

  // Dữ liệu mẫu (Trong ứng dụng thật, dữ liệu này sẽ được lấy từ API)
  const mockData = [];
  for (let i = 1; i <= 532; i++) {
    let difficulty;
    if (i % 3 === 0) difficulty = 'Nâng cao';
    else if (i % 3 === 1) difficulty = 'Cơ bản';
    else difficulty = 'Trung bình';

    mockData.push({
      id: i,
      content: `Nội dung của câu hỏi số ${i}: Lorem ipsum dolor sit amet...`,
      subject: 'Lập trình hướng đối tượng',
      difficulty: difficulty,
    });
  }

  const dataSource = ref([]);
  const loading = ref(false);

  // Cấu hình phân trang
  const pagination = reactive({
    current: 1,
    pageSize: 10,
    total: mockData.length,
    showSizeChanger: false, // Ẩn tuỳ chọn thay đổi số lượng item/trang
    showLessItems: true,
  });

  // --- PHƯƠNG THỨC ---

  // Hàm giả lập lấy dữ liệu từ API
  const fetchData = (page = 1, pageSize = 10) => {
    loading.value = true;
    // Giả lập độ trễ mạng
    setTimeout(() => {
      const start = (page - 1) * pageSize;
      const end = start + pageSize;
      dataSource.value = mockData.slice(start, end);
      pagination.current = page;
      pagination.total = mockData.length;
      loading.value = false;
    }, 500);
  };

  // Xử lý sự kiện thay đổi trang hoặc sắp xếp
  const handleTableChange = (pag) => {
    fetchData(pag.current, pag.pageSize);
  };

  // Xử lý khi tìm kiếm
  const onSearch = () => {
    message.info(`Đang tìm kiếm với nội dung: "${filters.searchText}"`);
    // Ở đây bạn sẽ gọi API để lọc dữ liệu
  };

  // Các hành động
  const addNewQuestion = () => {
    message.success('Chuyển đến trang thêm câu hỏi mới!');
    // Logic điều hướng đến trang tạo mới
  };

  const editQuestion = (record) => {
    message.info(`Sửa câu hỏi ID: ${record.id}`);
    // Logic điều hướng đến trang sửa
  };

  const deleteQuestion = (record) => {
    // Thường sẽ có một modal xác nhận ở đây
    message.error(`Xóa câu hỏi ID: ${record.id}`);
    // Logic gọi API để xóa
  };

  // Lấy dữ liệu lần đầu khi component được tạo
  onMounted(() => {
    fetchData();
  });
</script>

<style scoped>
  .page-container {
    padding: 24px;
    background-color: #f0f2f5;
  }

  .filter-section {
    margin-bottom: 24px;
  }
</style>
