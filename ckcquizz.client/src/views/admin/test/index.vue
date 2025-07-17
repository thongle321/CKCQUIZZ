<template>
  <a-card title="Quản lý Đề kiểm tra" style="width: 100%">
    <template #extra>
      <a-button type="primary" size="large" @click="openAddModal" v-if="userStore.canCreate('DeThi')">
        <template #icon>
          <Plus />
        </template>
        Thêm đề thi
      </a-button>
    </template>
    <a-row class="mb-3" :gutter="16">
      <a-col :span="12">
        <a-input v-model:value="tableState.searchText" placeholder="Tìm kiếm theo tên đề thi..." allow-clear>
          <template #prefix>
            <Search size="14" />
          </template>
        </a-input>
      </a-col>
      <a-col :span="6">
        <a-select v-model:value="filterState.subject" placeholder="Lọc theo môn học"
          :options="dropdownData.monHocOptions" allow-clear style="width: 100%"></a-select>
      </a-col>
      <a-col :span="6">
        <a-select v-model:value="filterState.status" placeholder="Lọc theo trạng thái" allow-clear style="width: 100%">
          <a-select-option value="upcoming">Sắp diễn ra</a-select-option>
          <a-select-option value="ongoing">Đang diễn ra</a-select-option>
          <a-select-option value="closed">Đã đóng</a-select-option>

        </a-select>
      </a-col>
    </a-row>

    <!-- 2. Bảng hiển thị -->
    <a-table :dataSource="filteredDeThis" :columns="columns" :loading="tableState.isLoading" rowKey="made">
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'status'">
          <a-tag :color="record.statusObject.color">
            {{ record.statusObject.text }}
          </a-tag>
        </template>
        <template v-if="column.key === 'trangthai'">
          <a-tag :color="record.trangthai ? 'green' : 'red'">
            {{ record.trangthai ? 'Hiện' : 'Ẩn' }}
          </a-tag>
        </template>
        <template v-if="column.key === 'actions'">
          <a-dropdown>
            <a-button type="text">
              <ChevronDown />
            </a-button>
            <template #overlay>
              <a-menu>
                <!-- 1. Soạn câu hỏi -->
                <a-menu-item key="compose" @click="openQuestionComposer(record)"
                  v-if="userStore.canCreate('DeThi') && ['Sắp diễn ra', 'Chưa có lịch'].includes(record.statusObject.text)">
                  <FilePlus2 :size="16" style="margin-right: 8px;" />
                  Soạn câu hỏi
                </a-menu-item>

                <!-- 2. Sửa thông tin -->
                <a-menu-item key="edit" @click="openEditModal(record)"
                  v-if="userStore.canUpdate('DeThi') && ['Sắp diễn ra', 'Chưa có lịch', 'Đang diễn ra'].includes(record.statusObject.text)">
                  <SquarePen :size="16" style="margin-right: 8px;" />
                  Sửa thông tin
                </a-menu-item>

                <!-- 3. Xem kết quả -->
                <a-menu-item key="results" @click="openResultsPage(record)"
                  v-if="['Đang diễn ra', 'Đã đóng'].includes(record.statusObject.text)">
                  <BarChart3 :size="16" style="margin-right: 8px;" />
                  Xem kết quả
                </a-menu-item>

                <!-- 4. Nút Xóa (Quan trọng nhất) -->
                <a-divider style="margin: 4px 0;" v-if="userStore.canDelete('DeThi')" />
                <a-menu-item key="toggle-visibility" v-if="userStore.canDelete('DeThi')">

                  <!-- NÚT ẨN: Chỉ hiển thị khi đề thi đang hiện (record.trangthai === true) -->
                  <a-popconfirm v-if="record.trangthai" title="Bạn có chắc chắn muốn ẩn đề thi này?" ok-text="Ẩn"
                    cancel-text="Huỷ" @confirm="handleDelete(record.made)">
                    <div style="color: red; display: flex; align-items: center;">
                      <Trash2 :size="16" style="margin-right: 8px;" />
                      Ẩn đề thi
                    </div>
                  </a-popconfirm>

                  <!-- NÚT HIỆN: Chỉ hiển thị khi đề thi đang ẩn (record.trangthai === false) -->
                  <div v-else style="color: #52c41a; display: flex; align-items: center;"
                    @click="handleShow(record.made)">
                    <Eye :size="16" style="margin-right: 8px;" />
                    Hiện lại đề thi
                  </div>
                </a-menu-item>
                <a-menu-item key="permanent-delete"
                  v-if="userStore.canDelete('DeThi') && record.trangthai === false && ['Đã đóng'].includes(record.statusObject.text)">
                  <a-popconfirm title="XÓA ĐỀ THI?" ok-text="Xóa" cancel-text="Hủy" ok-type="danger"
                    @confirm="handlePermanentDelete(record.made)">
                    <template #description>
                      <p>Hành động này không thể hoàn tác.</p>
                      <p>Bạn có chắc chắn muốn xóa đề thi <strong>{{ record.tende }}</strong>?</p>
                    </template>
                    <div style="color: #ff4d4f; display: flex; align-items: center;">
                      <Trash2 :size="16" style="margin-right: 8px;" />
                      Xóa
                    </div>
                  </a-popconfirm>
                </a-menu-item>
              </a-menu>
            </template>
          </a-dropdown>
        </template>
      </template>
      <template #emptyText>
        <a-empty description="Không tìm thấy đề thi nào." />
      </template>
    </a-table>

    <!-- 3. Modal Thêm/Sửa -->
    <a-modal :title="modalState.isEditMode ? 'Sửa Đề thi' : 'Tạo Đề thi mới'" :open="modalState.show" ok-text="Lưu" @ok="handleSubmit"
      cancel-text="Hủy" @cancel="handleCancel" :confirmLoading="modalState.isSaving" width="900px" destroyOnClose>
      <a-form ref="formRef" :model="formState" layout="vertical" :rules="rules">
        <a-row :gutter="24">
          <!-- Cột trái -->
          <a-col :span="12">
            <a-form-item label="Tên đề thi" name="tende">
              <a-input v-model:value="formState.tende" placeholder="VD: Kiểm tra cuối kỳ" />
            </a-form-item>
            <a-form-item label="Thời gian diễn ra" name="thoigian">
              <a-range-picker v-model:value="formState.thoigian" show-time format="YYYY-MM-DD HH:mm"
                style="width: 100%;" :disabled-date="disabledDate" />
            </a-form-item>
            <a-form-item label="Thời gian làm bài (phút)" name="thoigianthi">
              <a-input-number v-model:value="formState.thoigianthi" :min="1" placeholder="VD: 60"
                style="width: 100%;" />
            </a-form-item>
            <div v-if="!modalState.isEditMode">

              <a-form-item label="Chọn Môn học" name="mamonhoc">
                <a-select v-model:value="formState.mamonhoc" placeholder="Chọn môn học để xem các lớp"
                  :options="dropdownData.monHocOptions" :loading="dropdownData.isLoading" @change="handleMonHocChange"
                  allow-clear :disabled="modalState.isEditMode" />
              </a-form-item>
              <a-form-item label="Giao cho lớp" name="malops">
                <a-select v-model:value="formState.malops" mode="multiple" placeholder="Vui lòng chọn môn học trước"
                  :options="dropdownData.lopOptions" :disabled="modalState.isEditMode || !formState.mamonhoc"
                  optionFilterProp="label" />
              </a-form-item>
            </div>
          </a-col>

          <!-- Cột phải -->
          <a-col :span="12" v-if="!modalState.isEditMode">
            <div :class="{ 'disabled-section': modalState.isEditMode }">
              <a-form-item label="Loại đề" name="loaide">
                <a-checkbox v-model:checked="isUsingQuestionBank">
                  Lấy từ ngân hàng câu hỏi
                </a-checkbox>
              </a-form-item>
              <div v-if="isUsingQuestionBank">
                <a-form-item label="Chọn chương" name="machuongs">
                  <a-select v-model:value="formState.machuongs" mode="multiple" placeholder="Chọn các chương"
                    :options="dropdownData.chuongOptions" :loading="dropdownData.isLoading" />
                </a-form-item>

                <a-form-item label="Tổng số câu hỏi" name="tongsocau">
                  <a-row :gutter="16">
                    <a-col :span="8">
                      <a-form-item name="socaude" label="Số câu dễ" style="margin-bottom: 0;">
                        <a-input-number v-model:value="formState.socaude" :min="0" style="width: 100%" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item name="socautb" label="Số câu TB" style="margin-bottom: 0;">
                        <a-input-number v-model:value="formState.socautb" :min="0" style="width: 100%" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="8">
                      <a-form-item name="socaukho" label="Số câu khó" style="margin-bottom: 0;">
                        <a-input-number v-model:value="formState.socaukho" :min="0" style="width: 100%" />
                      </a-form-item>
                    </a-col>
                  </a-row>
                </a-form-item>
              </div>
            </div>
          </a-col>
        </a-row>

        <a-divider>Tùy chọn hiển thị</a-divider>
        <a-row :gutter="16">
          <a-col :span="6" v-if="!modalState.isEditMode || ['Sắp diễn ra'].includes(formState.statusObject?.text)">
            <a-form-item>
              <a-switch v-model:checked="formState.troncauhoi" /> Trộn câu
              hỏi
            </a-form-item>
          </a-col>
          <a-col :span="6">
            <a-form-item>
              <a-switch v-model:checked="formState.xemdiemthi" /> Xem điểm
              thi
            </a-form-item>
          </a-col>
          <a-col :span="6">
            <a-form-item>
              <a-switch v-model:checked="formState.hienthibailam" /> Xem lại bài
              làm
            </a-form-item>
          </a-col>
          <a-col :span="6">
            <a-form-item>
              <a-switch v-model:checked="formState.xemdapan" /> Xem đáp
              án
            </a-form-item>
          </a-col>
        </a-row>
      </a-form>
    </a-modal>
  </a-card>
