<template>
  <div class="page-container">
    <a-card title="Tất cả câu hỏi">
      <template #extra>
        <a-button type="primary" size="large" @click="showAddModal">
          <template #icon>
            <PlusOutlined />
          </template>
          Thêm câu hỏi mới
        </a-button>
      </template>

      <!-- ========================================================== -->
      <!-- HEADER CỦA TRANG -->
      <!-- ========================================================== -->
      <!-- ========================================================== -->
      <!-- KHUNG LỌC VÀ TÌM KIẾM -->
      <!-- ========================================================== -->
      <a-card class="filter-card" :bordered="false">
        <a-row :gutter="[16, 16]">
          <a-col :span="6">
            <a-select v-model:value="filters.maMonHoc" placeholder="Chọn môn học" style="width: 100%" allow-clear
              @change="handleSubjectChange">
              <a-select-option v-for="subject in subjects" :key="subject.mamonhoc" :value="subject.mamonhoc">{{
                subject.tenmonhoc }}</a-select-option>
            </a-select>
          </a-col>
          <a-col :span="6">
            <a-select v-model:value="filters.maChuong" placeholder="Chọn chương" style="width: 100%"
              :disabled="!filters.maMonHoc" allow-clear @change="handleFilterChange">
              <a-select-option v-for="chapter in chapters" :key="chapter.machuong" :value="chapter.machuong">{{
                chapter.tenchuong }}</a-select-option>
            </a-select>
          </a-col>
          <a-col :span="6">
            <a-select v-model:value="filters.doKho" placeholder="Độ khó" style="width: 100%" allow-clear
              @change="handleFilterChange">
              <a-select-option :value="null">Tất cả</a-select-option>
              <a-select-option :value="1">Cơ bản</a-select-option>
              <a-select-option :value="2">Trung bình</a-select-option>
              <a-select-option :value="3">Nâng cao</a-select-option>
            </a-select>
          </a-col>
        </a-row>
        <a-row style="margin-top: 16px">
          <a-col :span="24">
            <a-input-search v-model:value="filters.keyword" placeholder="Nội dung câu hỏi"
              @search="handleFilterChange" />
          </a-col>
        </a-row>
      </a-card>

      <!-- ========================================================== -->
      <!-- BẢNG HIỂN THỊ DỮ LIỆU -->
      <!-- ========================================================== -->
      <a-table :columns="columns" :data-source="dataSource" :pagination="pagination" :loading="Modalloading"
        @change="handleTableChange" row-key="macauhoi">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'loaicauhoi'">
            <a-tag :color="getQuestionTypeTagColor(record.loaicauhoi)">
              {{ formatQuestionType(record.loaicauhoi) }}
            </a-tag>
          </template>
          <template v-if="column.key === 'trangthai'">
            <span :style="{ color: record.trangthai ? 'green' : 'red' }">
              {{ record.trangthai ? 'Hiển thị' : 'Ẩn' }}
            </span>
          </template>
          <template v-if="column.key === 'action'">
            <a-tooltip title="Sửa câu hỏi">
              <a-button type="text" @click="openEditModal(record)">
                <template #icon>
                  <SquarePen />
                </template>
              </a-button>
            </a-tooltip>
            <a-tooltip title="Xoá câu hỏi">
              <a-button type="text" danger @click="handleDelete(record)">
                <template #icon>
                  <Trash2 />
                </template>
              </a-button>
            </a-tooltip>
          </template>
        </template>
      </a-table>
    </a-card>

    <!-- ========================================================== -->
    <!-- MODAL THÊM CÂU HỎI MỚI -->
    <!-- ========================================================== -->
    <a-modal v-model:open="isAddModalVisible" title="Thêm câu hỏi mới" width="800px" :confirm-loading="addModalLoading"
      ok-text="Thêm" cancel-text="Hủy" @ok="handleAddOk" @cancel="handleAddCancel" :destroyOnClose="true">
      <a-form ref="addFormRef" :model="addFormState" :rules="formRules" layout="vertical">
        <a-row :gutter="16">
          <a-col :span="12"><a-form-item label="Môn học" name="maMonHoc"><a-select v-model:value="addFormState.maMonHoc"
                placeholder="Chọn môn học"><a-select-option v-for="subject in subjects" :key="subject.mamonhoc"
                  :value="subject.mamonhoc">{{ subject.tenmonhoc }}</a-select-option></a-select></a-form-item></a-col>
          <a-col :span="12"><a-form-item label="Chương" name="maChuong"><a-select v-model:value="addFormState.maChuong"
                placeholder="Chọn chương" :disabled="!addFormState.maMonHoc"
                :loading="modalChaptersLoading"><a-select-option v-for="chapter in modalChapters"
                  :key="chapter.machuong" :value="chapter.machuong">{{ chapter.tenchuong
                  }}</a-select-option></a-select></a-form-item></a-col>
        </a-row>
        <a-row :gutter="16">
          <a-col :span="12"><a-form-item label="Loại câu hỏi" name="loaiCauHoi"><a-select
                v-model:value="addFormState.loaiCauHoi"><a-select-option value="multiple_choice">Nhiều đáp
                  án</a-select-option><a-select-option value="single_choice">Một đáp
                  án</a-select-option><a-select-option value="essay">Tự
                  luận</a-select-option></a-select></a-form-item></a-col>
          <a-col :span="12"><a-form-item label="Độ khó" name="doKho"><a-select
                v-model:value="addFormState.doKho"><a-select-option :value="1">Cơ bản</a-select-option><a-select-option
                  :value="2">Trung bình</a-select-option><a-select-option :value="3">Nâng
                  cao</a-select-option></a-select></a-form-item></a-col>
        </a-row>
        <a-form-item label="Nội dung câu hỏi" name="noidung"><a-textarea v-model:value="addFormState.noidung" :rows="4"
            placeholder="Nhập nội dung (có thể bỏ trống nếu là câu hỏi hình ảnh)" /></a-form-item>
        <a-form-item name="hasImage">
          <a-checkbox v-model:checked="addFormState.hasImage">
            Đính kèm hình ảnh cho câu hỏi
          </a-checkbox>
        </a-form-item>
        <dynamic-form-elements :formState="addFormState" :form-ref="addFormRef"
          @update:file-list="addFormState.fileList = $event" />

        <a-row style="margin-top: 16px;"><a-col :span="24"><a-form-item label="Trạng thái" name="trangthai"><a-switch
                v-model:checked="addFormState.trangthai" checked-children="Hiển thị"
                un-checked-children="Ẩn" /></a-form-item></a-col></a-row>
      </a-form>
    </a-modal>

    <!-- ========================================================== -->
    <!-- MODAL SỬA CÂU HỎI -->
    <!-- ========================================================== -->
    <a-modal v-model:open="isEditModalVisible" title="Chỉnh sửa câu hỏi" width="800px"
      :confirm-loading="editModalLoading" ok-text="Lưu" cancel-text="Hủy" @ok="handleEditOk" @cancel="handleEditCancel"
      :destroyOnClose="true">
      <a-spin :spinning="editModalLoading">
        <a-form v-if="!editModalLoading" ref="editFormRef" :model="editFormState" :rules="formRules" layout="vertical">
          <a-row :gutter="16">
            <a-col :span="12"><a-form-item label="Môn học" name="maMonHoc"><a-select
                  v-model:value="editFormState.maMonHoc" placeholder="Chọn môn học"><a-select-option
                    v-for="subject in subjects" :key="subject.mamonhoc" :value="subject.mamonhoc">{{ subject.tenmonhoc
                    }}</a-select-option></a-select></a-form-item></a-col>
            <a-col :span="12"><a-form-item label="Chương" name="maChuong"><a-select
                  v-model:value="editFormState.maChuong" placeholder="Chọn chương" :disabled="!editFormState.maMonHoc"
                  :loading="editModalChaptersLoading"><a-select-option v-for="chapter in editModalChapters"
                    :key="chapter.machuong" :value="chapter.machuong">{{ chapter.tenchuong
                    }}</a-select-option></a-select></a-form-item></a-col>
          </a-row>
          <a-row :gutter="16">
            <a-col :span="12"><a-form-item label="Loại câu hỏi" name="loaiCauHoi"><a-select
                  v-model:value="editFormState.loaiCauHoi"><a-select-option value="multiple_choice">Nhiều đáp
                    án</a-select-option><a-select-option value="single_choice">Một đáp
                    án</a-select-option><a-select-option value="essay">Tự
                    luận</a-select-option></a-select></a-form-item></a-col>
            <a-col :span="12"><a-form-item label="Độ khó" name="doKho"><a-select v-model:value="editFormState.doKho"
                  placeholder="Chọn độ khó"><a-select-option :value="1">Cơ bản</a-select-option><a-select-option
                    :value="2">Trung bình</a-select-option><a-select-option :value="3">Nâng
                    cao</a-select-option></a-select></a-form-item></a-col>
          </a-row>
          <a-form-item label="Nội dung câu hỏi" name="noidung"><a-textarea v-model:value="editFormState.noidung"
              :rows="4" placeholder="Nhập nội dung (có thể bỏ trống nếu là câu hỏi hình ảnh)" /></a-form-item>

          <dynamic-form-elements :formState="editFormState" :form-ref="editFormRef"
            @update:file-list="editFormState.fileList = $event" />

          <a-row style="margin-top: 16px;"><a-col :span="24"><a-form-item label="Trạng thái" name="trangthai"><a-switch
                  v-model:checked="editFormState.trangthai" checked-children="Hiển thị"
                  un-checked-children="Ẩn" /></a-form-item></a-col></a-row>
        </a-form>
      </a-spin>
    </a-modal>
  </div>
