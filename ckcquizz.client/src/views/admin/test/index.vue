<template>
  <a-card title="Quản lý Đề kiểm tra" style="width: 100%">
    <!-- 1. Thanh công cụ -->
    <a-row :gutter="16" style="margin-bottom: 24px;">
      <a-col :span="8">
        <a-input v-model:value="searchText" placeholder="Tìm kiếm theo tên đề thi..." allow-clear>
          <template #prefix>
            <Search size="14" />
          </template>
        </a-input>
      </a-col>
      <a-col :span="16" style="display: flex; justify-content: flex-end;">
        <a-button type="primary" size="large" @click="openAddModal">
          <template #icon>
            <Plus />
          </template>
          Thêm đề thi
        </a-button>
      </a-col>
    </a-row>

    <!-- 2. Bảng hiển thị -->
    <a-table :dataSource="filteredDeThis" :columns="columns" :loading="isLoading" rowKey="made">
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'trangthai'">
          <a-tag :color="getStatusColor(record.trangthai)">{{ record.trangthai }}</a-tag>
        </template>
        <template v-if="column.key === 'thoigianbatdau' || column.key === 'thoigianketthuc'">
          <span>{{ formatDisplayDate(record[column.dataIndex]) }}</span>
        </template>
        <template v-if="column.key === 'actions'">
          <a-space>
            <a-tooltip title="Sửa đề thi"><a-button type="text" :icon="h(SquarePen)" disabled /></a-tooltip>
            <a-tooltip title="Xoá đề thi"><a-button type="text" danger :icon="h(Trash2)" disabled /></a-tooltip>
          </a-space>
        </template>
      </template>
    </a-table>

    <!-- 3. Modal Thêm/Sửa -->
    <a-modal title="Tạo Đề thi mới" :open="showModal" @ok="handleOk" @cancel="handleCancel"
             :confirmLoading="isSaving" width="900px" destroyOnClose>
      <!-- SỬA LỖI: :model trỏ trực tiếp vào currentDeThi -->
      <a-form ref="formRef" :model="currentDeThi" layout="vertical" :rules="rules">
        <a-row :gutter="24">
          <!-- Cột trái -->
          <a-col :span="12">
            <a-form-item label="Tên đề thi" name="tende">
              <a-input v-model:value="currentDeThi.tende" placeholder="VD: Kiểm tra cuối kỳ" />
            </a-form-item>
            <a-form-item label="Thời gian diễn ra" name="thoigian">
              <a-range-picker v-model:value="currentDeThi.thoigian" show-time format="YYYY-MM-DD HH:mm" style="width: 100%;" />
            </a-form-item>
            <a-form-item label="Thời gian làm bài (phút)" name="thoigianthi">
              <a-input-number v-model:value="currentDeThi.thoigianthi" :min="1" placeholder="VD: 60" style="width: 100%;" />
            </a-form-item>
            <!-- SỬA LỖI: Gộp selectedMonHoc vào currentDeThi, v-model trỏ vào currentDeThi.mamonhoc -->
            <a-form-item label="Chọn Môn học" name="mamonhoc">
              <a-select v-model:value="currentDeThi.mamonhoc" placeholder="Chọn môn học để xem các lớp" :options="monHocOptions"
                        :loading="dataLoading" @change="handleMonHocChange" allow-clear />
            </a-form-item>
            <a-form-item label="Giao cho lớp" name="malops">
              <a-select v-model:value="currentDeThi.malops" mode="multiple" placeholder="Vui lòng chọn môn học trước"
                        :options="lopOptions" :disabled="!currentDeThi.mamonhoc" optionFilterProp="label" />
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
              <a-form-item label="Chọn chương" name="machuongs">
                <a-select v-model:value="currentDeThi.machuongs" mode="multiple" placeholder="Chọn các chương"
                          :options="chuongOptions" :loading="dataLoading" />
              </a-form-item>
              <!-- SỬA LỖI: Thêm name cho các a-form-item để validation -->
              <a-form-item label="Tổng số câu hỏi" name="tongsocau">
                <a-row :gutter="16">
                  <a-col :span="8">
                    <a-form-item name="socaude" label="Số câu dễ" style="margin-bottom: 0;">
                      <a-input-number v-model:value="currentDeThi.socaude" :min="0" style="width: 100%" />
                    </a-form-item>
                  </a-col>
                  <a-col :span="8">
                    <a-form-item name="socautb" label="Số câu TB" style="margin-bottom: 0;">
                      <a-input-number v-model:value="currentDeThi.socautb" :min="0" style="width: 100%" />
                    </a-form-item>
                  </a-col>
                  <a-col :span="8">
                    <a-form-item name="socaukho" label="Số câu khó" style="margin-bottom: 0;">
                      <a-input-number v-model:value="currentDeThi.socaukho" :min="0" style="width: 100%" />
                    </a-form-item>
                  </a-col>
                </a-row>
              </a-form-item>
            </div>
          </a-col>
        </a-row>

        <a-divider>Tùy chọn hiển thị</a-divider>
        <a-row :gutter="16">
          <a-col :span="6"><a-form-item><a-switch v-model:checked="currentDeThi.troncauhoi" /> Trộn câu hỏi</a-form-item></a-col>
          <a-col :span="6"><a-form-item><a-switch v-model:checked="currentDeThi.xemdiemthi" /> Xem điểm thi</a-form-item></a-col>
          <a-col :span="6"><a-form-item><a-switch v-model:checked="currentDeThi.hienthibailam" /> Xem lại bài làm</a-form-item></a-col>
          <a-col :span-6><a-form-item><a-switch v-model:checked="currentDeThi.xemdapan" /> Xem đáp án</a-form-item></a-col>
        </a-row>
      </a-form>
    </a-modal>
  </a-card>