</template>

<script setup>
  import { ref, computed, onMounted, reactive, watch, onUnmounted } from 'vue';
import { message, Tag as ATag, Dropdown, Menu, MenuItem } from 'ant-design-vue';
import { Search, Plus, SquarePen, Trash2, FilePlus2, Eye, BarChart3, Cog, ChevronDown } from 'lucide-vue-next';
import dayjs from 'dayjs';
import utc from 'dayjs/plugin/utc';
import timezone from 'dayjs/plugin/timezone';
import apiClient from "@/services/axiosServer";
import { useUserStore } from '@/stores/userStore';
import { useRouter } from 'vue-router';


dayjs.extend(utc);
  dayjs.extend(timezone);

  const currentTime = ref(dayjs().tz('Asia/Ho_Chi_Minh'));
  let intervalId = null;  
const userStore = useUserStore()
const router = useRouter();
const columns = [
  { title: 'Tên đề', dataIndex: 'tende', key: 'tende', sorter: (a, b) => a.tende.localeCompare(b.tende) },
  { title: 'Môn học', dataIndex: 'tenmonhoc', key: 'tenmonhoc', width: '25%' },
  { title: 'Lớp học phần', dataIndex: 'giaoCho', key: 'giaoCho', width: '25%' },
  { title: 'Bắt đầu', dataIndex: 'formattedThoiGianBatDau', key: 'thoigianbatdau' },
  { title: 'Kết thúc', dataIndex: 'formattedThoiGianKetThuc', key: 'thoigianketthuc' },
  { title: 'Trạng thái thi', key: 'status', width: 130, align: 'center' },
  { title: 'Hiển thị', dataIndex: 'trangthai', key: 'trangthai', width: 120, align: 'center' },
  { title: 'Hành động', key: 'actions', width: 150, align: 'center' },
];