</template>

<script setup>
// ==========================================================
// IMPORTS & COMPONENT DEFINITIONS
// ==========================================================
import { ref, h, reactive, onMounted, watch, defineAsyncComponent } from 'vue';
import { SquarePen, Trash2 } from 'lucide-vue-next';
import debounce from 'lodash/debounce';
import { PlusOutlined, DeleteOutlined } from '@ant-design/icons-vue';
import { message, Modal } from 'ant-design-vue';
import apiClient from '@/services/axiosServer';

// Tách phần giao diện động ra một component riêng để tái sử dụng
const DynamicFormElements = defineAsyncComponent(() => import('./DynamicFormElements.vue'));

// ==========================================================
// CẤU HÌNH BẢNG & CÁC STATE CHÍNH
// ==========================================================
const columns = [
  { title: 'ID', dataIndex: 'macauhoi', key: 'macauhoi', width: 60 },
  { title: 'Nội dung câu hỏi', dataIndex: 'noidung', key: 'noidung' },
  { title: 'Loại', dataIndex: 'loaicauhoi', key: 'loaicauhoi', width: 130, align: 'center' },
  { title: 'Môn học', dataIndex: 'tenMonHoc', key: 'tenMonHoc', width: 180 },
  { title: 'Độ khó', dataIndex: 'tenDoKho', key: 'tenDoKho', width: 120 },
  { title: 'Trạng thái', dataIndex: 'trangthai', key: 'trangthai', width: 100, align: 'center' },
  { title: 'Hành động', key: 'action', width: 100, align: 'center' },
];

