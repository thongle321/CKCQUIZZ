<template>
  <div class="page-container">
    <a-card>
      <div class="page-header">
        <h3>Tất cả câu hỏi</h3>
        <a-button type="primary" @click="showAddModal">
          <template #icon>
            <PlusOutlined />
          </template>
          Thêm câu hỏi mới
        </a-button>
      </div>
      
      <a-card class="filter-card" :bordered="false">

        <a-row :gutter="[16, 16]">
          <!-- Filter Môn học -->
          <a-col :span="6">
            <a-select v-model:value="filters.maMonHoc" placeholder="Chọn môn học" style="width: 100%" allow-clear @change="handleSubjectChange">
              <a-select-option v-for="subject in subjects" :key="subject.mamonhoc" :value="subject.mamonhoc">
                {{ subject.tenmonhoc }}
              </a-select-option>
            </a-select>
          </a-col>

          <!-- Filter Chương -->
          <a-col :span="6">
            <a-select v-model:value="filters.maChuong" placeholder="Chọn chương" style="width: 100%" :disabled="!filters.maMonHoc" allow-clear @change="handleFilterChange">
              <a-select-option v-for="chapter in chapters" :key="chapter.machuong" :value="chapter.machuong">
                {{ chapter.tenchuong }}
              </a-select-option>
            </a-select>
          </a-col>

          <!-- Filter Độ khó -->
          <a-col :span="6">
            <a-select v-model:value="filters.doKho" placeholder="Độ khó" style="width: 100%" allow-clear @change="handleFilterChange">
              <a-select-option :value="null">Tất cả</a-select-option>
              <a-select-option :value="1">Cơ bản</a-select-option>
              <a-select-option :value="2">Trung bình</a-select-option>
              <a-select-option :value="3">Nâng cao</a-select-option>
            </a-select>
          </a-col>
        </a-row>

        <!-- Filter Tìm kiếm theo nội dung -->
        <a-row style="margin-top: 16px">
          <a-col :span="24">
            <a-input-search v-model:value="filters.keyword" placeholder="Nội dung câu hỏi" @search="handleFilterChange" />
          </a-col>
        </a-row>

      </a-card>

      <a-table :columns="columns"
               :data-source="dataSource"
               :pagination="pagination"
               :loading="Modalloading"
               @change="handleTableChange"
               row-key="macauhoi">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'tenMonHoc'">
            <a>{{ record.tenMonHoc }}</a>
          </template>

          <template v-if="column.key === 'trangthai'">
            <span :style="{ color: record.trangthai ? 'green' : 'red' }">
              {{ record.trangthai ? 'Hiển thị' : 'Ẩn' }}
            </span>
          </template>

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
  import { ref, reactive, onMounted, watch } from 'vue';
  import debounce from 'lodash/debounce';
  import { PlusOutlined, EditOutlined, DeleteOutlined } from '@ant-design/icons-vue';
  import { message } from 'ant-design-vue';
  import axios from 'axios';
import apiClient from '../../../services/axiosServer';

  const columns = [
    { title: 'ID', dataIndex: 'macauhoi', key: 'macauhoi', width: 80 },
    { title: 'Nội dung câu hỏi', dataIndex: 'noidung', key: 'noidung' },
    { title: 'Môn học', dataIndex: 'tenMonHoc', key: 'tenMonHoc', width: 180 },
    { title: 'Độ khó', dataIndex: 'tenDoKho', key: 'tenDoKho', width: 150 },
    { title: 'Trạng thái', dataIndex: 'trangthai', key: 'trangthai', width: 120 },
    { title: 'Hành động', key: 'action', width: 120, align: 'center' },
  ];


  const dataSource = ref([]);
  const Modalloading = ref(false);
  const pagination = reactive({
    current: 1,
    pageSize: 10,
    total: 0,
  });
  const subjects = ref([]); 
  const chapters = ref([]);
  const filters = reactive({
    maMonHoc: null,
    maChuong: null,
    doKho: null,
    keyword: '',
  });
  const searchTerm = ref('');

  const fetchData = async () => {
    Modalloading.value = true;
    try {
      // Gửi tất cả các giá trị trong object 'filters' làm tham số
      const params = {
        ...filters, 
        pageNumber: pagination.current,
        pageSize: pagination.pageSize,
      };
      const response = await axios.get('https://localhost:7254/api/CauHoi', { params });
      dataSource.value = response.data.items;
      pagination.total = response.data.totalCount;
    } catch (error) {
      console.error('Lỗi tải dữ liệu câu hỏi:', error);
      message.error('Không thể tải dữ liệu câu hỏi');
    } finally {
      Modalloading.value = false;
    }
  };
  const fetchSubjects = async () => {
    try {
      const response = await apiClient.get('/api/MonHoc');
      subjects.value = response.data;
    } catch (error) {
      message.error('Không thể tải danh sách môn học');
    }
  };

  const fetchChapters = async (subjectId) => {
    if (!subjectId) {
      chapters.value = [];
      return;
    }
    try {
      // Sử dụng đúng tên tham số "mamonhocId" như trong backend
      const response = await apiClient.get(`https://localhost:7254/api/Chuong?mamonhocId=${subjectId}`);
      chapters.value = response.data;
    } catch (error) {
      message.error('Không thể tải danh sách chương');
    }
  };

  const handleTableChange = (paginationChange) => {
    pagination.current = paginationChange.current;
    pagination.pageSize = paginationChange.pageSize;
    fetchData();
  };
  const handleFilterChange = () => {
    pagination.current = 1; // Luôn quay về trang 1 khi lọc
    fetchData();
  };
  const handleSubjectChange = (subjectId) => {
    filters.maChuong = null; // Reset chương khi đổi môn học
    fetchChapters(subjectId);
    handleFilterChange(); // Tải lại bảng theo môn học mới
  };

  watch(() => filters.keyword, debounce(() => {
    handleFilterChange();
  }, 500));

  onMounted(() => {
    fetchData();
    fetchSubjects();
  });


</script>

