<template>
  <a-card title="Danh sách Đề kiểm tra" style="width: 100%">
    <!-- Thanh công cụ (đã bị vô hiệu hóa) -->
    <a-row :gutter="16" style="margin-bottom: 24px;">
      <a-col :span="8">
        <a-input v-model:value="searchText" placeholder="Tìm kiếm theo tên đề thi..." allow-clear>
          <template #prefix>
            <Search size="14" />
          </template>
        </a-input>
      </a-col>
      <a-col :span="16" style="display: flex; justify-content: flex-end;">
        <a-button type="primary" size="large" @click="openAddModal" >
          <template #icon>
            <Plus />
          </template>
          Thêm đề thi
        </a-button>
      </a-col>
    </a-row>

    <!-- Bảng hiển thị danh sách đề thi -->
    <a-table :dataSource="filteredDeThis"
             :columns="columns"
             :loading="isLoading"
             rowKey="made">
      <template #bodyCell="{ column, record }">
        <!-- Cột Trạng thái với Tag màu -->
        <template v-if="column.key === 'trangthai'">
          <a-tag :color="getStatusColor(record.trangthai)">
            {{ record.trangthai }}
          </a-tag>
        </template>
        <!-- Cột Ngày tháng với xử lý giá trị "rác" -->
        <template v-if="column.key === 'thoigianbatdau' || column.key === 'thoigianketthuc'">
          <span>{{ formatDisplayDate(record[column.dataIndex]) }}</span>
        </template>
        <!-- Cột Hành động (đã bị vô hiệu hóa) -->
        <template v-if="column.key === 'actions'">
          <a-space>
            <a-tooltip title="Sửa đề thi">
              <a-button type="text" :icon="h(SquarePen)"  />
            </a-tooltip>
            <a-tooltip title="Xoá đề thi">
              <a-button type="text" danger :icon="h(Trash2)"  />
            </a-tooltip>
          </a-space>
        </template>
      </template>
    </a-table>
    <!-- Modal Thêm Đề thi -->
    <a-modal title="Tạo Đề thi mới"
             :open="showModal"
             @ok="handleOk"
             @cancel="handleCancel"
             :confirmLoading="isSaving"
             width="900px"
             destroyOnClose>
      <a-form ref="formRef" :model="currentDeThi" layout="vertical" :rules="rules">
        <a-row :gutter="24">
          <!-- Cột trái -->
          <a-col :span="12">
            <a-form-item label="Tên đề thi" name="tende" required>
              <a-input v-model:value="currentDeThi.tende" placeholder="VD: Kiểm tra cuối kỳ môn Lập trình Web" />
            </a-form-item>
            <a-form-item label="Thời gian diễn ra" name="thoigian" required>
              <a-range-picker v-model:value="currentDeThi.thoigian" show-time format="YYYY-MM-DD HH:mm" style="width: 100%;" />
            </a-form-item>
            <a-form-item label="Thời gian làm bài (phút)" name="thoigianthi" required>
              <a-input-number v-model:value="currentDeThi.thoigianthi" :min="1" placeholder="VD: 60" style="width: 100%;" />
            </a-form-item>
            <a-form-item label="Giao cho lớp" name="malops" required>
              <a-select v-model:value="currentDeThi.malops"
                        mode="multiple"
                        placeholder="Chọn các lớp được giao đề"
                        :options="lops" />
            </a-form-item>
          </a-col>

          <!-- Cột phải -->
          <a-col :span="12">
            <a-form-item label="Loại đề" name="loaide">
              <a-radio-group v-model:value="currentDeThi.loaide">
                <a-radio :value="1">Lấy từ ngân hàng câu hỏi</a-radio>
                <a-radio :value="2" disabled>Tự soạn (chưa hỗ trợ)</a-radio>
              </a-radio-group>
            </a-form-item>

            <div v-if="currentDeThi.loaide === 1">
              <a-form-item label="Chọn chương" name="machuongs" required>
                <a-select v-model:value="currentDeThi.machuongs"
                          mode="multiple"
                          placeholder="Chọn các chương để lấy câu hỏi"
                          :options="chuongs"></a-select>
              </a-form-item>
              <a-row :gutter="16">
                <a-col :span="8"><a-form-item label="Số câu dễ" name="socaude"><a-input-number v-model:value="currentDeThi.socaude" :min="0" style="width: 100%" /></a-form-item></a-col>
                <a-col :span="8"><a-form-item label="Số câu TB" name="socautb"><a-input-number v-model:value="currentDeThi.socautb" :min="0" style="width: 100%" /></a-form-item></a-col>
                <a-col :span="8"><a-form-item label="Số câu khó" name="socaukho"><a-input-number v-model:value="currentDeThi.socaukho" :min="0" style="width: 100%" /></a-form-item></a-col>
              </a-row>
            </div>
          </a-col>
        </a-row>

        <a-divider>Tùy chọn hiển thị</a-divider>
        <a-row :gutter="16">
          <a-col :span="6"><a-form-item><a-switch v-model:checked="currentDeThi.troncauhoi" /> Trộn câu hỏi</a-form-item></a-col>
          <a-col :span="6"><a-form-item><a-switch v-model:checked="currentDeThi.xemdiemthi" /> Xem điểm thi</a-form-item></a-col>
          <a-col :span="6"><a-form-item><a-switch v-model:checked="currentDeThi.hienthibailam" /> Xem lại bài làm</a-form-item></a-col>
          <a-col :span="6"><a-form-item><a-switch v-model:checked="currentDeThi.xemdapan" /> Xem đáp án</a-form-item></a-col>
        </a-row>
      </a-form>
    </a-modal>
  </a-card>