const dataSource = ref([]);
const Modalloading = ref(false);
const pagination = reactive({ current: 1, pageSize: 10, total: 0 });
const subjects = ref([]);
const chapters = ref([]);
const filters = reactive({ maMonHoc: null, maChuong: null, doKho: null, keyword: '' });

// ==========================================================
// STATE CHO MODAL & FORM (TÁI SỬ DỤNG)
// ==========================================================
const getInitialFormState = () => ({
  macauhoi: null,
  loaiCauHoi: 'multiple_choice',
  maMonHoc: null,
  maChuong: null,
  doKho: 1,
  noidung: '',
  hinhanhUrl: null, // Sử dụng tên thống nhất
  fileList: [],
  trangthai: true,
  dapAn: [{ noidung: '' }],
  correctAnswer: null,
  dapAnTuLuan: '',
});

// State cho Modal Thêm
const isAddModalVisible = ref(false);
const addModalLoading = ref(false);
const addFormRef = ref();
let addFormState = reactive(getInitialFormState());
const modalChapters = ref([]);
const modalChaptersLoading = ref(false);

// State cho Modal Sửa
const isEditModalVisible = ref(false);
const editModalLoading = ref(false);
const editFormRef = ref();
let editFormState = reactive(getInitialFormState());
const editModalChapters = ref([]);
const editModalChaptersLoading = ref(false);

// Rules validation chung
const formRules = {
  maMonHoc: [{ required: true, message: 'Vui lòng chọn môn học!' }],
  maChuong: [{ required: true, message: 'Vui lòng chọn chương!' }],
  loaiCauHoi: [{ required: true, message: 'Vui lòng chọn loại câu hỏi!' }],
  doKho: [{ required: true, message: 'Vui lòng chọn độ khó!' }],
};

// ==========================================================
// CÁC HÀM GỌI API
// ==========================================================
const fetchData = async () => {
  Modalloading.value = true;
  try {
    const params = { ...filters, pageNumber: pagination.current, pageSize: pagination.pageSize };
    const response = await apiClient.get('/CauHoi', { params });
    dataSource.value = response.data.items;
    pagination.total = response.data.totalCount;
  } catch (error) { message.error('Không thể tải dữ liệu câu hỏi.'); }
  finally { Modalloading.value = false; }
};

const fetchSubjects = async () => {
  try {
    const response = await apiClient.get('/MonHoc');
    subjects.value = response.data;
  } catch (error) { message.error('Không thể tải danh sách môn học.'); }
};

