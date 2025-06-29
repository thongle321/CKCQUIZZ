<template>
  <a-card title="Ngân hàng câu hỏi" :bordered="false">
    <!-- Bộ lọc (không đổi) -->
    <a-row :gutter="[16, 16]" style="margin-bottom: 16px">
      <a-col :span="12">
        <a-select v-model:value="filters.maChuong" :options="chapterOptions" :loading="chaptersLoading"
          placeholder="Lọc theo chương" allow-clear style="width: 100%"></a-select>
      </a-col>
      <a-col :span="12">
        <!-- Input tìm kiếm theo từ khóa (giữ nguyên) -->
        <a-input v-model:value="filters.keyword" placeholder="Tìm theo nội dung câu hỏi..." allow-clear />
      </a-col>
    </a-row>

    <!-- Bảng câu hỏi -->
    <a-table :columns="columns" :data-source="filteredDataSource" :pagination="pagination" :loading="loading"
             @change="handleTableChange" row-key="macauhoi" size="small" :row-selection="rowSelection">
      <!-- SỬ DỤNG expandedRowRender ĐỂ HIỂN THỊ ĐÁP ÁN -->
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'status'">
          <a-tag v-if="existingQuestionIds.includes(record.macauhoi)" color="success">
            <template #icon>
              <CheckCircleOutlined />
            </template>
            Đã thêm
          </a-tag>
        </template>
      </template>
      <template #expandedRowRender="{ record }">
        <div style="padding-left: 24px;">
          <p><strong>Nội dung câu hỏi:</strong></p>
          <div v-html="record.noidung" style="margin-bottom: 16px;"></div>

          <p><strong>Các đáp án:</strong></p>
          <a-list item-layout="horizontal" :data-source="record.cauTraLois">
            <template #renderItem="{ item }">
              <a-list-item>
                <a-list-item-meta>
                  <template #title>
                    <span :style="{ color: item.dapan ? '#52c41a' : 'inherit', fontWeight: item.dapan ? 'bold' : 'normal' }">
                      {{ item.noidungtl }}
                    </span>
                  </template>
                  <template #avatar>
                    <CheckCircleTwoTone v-if="item.dapan" two-tone-color="#52c41a" />
                    <CloseCircleTwoTone v-else two-tone-color="#eb2f96" />
                  </template>
                </a-list-item-meta>
              </a-list-item>
            </template>
          </a-list>
        </div>
      </template>
    </a-table>
  </a-card>
</template>

<script setup>
  import { CheckCircleTwoTone, CloseCircleTwoTone, CheckCircleOutlined } from '@ant-design/icons-vue';
import { ref, reactive, onMounted, watch, computed } from 'vue';
import { message } from 'ant-design-vue';
import apiClient from '@/services/axiosServer';
import debounce from 'lodash/debounce';

const columns = [
  { title: 'Nội dung câu hỏi', dataIndex: 'noidung', key: 'noidung', ellipsis: true },
  { title: 'Độ khó', dataIndex: 'tenDoKho', key: 'tenDoKho', width: 120 },
  { title: 'Trạng thái', key: 'status', width: 120, align: 'center' },
];

const dataSource = ref([]);
const loading = ref(false);
const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: computed(() => filteredDataSource.value.length),
  hideOnSinglePage: true,
});
const uiState = reactive({
  loading: false,
  chaptersLoading: false,
});
const filters = reactive({ maChuong: null, keyword: '' });
const chapterOptions = ref([]);
const chaptersLoading = ref(false);
  const selectedRowKeys = ref([]);
  const userSelectedKeys = ref([]);
  const allSelectedKeys = computed(() => {
    // Dùng Set để đảm bảo không có key nào bị trùng lặp
    return [...new Set([...props.existingQuestionIds, ...userSelectedKeys.value])];
  });
  const rowSelection = computed(() => {
    return {
      // THAY ĐỔI SỐ 2: Sử dụng `allSelectedKeys` đã được gộp
      selectedRowKeys: allSelectedKeys.value,

      // THAY ĐỔI SỐ 3: Cập nhật logic `onChange`
      onChange: (selectedKeys) => {
        // `selectedKeys` là toàn bộ các key đang được check trên bảng.
        // Chúng ta cần lọc ra những key nào là do người dùng mới chọn,
        // bằng cách loại bỏ những key đã có sẵn trong đề thi.
        const newlySelected = selectedKeys.filter(key => !props.existingQuestionIds.includes(key));

        // Cập nhật lại state của chúng ta và gửi lên component cha
        userSelectedKeys.value = newlySelected;
        emit('selection-change', newlySelected);
      },

      // THAY ĐỔI SỐ 4: Bỏ thuộc tính `checked` đi
      getCheckboxProps: (record) => {
        const isInTest = props.existingQuestionIds.includes(record.macauhoi);
        return {
          disabled: isInTest, // Chỉ vô hiệu hóa, không "ép" check
          name: String(record.macauhoi),
        };
      },
    };
  });