const getInitialFormState = () => ({
  made: null,
  tende: '',
  thoigian: [],
  thoigianthi: 60,
  mamonhoc: null,
  malops: [],
  xemdiemthi: true,
  hienthibailam: false,
  xemdapan: false,
  troncauhoi: true,
  loaide: 2,
  machuongs: [],
  socaude: 0,
  socautb: 0,
  socaukho: 0,
});

const tableState = reactive({
  deThis: [],
  isLoading: true,
  searchText: '',
});

const modalState = reactive({
  show: false,
  isSaving: false,
  isEditMode: false,
});
const filterState = reactive({
  subject: null,
  status: null,
});
const formRef = ref(null);
const formState = reactive(getInitialFormState());

const dropdownData = reactive({
  isLoading: true,
  allLops: [],
  allMonHocs: [],
  allChuongs: [],
  monHocOptions: [],
  lopOptions: [],
  chuongOptions: [],
});
const monHocMap = computed(() => {
  return new Map(dropdownData.allMonHocs.map(mh => [mh.mamonhoc, mh.tenmonhoc]));
});
  const getDeThiStatus = (start, end, now) => {
  if (!start || start.startsWith('0001-01-01')) {
    return { text: 'Chưa có lịch', color: 'default' };
  }
  const startTime = dayjs.utc(start).tz('Asia/Ho_Chi_Minh');
  const endTime = dayjs.utc(end).tz('Asia/Ho_Chi_Minh');



  if (now.isBefore(startTime)) {
    return { text: 'Sắp diễn ra', color: 'blue' };
  }

  if (now.isAfter(endTime)) {
    return { text: 'Đã đóng', color: 'red' };
  }
  return { text: 'Đang diễn ra', color: 'green' };
};
const deThisWithNames = computed(() => {
  return tableState.deThis.map(deThi => ({
    ...deThi,
    tenmonhoc: monHocMap.value.get(deThi.monthi) || '...',
    formattedThoiGianBatDau: formatDateTime(deThi.thoigianbatdau),
    formattedThoiGianKetThuc: formatDateTime(deThi.thoigianketthuc),
    statusObject: getDeThiStatus(deThi.thoigianbatdau, deThi.thoigianketthuc, currentTime.value),
  }));
});
const filteredDeThis = computed(() => {
  let result = deThisWithNames.value;

  if (filterState.status) {
    result = result.filter(de => {
      const statusText = de.statusObject.text;
      if (filterState.status === 'upcoming' && statusText === 'Sắp diễn ra') return true;
      if (filterState.status === 'ongoing' && statusText === 'Đang diễn ra') return true;
      if (filterState.status === 'closed' && statusText === 'Đã đóng') return true;
      return false;
    });
  }

  if (filterState.subject) {
    result = result.filter(de => de.monthi === filterState.subject);
  }
  if (tableState.searchText) {
    const searchTextLower = tableState.searchText.toLowerCase().trim();
    if (searchTextLower) {
      result = result.filter(de =>
        de.tende.toLowerCase().includes(searchTextLower) ||
        (de.tenmonhoc && de.tenmonhoc.toLowerCase().includes(searchTextLower))
      );
    }
  }
  return result;
});