const fetchChaptersForFilter = async (subjectId) => {
  if (!subjectId) { chapters.value = []; return; }
  try {
    const response = await apiClient.get(`/Chuong?mamonhocId=${subjectId}`);
    chapters.value = response.data;
  } catch (error) { message.error('Không thể tải danh sách chương.'); }
};

const fetchChaptersForModal = async (subjectId, targetChaptersRef, loadingRef) => {
  if (!subjectId) { targetChaptersRef.value = []; return; }
  loadingRef.value = true;
  try {
    const response = await apiClient.get(`/Chuong?mamonhocId=${subjectId}`);
    targetChaptersRef.value = response.data;
  } catch (error) { message.error('Không thể tải danh sách chương cho modal.'); }
  finally { loadingRef.value = false; }
};

// ==========================================================
// CÁC HÀM XỬ LÝ SỰ KIỆN (BẢNG, LỌC, XÓA)
// ==========================================================
const handleTableChange = (p) => {
  pagination.current = p.current;
  pagination.pageSize = p.pageSize;
  fetchData();
};

const handleFilterChange = () => {
  pagination.current = 1;
  fetchData();
};

const handleSubjectChange = (subjectId) => {
  filters.maChuong = null;
  fetchChaptersForFilter(subjectId);
  handleFilterChange();
};

const handleDelete = (record) => {
  Modal.confirm({
    title: 'Xác nhận xóa',
    icon: h(DeleteOutlined),
    content: `Bạn có chắc muốn xóa (ẩn) câu hỏi ID ${record.macauhoi}?`,
    okText: 'Xóa', okType: 'danger', cancelText: 'Hủy',
    onOk: async () => {
      try {
        await apiClient.delete(`/CauHoi/${record.macauhoi}`);
        message.success('Xóa (ẩn) câu hỏi thành công.');
        fetchData();
      } catch (error) { message.error('Lỗi khi xóa câu hỏi.'); }
    },
  });
};

// ==========================================================
// CÁC HÀM XỬ LÝ MODAL THÊM MỚI
// ==========================================================
const showAddModal = () => {
  Object.assign(addFormState, getInitialFormState());
  modalChapters.value = [];
  isAddModalVisible.value = true;
};

const handleAddOk = async () => {
  try {
    await addFormRef.value.validate();
    addModalLoading.value = true;
    const payload = createPayload(addFormState);
    await apiClient.post('/CauHoi', payload);
    message.success('Thêm câu hỏi mới thành công!');
    isAddModalVisible.value = false;
    fetchData();
  } catch (error) {
    handleApiError(error, 'Thêm mới thất bại');
  } finally {
    addModalLoading.value = false;
  }
};

const handleAddCancel = () => { isAddModalVisible.value = false; };

// ==========================================================
// CÁC HÀM XỬ LÝ MODAL SỬA
// ==========================================================
const openEditModal = async (record) => {
  isEditModalVisible.value = true;
  editModalLoading.value = true;
  try {
    const response = await apiClient.get(`/CauHoi/${record.macauhoi}`);
    const data = response.data;

    Object.assign(editFormState, {
      macauhoi: data.macauhoi,
      noidung: data.noidung,
      trangthai: data.trangthai,
      doKho: data.dokho,
      maMonHoc: data.mamonhoc,
      maChuong: data.machuong,
      loaiCauHoi: data.loaicauhoi,
      hinhanhUrl: data.hinhanhurl,
      fileList: data.hinhanhurl ? [{ uid: '-1', name: 'image.png', status: 'done', url: data.hinhanhurl }] : [],
      dapAn: data.cauTraLois.length > 0 ? data.cauTraLois.map(ans => ({ macautl: ans.macautl, noidung: ans.noidungtl })) : getInitialFormState().dapAn,
      dapAnTuLuan: data.loaicauhoi === 'essay' && data.cauTraLois.length > 0 ? data.cauTraLois[0].noidungtl : '',
      correctAnswer: getCorrectAnswerFromApi(data.cauTraLois, data.loaicauhoi),
      hasImage: !!data.hinhanhurl,
    });
    console.log("DỮ LIỆU CHI TIẾT CÂU HỎI TỪ API:", data); 
    await fetchChaptersForModal(data.mamonhoc, editModalChapters, editModalChaptersLoading);
  } catch (error) {
    message.error('Không thể tải dữ liệu câu hỏi để sửa.');
    isEditModalVisible.value = false;
  } finally {
    editModalLoading.value = false;
  }
};