const props = defineProps({
  maMonHoc: {
    type: Number,
    required: true,
  },
  existingQuestionIds: {
    type: Array,
    default: () => [],
  },
});


const filteredDataSource = computed(() => {
  let data = dataSource.value;
  if (filters.maChuong) {
    data = data.filter(item => item.machuong === filters.maChuong);
  }
  if (filters.keyword) {
    const keywordLower = filters.keyword.toLowerCase();
    data = data.filter(item =>
      item.noidung && item.noidung.toLowerCase().includes(keywordLower)
    );
  }
  return data;
});

const emit = defineEmits(['selection-change']);
// Hàm gọi API lấy danh sách câu hỏi
const fetchData = async () => {
  if (!props.maMonHoc) return;
  uiState.loading = true;
  try {
    const response = await apiClient.get(`/CauHoi/ByMonHoc/${props.maMonHoc}`);
    dataSource.value = response.data; // Lưu dữ liệu gốc
  } catch (error) {
    message.error("Lỗi: Không thể tải danh sách câu hỏi.");
    console.error("API /CauHoi/ByMonHoc/ failed:", error);
  } finally {
    uiState.loading = false;
  }
};

// Hàm lấy danh sách chương của môn học
const fetchChapters = async () => {
  if (!props.maMonHoc) return;
  uiState.chaptersLoading = true;
  try {
    const response = await apiClient.get(`/Chuong?mamonhocId=${props.maMonHoc}`);
    if (Array.isArray(response.data)) {
      chapterOptions.value = [
        { value: null, label: 'Tất cả chương' }, 
        ...response.data.map(c => ({
          value: c.machuong,
          label: c.tenchuong
        }))
      ];
    } else {
      chapterOptions.value = [{ value: null, label: 'Tất cả chương' }];
    }
  } catch (error) {
    message.error('Lỗi: Không thể tải danh sách chương.');
    console.error("API /Chuong failed:", error);
  } finally {
    uiState.chaptersLoading = false;
  }
};

const handleTableChange = (p) => {
  pagination.current = p.current;
  pagination.pageSize = p.pageSize;
};

const handleFilterChange = () => {
  pagination.current = 1;
};
watch(filters, handleFilterChange, { deep: true });
// Theo dõi sự thay đổi của từ khóa tìm kiếm
watch(() => filters.keyword, debounce(handleFilterChange, 500));

// Khi component được mount hoặc mã môn học thay đổi, tải lại dữ liệu
watch(
  () => props.maMonHoc,
  (newVal) => {
    if (newVal) {
      filters.maChuong = null;
      filters.keyword = '';
      selectedRowKeys.value = [];
      fetchChapters();
      fetchData();
    }
  },
  { immediate: true }
);
  watch(() => props.existingQuestionIds, (newIds) => {
    // Khi câu hỏi được thêm vào đề, `newIds` sẽ cập nhật.
    // Ta cần xóa những key đó khỏi `userSelectedKeys` vì chúng không còn là "lựa chọn mới" nữa.
    const stillSelectableKeys = userSelectedKeys.value.filter(key => !newIds.includes(key));
    if (stillSelectableKeys.length !== userSelectedKeys.value.length) {
      userSelectedKeys.value = stillSelectableKeys;
      emit('selection-change', stillSelectableKeys);
    }
  }, { deep: true });
  defineExpose({
    fetchData
  });
</script>