const isUsingQuestionBank = computed({
  get: () => formState.loaide === 1,
  set: (value) => { formState.loaide = value ? 1 : 2; }
});
const formatDateTime = (dateTimeString) => {

  if (!dateTimeString || dateTimeString.startsWith('0001-01-01')) {
    return 'Chưa cập nhật';
  }
  return dayjs.utc(dateTimeString).tz('Asia/Ho_Chi_Minh').format('HH:mm - DD/MM/YYYY');
};
const validateTongSoCau = (rule, value) => {
  if (modalState.isEditMode || formState.loaide !== 1) return Promise.resolve();
  const { socaude, socautb, socaukho } = formState;
  if ((socaude || 0) + (socautb || 0) + (socaukho || 0) <= 0) {
    return Promise.reject('Tổng số câu hỏi phải lớn hơn 0');
  }
  return Promise.resolve();
};
const disabledDate = current => {
  return current && current < dayjs().startOf('day');
};
const validateThoiGian = async (rule, value) => {
  if (!value || value.length < 2) {
    return Promise.resolve();
  }

  const [start, end] = value;
  const now = dayjs();
  if (!modalState.isEditMode && start.isBefore(now)) {
    return Promise.reject('Lỗi thời gian bắt đầu');
  }

  if (end.isSame(start) || end.isBefore(start)) {
    return Promise.reject('Thời gian kết thúc phải sau thời gian bắt đầu.');
  }

  return Promise.resolve();
};
const validateThoiGianLamBai = async (_rule, value) => {
  if (!value || value <= 0) return Promise.resolve();
  if (!formState.thoigian || formState.thoigian.length < 2) return Promise.resolve();

  const [start, end] = formState.thoigian;
  const diffInSeconds = end.diff(start, 'second');
  const availableMinutes = Math.floor(diffInSeconds / 60);

  if (value > availableMinutes) {
    return Promise.reject(`Thời gian làm bài không được vượt quá ${availableMinutes} phút.`);
  }

  return Promise.resolve();
};
const rules = reactive({
  tende: [{ required: true, message: 'Vui lòng nhập tên đề thi', trigger: 'blur' }],
  thoigian: [
    { required: true, message: 'Vui lòng chọn thời gian diễn ra', type: 'array', trigger: 'change' },
    { validator: validateThoiGian, trigger: ['change', 'blur'] }
  ],
  thoigianthi: [{ required: true, message: 'Vui lòng nhập thời gian làm bài', type: 'number', trigger: 'blur' },
  { validator: validateThoiGianLamBai, trigger: ['change', 'blur'] }],
  mamonhoc: [{ required: computed(() => !modalState.isEditMode), message: 'Vui lòng chọn môn học', trigger: 'change' }],
  malops: [{ required: computed(() => !modalState.isEditMode), message: 'Vui lòng giao cho ít nhất một lớp', type: 'array', trigger: 'change' }],
  machuongs: [{
    required: computed(() => isUsingQuestionBank.value),
    message: 'Vui lòng chọn chương',
    type: 'array',
    trigger: 'change'
  }],
  tongsocau: [{ validator: validateTongSoCau, trigger: 'change' }],
});