</template>

<script setup>
  import { ref, computed, onMounted, h } from 'vue';
  import { message } from 'ant-design-vue';
  import { Search, Plus, SquarePen, Trash2 } from 'lucide-vue-next';
  import dayjs from 'dayjs';
  import axios from 'axios';
import apiClient from "@/services/axiosServer";

  // --- CẤU HÌNH ---
  // !!! QUAN TRỌNG: Thay đổi URL này thành địa chỉ API của bạn

  // --- TRẠNG THÁI (STATE) ---
  const searchText = ref('');
  const isLoading = ref(true);
  const deThis = ref([]);
  // --- Các state mới cho modal ---
const showModal = ref(false);
const isSaving = ref(false);
const formRef = ref(null);
const currentDeThi = ref({});

// Dữ liệu cho form

const lops = ref([]); 
const chuongs = ref([]);

const getInitialFormState = () => ({
  tende: '',
  thoigian: [], // Dùng mảng rỗng cho Range Picker
  thoigianthi: 60,
  malops: [],
  xemdiemthi: true,
  hienthibailam: false,
  xemdapan: false,
  troncauhoi: true,
  loaide: 1,
  machuongs: [],
  socaude: 10,
  socautb: 5,
  socaukho: 2
});
  // --- CẤU HÌNH BẢNG (TABLE) ---
  // Các cột khớp với JSON bạn cung cấp
  const columns = [
    { title: 'Tên đề', dataIndex: 'tende', key: 'tende', sorter: (a, b) => a.tende.localeCompare(b.tende) },
    { title: 'Giao cho', dataIndex: 'giaoCho', key: 'giaoCho', width: '25%' },
    { title: 'Bắt đầu', dataIndex: 'thoigianbatdau', key: 'thoigianbatdau' },
    { title: 'Kết thúc', dataIndex: 'thoigianketthuc', key: 'thoigianketthuc' },
    { title: 'Trạng thái', dataIndex: 'trangthai', key: 'trangthai', align: 'center' },
    { title: 'Hành động', key: 'actions', width: 120, align: 'center' },
  ];
  const rules = {
  tende: [{ required: true, message: 'Vui lòng nhập tên đề thi' }],
  thoigian: [{ required: true, message: 'Vui lòng chọn thời gian diễn ra', type: 'array' }],
  thoigianthi: [{ required: true, message: 'Vui lòng nhập thời gian làm bài' }],
  malops: [{ required: true, message: 'Vui lòng chọn ít nhất một lớp', type: 'array' }],
  machuongs: [{ required: true, message: 'Vui lòng chọn ít nhất một chương', type: 'array' }],
};
  // Lọc danh sách
  const filteredDeThis = computed(() => {
    if (!searchText.value) return deThis.value;
    return deThis.value.filter(de => de.tende.toLowerCase().includes(searchText.value.toLowerCase()));
  });

  // Hàm đổi màu cho Tag
  const getStatusColor = (status) => {
    if (status === 'Đang diễn ra') return 'green';
    if (status === 'Sắp diễn ra') return 'blue';
    return 'default';
  };
  // --- CÁC HÀM XỬ LÝ SỰ KIỆN ---
const openAddModal = () => {
  currentDeThi.value = getInitialFormState(); // Reset form về trạng thái ban đầu
  showModal.value = true;
};

const handleCancel = () => {
  showModal.value = false;
};