const handleEditOk = async () => {
  try {
    await editFormRef.value.validate();
    editModalLoading.value = true;
    const payload = createPayload(editFormState);
    await apiClient.put(`/CauHoi/${editFormState.macauhoi}`, payload);
    message.success('Cập nhật câu hỏi thành công!');
    isEditModalVisible.value = false;
    fetchData();
  } catch (error) {
    handleApiError(error, 'Cập nhật thất bại');
  } finally {
    editModalLoading.value = false;
  }
};

const handleEditCancel = () => { isEditModalVisible.value = false; };

// ==========================================================
// CÁC HÀM HELPER (TÁI SỬ DỤNG)
// ==========================================================
const createPayload = (formState) => {
  const basePayload = {
    loaiCauHoi: formState.loaiCauHoi,
    noidung: formState.noidung,
    dokho: formState.doKho,
    mamonhoc: formState.maMonHoc,
    machuong: formState.maChuong,
    trangthai: formState.trangthai,
    hinhanhurl: formState.hinhanhUrl,
  };

  let cauTraLois = [];
  switch (formState.loaiCauHoi) {
    case 'single_choice':
    case 'multiple_choice':
    case 'image':
      const correctIndices = Array.isArray(formState.correctAnswer)
        ? formState.correctAnswer
        : (formState.correctAnswer !== null ? [formState.correctAnswer] : []);

      // === PHẦN SỬA LỖI QUAN TRỌNG ===
      // Map qua mảng gốc để bảo toàn chỉ số, sau đó mới filter
      cauTraLois = formState.dapAn
        .map((answer, index) => {
          // Bỏ qua nếu nội dung đáp án trống
          if (!answer.noidung || !answer.noidung.trim()) {
            return null;
          }
          return {
            macautl: answer.macautl || 0,
            noidungtl: answer.noidung.trim(),
            dapan: correctIndices.includes(index),
          };
        })
        .filter(Boolean); // Lọc bỏ các giá trị null đã trả về ở trên
      break;

    case 'essay':
      if (formState.dapAnTuLuan?.trim()) {
        // Vẫn giữ logic cũ cho tự luận, đảm bảo nó cũng có macautl
        cauTraLois = [{
          macautl: formState.dapAn[0]?.macautl || 0,
          noidungtl: formState.dapAnTuLuan,
          dapan: true
        }];
      }
      break;
  }
  return { ...basePayload, cauTraLois };
};

const getCorrectAnswerFromApi = (cauTraLois, loaiCauHoi) => {
  const correctIndices = cauTraLois.map((ans, index) => (ans.dapan ? index : -1)).filter(index => index !== -1);
  if (loaiCauHoi === 'single_choice') {
    return correctIndices.length > 0 ? correctIndices[0] : null;
  }
  return correctIndices;
};

const handleApiError = (error, defaultMessage) => {
  if (error.response && error.response.data) {
    const data = error.response.data;
    let errorMsg = defaultMessage;
    // Xử lý lỗi validation từ ASP.NET Core
    if (data.errors) {
      errorMsg = Object.values(data.errors).flat().join('\n');
    } else if (data.message) {
      errorMsg = data.message;
    } else if (typeof data === 'string') {
      errorMsg = data;
    }
    message.error(errorMsg);
  } else if (!error.info) { // Bỏ qua lỗi validation của Ant Form
    message.error(`${defaultMessage}! Vui lòng kiểm tra lại.`);
  }
  console.error("API Error:", error);
};

const formatQuestionType = (type) => ({ 'single_choice': 'Một đáp án', 'multiple_choice': 'Nhiều đáp án', 'essay': 'Tự luận', 'image': 'Hình ảnh', }[type] || 'N/A');
const getQuestionTypeTagColor = (type) => ({ 'single_choice': 'blue', 'multiple_choice': 'cyan', 'essay': 'purple', 'image': 'orange', }[type] || 'default');

// ==========================================================
// WATCHERS (THEO DÕI SỰ THAY ĐỔI)
// ==========================================================
watch(() => addFormState.maMonHoc, (newVal) => {
  addFormState.maChuong = null;
  fetchChaptersForModal(newVal, modalChapters, modalChaptersLoading);
});

watch(() => editFormState.maMonHoc, (newVal) => {
  editFormState.maChuong = null;
  fetchChaptersForModal(newVal, editModalChapters, editModalChaptersLoading);
});

watch(() => filters.keyword, debounce(handleFilterChange, 500));
watch(() => addFormState.hasImage, (newValue) => {
  if (!newValue) {
    addFormState.fileList = [];
    addFormState.hinhanhUrl = '';
  }
});
// ==========================================================
// LIFECYCLE HOOKS
// ==========================================================
onMounted(() => {
  fetchData();
  fetchSubjects();
});
</script>

<style scoped>
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.filter-card {
  margin-bottom: 16px;
}
</style>