const fetchAllDeThis = async () => {
  tableState.isLoading = true;
  try {
    if (!userStore.canView('DeThi')) {
      tableState.deThis = []
      return
    }
    const response = await apiClient.get("DeThi");
    tableState.deThis = response.data;
  } catch (error) {
    message.error("Không thể tải danh sách đề thi.");
  } finally {
    tableState.isLoading = false;
  }
};

const fetchDataForDropdowns = async () => {
  dropdownData.isLoading = true;
  try {
    const [lopsRes, chuongsRes, monHocRes] = await Promise.all([
      apiClient.get('/Lop/subjects-with-groups'),
      apiClient.get('/Chuong'),
      apiClient.get('/PhanCong/my-assignments')
    ]);
    dropdownData.allLops = lopsRes.data;
    dropdownData.allChuongs = chuongsRes.data;
    dropdownData.allMonHocs = monHocRes.data;
    dropdownData.monHocOptions = monHocRes.data.map(mh => ({
      label: mh.tenmonhoc,
      value: mh.mamonhoc,
    }));
  } catch (error) {

  } finally {
    dropdownData.isLoading = false;
  }
};

const createDeThi = async (payload) => {
  await apiClient.post('DeThi', payload);
  message.success('Thêm đề thi thành công!');
};

const updateDeThi = async (id, payload) => {
  await apiClient.put(`DeThi/${id}`, payload);
  message.success('Cập nhật đề thi thành công!');
};

const openAddModal = () => {
  modalState.isEditMode = false;
  Object.assign(formState, getInitialFormState()); 
  dropdownData.lopOptions = [];
  dropdownData.chuongOptions = [];
  modalState.show = true;
};

  const openEditModal = (record) => {
  modalState.isEditMode = true;
  const deThiToEdit = {
    ...record,
    thoigian: [
      dayjs.utc(record.thoigianbatdau).local(),
      dayjs.utc(record.thoigianketthuc).local()
    ],
  };
  Object.assign(formState, deThiToEdit);
  modalState.show = true;
};