const handleOk = async () => {
  try {
    await formRef.value.validate(); // Kiểm tra xem form có hợp lệ không
    isSaving.value = true;
    
    // Xây dựng payload khớp với DeThiCreateRequest ở backend
    const [start, end] = currentDeThi.value.thoigian;
    const payload = {
        tende: currentDeThi.value.tende,
        thoigianbatdau: start.toISOString(), // Gửi định dạng ISO 8601
        thoigianketthuc: end.toISOString(),
        thoigianthi: currentDeThi.value.thoigianthi,
        malops: currentDeThi.value.malops,
        xemdiemthi: currentDeThi.value.xemdiemthi,
        hienthibailam: currentDeThi.value.hienthibailam,
        xemdapan: currentDeThi.value.xemdapan,
        troncauhoi: currentDeThi.value.troncauhoi,
        loaide: currentDeThi.value.loaide,
        machuongs: currentDeThi.value.machuongs,
        socaude: currentDeThi.value.socaude || 0,
        socautb: currentDeThi.value.socautb || 0,
        socaukho: currentDeThi.value.socaukho || 0,
    };

    // Gọi API POST để tạo mới
    await apiClient.post('DeThi', payload);
    message.success('Thêm đề thi thành công!');
    showModal.value = false;
    await fetchDeThis(); // Tải lại danh sách mới nhất
  } catch (error) {
    console.error("Lỗi khi tạo đề thi:", error);
    if (error.response) {
      console.log('Lỗi từ server:', error.response.data);
      message.error("Đã có lỗi xảy ra từ server. Vui lòng kiểm tra lại thông tin.");
    } else {
      message.error("Lỗi khi gửi yêu cầu. Vui lòng kiểm tra kết nối mạng.");
    }
  } finally {
    isSaving.value = false;
  }
};

  // --- HÀM TIỆN ÍCH ---
  // Hàm này đặc biệt quan trọng để xử lý ngày "0001-01-01"
  const formatDisplayDate = (dateString) => {
    // Nếu ngày là giá trị mặc định (MinValue), hiển thị là "Chưa đặt"
    if (dateString.startsWith('0001-01-01')) {
      return 'Chưa đặt';
    }
    // Nếu là ngày hợp lệ, định dạng lại cho đẹp
    return dayjs(dateString).format('YYYY-MM-DD HH:mm');
  };


  // --- HÀM GỌI API ---
  const fetchDeThis = async () => {
    isLoading.value = true;
    try {
      const response = await apiClient.get("DeThi");
      // Gán thẳng dữ liệu từ API vào state, không cần xử lý thêm ở đây
      // vì chúng ta đã có hàm formatDisplayDate để xử lý lúc hiển thị
      deThis.value = response.data;
    } catch (error) {
      console.error("Lỗi khi tải danh sách đề thi:", error);
      message.error("Không thể tải dữ liệu từ server. Vui lòng kiểm tra lại API.");
    } finally {
      isLoading.value = false;
    }
  };
  const fetchLops = async () => {
  try {
    // Giả sử endpoint của bạn là 'Lop'
    const response = await apiClient.get('Lop'); 
    // Ánh xạ lại dữ liệu từ API cho phù hợp với a-select
    // API của bạn có thể trả về 'malop' và 'tenlop', chúng ta cần đổi thành 'value' và 'label'
    lops.value = response.data.map(lop => ({
      value: lop.malop, // Hoặc tên thuộc tính ID của lớp trong API
      label: lop.tenlop  // Hoặc tên thuộc tính tên lớp trong API
    }));
  } catch (error) {
    console.error("Lỗi khi tải danh sách lớp:", error);
    message.error("Không thể tải danh sách lớp.");
  }
};

const fetchChuongs = async () => {
  try {
    // Giả sử endpoint của bạn là 'Chuong'
    const response = await apiClient.get('Chuong');
    chuongs.value = response.data.map(chuong => ({
      value: chuong.machuong, // Hoặc tên thuộc tính ID của chương
      label: chuong.tenchuong // Hoặc tên thuộc tính tên chương
    }));
  } catch (error) {
    console.error("Lỗi khi tải danh sách chương:", error);
    message.error("Không thể tải danh sách chương.");
  }
};
  // --- LIFECYCLE HOOK ---
  // Gọi hàm fetchDeThis() ngay khi component được tạo
  onMounted(() => {
      Promise.all([
    fetchDeThis(),
    fetchLops(),
    fetchChuongs()
  ]);
  });
</script>