</template>

<script setup>
  import { ref, computed, onMounted, h, reactive } from 'vue';
  import { message } from 'ant-design-vue';
  import { Search, Plus, SquarePen, Trash2 } from 'lucide-vue-next';
  import dayjs from 'dayjs';
  import apiClient from "@/services/axiosServer";

  //--- 1. STATE CHO BẢNG VÀ TÌM KIẾM ---
  const searchText = ref('');
  const isLoading = ref(true);
  const deThis = ref([]);

  //--- 2. STATE CHO MODAL VÀ FORM ---
  const showModal = ref(false);
  const isSaving = ref(false);
  const formRef = ref(null);

  const getInitialFormState = () => ({
    tende: '',
    thoigian: [],
    thoigianthi: 60,
    mamonhoc: null,
    malops: [],
    xemdiemthi: true,
    hienthibailam: false,
    xemdapan: false,
    troncauhoi: true,
    loaide: 1,
    machuongs: [],
    socaude: 10,
    socautb: 5,
    socaukho: 2,
  });
  const currentDeThi = ref(getInitialFormState());

  //--- 3. STATE CHO DỮ LIỆU DROPDOWN PHỤ THUỘC ---
  const dataLoading = ref(true);
  const allLops = ref([]);
  const allMonHocs = ref([]);
  const allChuongs = ref([]);
  const monHocOptions = ref([]);
  const lopOptions = ref([]);
  const chuongOptions = ref([]);

  //--- CẤU HÌNH VÀ COMPUTED ---
  const columns = [
    { title: 'Tên đề', dataIndex: 'tende', key: 'tende', sorter: (a, b) => a.tende.localeCompare(b.tende) },
    { title: 'Giao cho', dataIndex: 'giaoCho', key: 'giaoCho', width: '25%' },
    { title: 'Bắt đầu', dataIndex: 'thoigianbatdau', key: 'thoigianbatdau' },
    { title: 'Kết thúc', dataIndex: 'thoigianketthuc', key: 'thoigianketthuc' },
    { title: 'Trạng thái', dataIndex: 'trangthai', key: 'trangthai', align: 'center' },
    { title: 'Hành động', key: 'actions', width: 120, align: 'center' },
  ];

  const validateTongSoCau = (rule, value) => {
    const { socaude, socautb, socaukho } = currentDeThi.value;
    if ((socaude || 0) + (socautb || 0) + (socaukho || 0) <= 0) {
      return Promise.reject('Tổng số câu hỏi phải lớn hơn 0');
    }
    return Promise.resolve();
  };

  const rules = {
    tende: [{ required: true, message: 'Vui lòng nhập tên đề thi', trigger: 'blur' }],
    thoigian: [{ required: true, message: 'Vui lòng chọn thời gian diễn ra', type: 'array', trigger: 'change' }],
    thoigianthi: [{ required: true, message: 'Vui lòng nhập thời gian làm bài', type: 'number', trigger: 'blur' }],
    mamonhoc: [{ required: true, message: 'Vui lòng chọn môn học', trigger: 'change' }],
    malops: [{ required: true, message: 'Vui lòng giao cho ít nhất một lớp', type: 'array', trigger: 'change' }],
    machuongs: [{ required: true, message: 'Vui lòng chọn ít nhất một chương', type: 'array', trigger: 'change' }],
    tongsocau: [{ validator: validateTongSoCau, trigger: 'change' }],
  };

  const filteredDeThis = computed(() => {
    if (!searchText.value) return deThis.value;
    return deThis.value.filter(de => de.tende.toLowerCase().includes(searchText.value.toLowerCase()));
  });

  const getStatusColor = (status) => {
    if (status === 'Đang diễn ra') return 'green';
    if (status === 'Sắp diễn ra') return 'blue';
    return 'default';
  };

  const formatDisplayDate = (dateString) => {
    if (!dateString || dateString.startsWith('0001-01-01')) return 'Chưa đặt';
    return dayjs(dateString).format('YYYY-MM-DD HH:mm');
  };

  //--- CÁC HÀM GỌI API ---
  const fetchDeThis = async () => {
    isLoading.value = true;
    try {
      const response = await apiClient.get("DeThi");
      deThis.value = response.data;
    } catch (error) {
      message.error("Không thể tải danh sách đề thi.");
    } finally {
      isLoading.value = false;
    }
  };

  const fetchDataForForm = async () => {
    dataLoading.value = true;
    try {
      const [lopsResponse, chuongsResponse, monHocResponse] = await Promise.all([
        apiClient.get('/Lop/subjects-with-groups'),
        apiClient.get('/Chuong'),
        apiClient.get('/PhanCong/my-assignments')
      ]);

      allLops.value = lopsResponse.data;
      allChuongs.value = chuongsResponse.data;
      allMonHocs.value = monHocResponse.data;

      // Giả định rằng mỗi object trong monHocResponse.data có các trường:
      // id (PK), mamonhoc (mã code), tenmonhoc (tên hiển thị)
      monHocOptions.value = allMonHocs.value.map(mh => ({
        label: mh.tenmonhoc,
        value: mh.mamonhoc,
      }));

    } catch (error) {
      console.error("Lỗi khi tải dữ liệu cho form:", error);
      message.error("Không thể tải dữ liệu cho form tạo đề thi!");
    } finally {
      dataLoading.value = false;
    }
  };

  //--- CÁC HÀM XỬ LÝ SỰ KIỆN ---
  const openAddModal = () => {
    currentDeThi.value = getInitialFormState();
    lopOptions.value = [];
    chuongOptions.value = [];
    showModal.value = true;
  };

  const handleCancel = () => {
    showModal.value = false;
  };

  const handleMonHocChange = (selectedMaMonHoc) => {
    currentDeThi.value.malops = [];
    currentDeThi.value.machuongs = [];
    lopOptions.value = [];
    chuongOptions.value = [];

    if (selectedMaMonHoc) {
      // FIX: Lọc Lớp và Chương dựa trên mamonhoc (value của dropdown)
      lopOptions.value = allLops.value
        .filter(lop => lop.mamonhoc === selectedMaMonHoc)
        .flatMap(lop => lop.nhomLop.map(nhom => ({
          label: `${nhom.tennhom} (NH ${lop.namhoc} - HK${lop.hocky})`,
          value: nhom.manhom
        })));

      chuongOptions.value = allChuongs.value
        .filter(chuong => chuong.mamonhoc === selectedMaMonHoc)
        .map(chuong => ({
          value: chuong.machuong,
          label: chuong.tenchuong
        }));
    }
  };


  const handleOk = async () => {
    try {
      await formRef.value.validate();
      isSaving.value = true;

      const selectedMonHocObject = allMonHocs.value.find(
        mh => mh.mamonhoc === currentDeThi.value.mamonhoc
      );

      if (!selectedMonHocObject || !selectedMonHocObject.mamonhoc) {
        message.error("Không tìm thấy ID hợp lệ cho môn học đã chọn. Vui lòng thử lại.");
        isSaving.value = false;
        return;
      }

      const [start, end] = currentDeThi.value.thoigian;

      const payload = {
        tende: currentDeThi.value.tende,
        thoigianbatdau: start.toISOString(),
        thoigianketthuc: end.toISOString(),
        thoigianthi: currentDeThi.value.thoigianthi,
        monthi: selectedMonHocObject.mamonhoc, // FIX: Gửi `monthi` với giá trị là ID
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

      await apiClient.post('DeThi', payload);
      message.success('Thêm đề thi thành công!');
      showModal.value = false;
      await fetchDeThis();
    } catch (errorInfo) {
      if (errorInfo.name !== 'ValidateError') {
        console.error("Lỗi khi lưu đề thi:", errorInfo);
        const errorMessage = errorInfo.response?.data?.message || "Đã có lỗi xảy ra. Vui lòng kiểm tra lại thông tin.";
        message.error(errorMessage);
      }
    } finally {
      isSaving.value = false;
    }
  };

  //--- LIFECYCLE HOOK ---
  onMounted(() => {
    fetchDeThis();
    fetchDataForForm();
  });
</script>