const openQuestionComposer = async (record) => {
  router.push({
    name: 'admin-test-compose',
    params: { id: record.made }
  });
};
const openResultsPage = (record) => {
  router.push({
    name: 'admin-test-results',
    params: { id: record.made }
  });
};
const handleDelete = async (deThiId) => {
  try {
    await apiClient.delete(`/DeThi/${deThiId}`);
    message.success('Ẩn đề thi thành công!');
    await fetchAllDeThis();
  } catch (error) {
    const errorMessage = error.response?.data?.message || "Đã xảy ra lỗi khi ẩn đề thi.";
    message.error(errorMessage);

  }
};
const handlePermanentDelete = async (deThiId) => {
  try {
    await apiClient.delete(`/DeThi/${deThiId}/HardDelete`);
    message.success('Đã xóa đề thi thành công!');
    await fetchAllDeThis();
  } catch (error) {
    const errorMessage = error.response?.data?.message || "Đã xảy ra lỗi khi xóa vĩnh viễn đề thi.";
    message.error(errorMessage);
  }
};
const handleShow = async (deThiId) => {
  try {
    await apiClient.put(`/DeThi/Restore/${deThiId}`);
    message.success('Hiện lại đề thi thành công!');
    await fetchAllDeThis();
  } catch (error) {
    const errorMessage = error.response?.data?.message || "Đã xảy ra lỗi khi hiện lại đề thi.";
    message.error(errorMessage);
  }
};
const handleCancel = () => {
  modalState.show = false;
};

const handleSubmit = async () => {
  try {
    await formRef.value.validate();
    modalState.isSaving = true;

    const [start, end] = formState.thoigian;
    const basePayload = {
      tende: formState.tende,
      thoigianbatdau: start.format(),
      thoigianketthuc: end.format(),
      thoigianthi: formState.thoigianthi,
      xemdiemthi: formState.xemdiemthi,
      hienthibailam: formState.hienthibailam,
      xemdapan: formState.xemdapan,
      troncauhoi: formState.troncauhoi,
    };

    if (modalState.isEditMode) {
      await updateDeThi(formState.made, basePayload);
    } else {
      const createPayload = {
        ...basePayload,
        thoigianthi: formState.thoigianthi,
        monthi: formState.mamonhoc,
        malops: formState.malops,
        xemdiemthi: formState.xemdiemthi,
        hienthibailam: formState.hienthibailam,
        xemdapan: formState.xemdapan,
        troncauhoi: formState.troncauhoi,
        loaide: formState.loaide,
        machuongs: formState.machuongs,
        socaude: formState.socaude || 0,
        socautb: formState.socautb || 0,
        socaukho: formState.socaukho || 0,
      };
      await createDeThi(createPayload);
    }

    modalState.show = false;
    await fetchAllDeThis();

  } catch (errorInfo) {
    if (errorInfo.name !== 'ValidateError') {
      const errorMessage = errorInfo.response?.data?.message || "Tạo đề thi thất bại.";
      message.error(errorMessage);
    }
  } finally {
    modalState.isSaving = false;
  }
};

const handleMonHocChange = (selectedMaMonHoc) => {
  formState.malops = [];
  formState.machuongs = [];
  if (selectedMaMonHoc) {
    dropdownData.lopOptions = dropdownData.allLops
      .filter(lop => lop.mamonhoc === selectedMaMonHoc)
      .flatMap(lop => lop.nhomLop.map(nhom => ({
        label: `${nhom.tennhom} (NH ${lop.namhoc} - HK${lop.hocky})`,
        value: nhom.manhom
      })));
    dropdownData.chuongOptions = dropdownData.allChuongs
      .filter(chuong => chuong.mamonhoc === selectedMaMonHoc)
      .map(chuong => ({
        value: chuong.machuong,
        label: chuong.tenchuong
      }));
  } else {
    dropdownData.lopOptions = [];
    dropdownData.chuongOptions = [];
  }
};

watch(() => formState.thoigian, (newValue) => {
  if (formRef.value && newValue && newValue.length === 2) {
    setTimeout(() => {
      formRef.value.validateFields(['thoigian']).catch(() => {
      });
    }, 100);
  }
}, { deep: true });

  onMounted(async () => {
    await userStore.fetchUserPermissions();
    fetchDataForDropdowns();
    fetchAllDeThis();
    intervalId = setInterval(() => {
      currentTime.value = dayjs().tz('Asia/Ho_Chi_Minh');
    }, 1000);
  });
  onUnmounted(() => {
    if (intervalId) {
      clearInterval(intervalId);
    }
  });
</script>

<style scoped>
.disabled-section {
  opacity: 0.5;
  pointer-events: none;
}
</style>
