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
    <!-- MODAL THÊM CÂU HỎI MỚI (PHẦN THÊM VÀO) -->
    <a-modal v-model:open="isAddModalVisible"
             title="Thêm câu hỏi mới"
             width="800px"
             :confirm-loading="addModalLoading"
             ok-text="Thêm"
             cancel-text="Hủy"
             @ok="handleAddOk"
             @cancel="handleAddCancel">
      <a-form ref="addFormRef" :model="addFormState" :rules="addFormRules" layout="vertical">
        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="Môn học" name="maMonHoc">
              <a-select v-model:value="addFormState.maMonHoc" placeholder="Chọn môn học" @change="handleModalSubjectChange">
                <a-select-option v-for="subject in subjects" :key="subject.mamonhoc" :value="subject.mamonhoc">
                  {{ subject.tenmonhoc }}
                </a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="Chương" name="maChuong">
              <a-select v-model:value="addFormState.maChuong" placeholder="Chọn chương" :disabled="!addFormState.maMonHoc" :loading="modalChaptersLoading">
                <a-select-option v-for="chapter in modalChapters" :key="chapter.machuong" :value="chapter.machuong">
                  {{ chapter.tenchuong }}
                </a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="Độ khó" name="doKho">
              <a-select v-model:value="addFormState.doKho" placeholder="Chọn độ khó">
                <a-select-option :value="1">Cơ bản</a-select-option>
                <a-select-option :value="2">Trung bình</a-select-option>
                <a-select-option :value="3">Nâng cao</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="Trạng thái" name="trangthai">
              <a-switch v-model:checked="addFormState.trangthai" checked-children="Hiển thị" un-checked-children="Ẩn" />
            </a-form-item>
          </a-col>
        </a-row>

        <a-form-item label="Nội dung câu hỏi" name="noidung">
          <a-textarea v-model:value="addFormState.noidung" :rows="4" placeholder="Nhập nội dung câu hỏi" />
        </a-form-item>

        <a-divider>Các đáp án</a-divider>
        <a-form-item label="Chọn các đáp án đúng" name="correctAnswerIndices">
          <!-- Sử dụng a-checkbox-group để chứa các đáp án -->
          <a-checkbox-group v-model:value="addFormState.correctAnswerIndices" style="width: 100%;">
            <div v-for="(answer, index) in addFormState.dapAn" :key="index" style="display: flex; align-items: center; margin-bottom: 8px;">
              <!-- Mỗi đáp án là một a-checkbox riêng lẻ -->
              <a-checkbox :value="index" style="margin-right: 8px;"></a-checkbox>
              <a-input v-model:value="answer.noidung" :placeholder="`Nội dung đáp án ${index + 1}`" @blur="validateAnswersField"  style="flex-grow: 1;" />
              <DeleteOutlined v-if="addFormState.dapAn.length > 2" @click="removeAnswer(index)" style="color: red; margin-left: 8px; cursor: pointer;" />
            </div>
          </a-checkbox-group>
        </a-form-item>

        <a-button type="dashed" @click="addAnswer" style="width: 100%">
          <PlusOutlined /> Thêm đáp án
        </a-button>

      </a-form>
    </a-modal>
    <!-- ========================================================== -->
    <!-- MODAL SỬA CÂU HỎI (PHẦN THÊM MỚI) -->
    <!-- ========================================================== -->
    <a-modal v-model:open="isEditModalVisible" title="Chỉnh sửa câu hỏi" width="800px" :confirm-loading="editModalLoading" ok-text="Lưu" cancel-text="Hủy" @ok="handleEditOk" @cancel="handleEditCancel">
      <a-spin :spinning="editModalLoading">
        <a-form ref="editFormRef" :model="editFormState" :rules="editFormRules" layout="vertical">
          <a-row :gutter="16">
            <a-col :span="12">
              <a-form-item label="Môn học" name="maMonHoc">
                <a-select v-model:value="editFormState.maMonHoc" placeholder="Chọn môn học" @change="fetchEditModalChapters(editFormState.maMonHoc)">
                  <a-select-option v-for="subject in subjects" :key="subject.mamonhoc" :value="subject.mamonhoc"> {{ subject.tenmonhoc }} </a-select-option>
                </a-select>
              </a-form-item>
            </a-col>
            <a-col :span="12">
              <a-form-item label="Chương" name="maChuong">
                <a-select v-model:value="editFormState.maChuong" placeholder="Chọn chương" :disabled="!editFormState.maMonHoc" :loading="editModalChaptersLoading">
                  <a-select-option v-for="chapter in editModalChapters" :key="chapter.machuong" :value="chapter.machuong"> {{ chapter.tenchuong }} </a-select-option>
                </a-select>
              </a-form-item>
            </a-col>
          </a-row>
          <a-row :gutter="16">
            <a-col :span="12">
              <a-form-item label="Độ khó" name="doKho">
                <a-select v-model:value="editFormState.doKho" placeholder="Chọn độ khó">
                  <a-select-option :value="1">Cơ bản</a-select-option>
                  <a-select-option :value="2">Trung bình</a-select-option>
                  <a-select-option :value="3">Nâng cao</a-select-option>
                </a-select>
              </a-form-item>
            </a-col>
            <a-col :span="12">
              <a-form-item label="Trạng thái" name="trangthai">
                <a-switch v-model:checked="editFormState.trangthai" checked-children="Hiển thị" un-checked-children="Ẩn" />
              </a-form-item>
            </a-col>
          </a-row>
          <a-form-item label="Nội dung câu hỏi" name="noidung">
            <a-textarea v-model:value="editFormState.noidung" :rows="4" placeholder="Nhập nội dung câu hỏi" />
          </a-form-item>
          <a-divider>Các đáp án</a-divider>
          <a-form-item label="Chọn các đáp án đúng" name="correctAnswerIndices">
            <a-checkbox-group v-model:value="editFormState.correctAnswerIndices" style="width: 100%;">
              <div v-for="(answer, index) in editFormState.dapAn" :key="index" style="display: flex; align-items: center; margin-bottom: 8px;">
                <a-checkbox :value="index" style="margin-right: 8px;"></a-checkbox>
                <a-input v-model:value="answer.noidung" :placeholder="`Nội dung đáp án ${index + 1}`" @blur="validateAnswersField"  style="flex-grow: 1;" />
                <DeleteOutlined v-if="editFormState.dapAn.length > 2" @click="removeAnswer(editFormState, index)" style="color: red; margin-left: 8px; cursor: pointer;" />
              </div>
            </a-checkbox-group>
          </a-form-item>
          <a-button type="dashed" @click="addAnswer(editFormState)" style="width: 100%"> <PlusOutlined /> Thêm đáp án </a-button>
        </a-form>
      </a-spin>
    </a-modal>
  </div>
</template>

<script setup>
  import { ref, h, reactive, onMounted, watch, nextTick } from 'vue';
  import { SquarePen, Trash2, Plus } from 'lucide-vue-next';
  import debounce from 'lodash/debounce';
  import { PlusOutlined, EditOutlined, DeleteOutlined } from '@ant-design/icons-vue';
  import { message,Modal } from 'ant-design-vue';
import apiClient from '@/services/axiosServer';

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
  //Modal thêm mới
  const isAddModalVisible = ref(false);
  const addModalLoading = ref(false);
  const addFormRef = ref(); // Tham chiếu đến form
  const modalChapters = ref([]); // Danh sách chương riêng cho modal
  const modalChaptersLoading = ref(false);

  // Hàm để lấy trạng thái khởi tạo của form
  const getInitialFormState = () => ({
    maMonHoc: null,
    maChuong: null,
    doKho: 1,
    noidung: '',
    trangthai: true,
    dapAn: [
      { noidung: '' },
      { noidung: '' },
      { noidung: '' },
      { noidung: '' },
    ],
    correctAnswerIndices: [], // Mặc định đáp án đầu tiên là đúng
  });
  // State cho form thêm mới
  let addFormState = reactive(getInitialFormState());
  const validateAnswers = (rule, value) => {
    // Lọc ra các đáp án thực sự có nội dung
    const validAnswers = addFormState.dapAn.filter(ans => ans.noidung && ans.noidung.trim() !== '');

    //if (validAnswers.length === 0) {
    //  return Promise.reject('Vui lòng nhập đáp án!');
    //}

    //// Bạn có thể yêu cầu tối thiểu 2 đáp án nếu muốn
    //if (validAnswers.length < 3) {
    //  return Promise.reject('Câu hỏi cần có ít nhất 3 đáp án.');
    //}
    //const answerContents = validAnswers.map(ans => ans.noidung.trim().toLowerCase());
    //const uniqueAnswerContents = new Set(answerContents);
    //if (uniqueAnswerContents.size < answerContents.length) {
    //  return Promise.reject('Nội dung các đáp án không được trùng nhau.');
    //}
    //// Nếu đáp án đã chọn không còn tồn tại (do bị xóa)
    //if (addFormState.correctAnswerIndex >= validAnswers.length) {
    //  addFormState.correctAnswerIndex = 0; // Reset về đáp án đầu tiên
    //}

    return Promise.resolve();
  };
  const createFormRules = (formState) => ({
    maMonHoc: [{ required: true, message: 'Vui lòng chọn môn học!' }],
    maChuong: [{ required: true, message: 'Vui lòng chọn chương!' }],
    doKho: [{ required: true, message: 'Vui lòng chọn độ khó!' }],
    noidung: [{ required: true, message: 'Vui lòng nhập nội dung câu hỏi!' }],
    correctAnswerIndices: [
      { type: 'array', required: true, min: 1, message: 'Vui lòng chọn ít nhất một đáp án đúng!' },
      { validator: (rule, value) => validateAnswers(formState, rule, value), }
    ],
  });
  // Rules validation cho form
  const addFormRules = {
    maMonHoc: [{ required: true, message: 'Vui lòng chọn môn học!' }],
    maChuong: [{ required: true, message: 'Vui lòng chọn chương!' }],
    doKho: [{ required: true, message: 'Vui lòng chọn độ khó!' }],
    noidung: [{ required: true, message: 'Vui lòng nhập nội dung câu hỏi!' },
      { max: 1000, message: 'Nội dung câu hỏi không được vượt quá 1000 ký tự.' }],
    correctAnswerIndices: [{ required: true, message: 'Vui lòng chọn đáp án đúng!' },
      { validator: validateAnswers, trigger: 'change' }],
  };

  // Hiển thị modal
  const showAddModal = () => {
    // Reset form về trạng thái ban đầu mỗi khi mở
    Object.assign(addFormState, getInitialFormState());
    modalChapters.value = [];
    addFormRef.value?.resetFields(); // Xóa trạng thái validate cũ
    isAddModalVisible.value = true;
  };
  // Xử lý khi nhấn nút OK trên modal
  // Trong file index.vue

  const handleAddOk = async () => {
    try {
      // 1. Validate form
      await addFormRef.value.validate();
      addModalLoading.value = true;

      // 2. Tạo payload với cấu trúc CHÍNH XÁC mà API yêu cầu
      const payload = {
        noidung: addFormState.noidung,
        dokho: addFormState.doKho,
        mamonhoc: addFormState.maMonHoc,
        machuong: addFormState.maChuong,
        daodapan: false, // Giả định mặc định là false, bạn có thể thay đổi nếu cần

        // Chuyển đổi mảng đáp án sang định dạng `cauTraLois`
        cauTraLois: addFormState.dapAn
          .filter(ans => ans.noidung && ans.noidung.trim() !== '') // Quan trọng: Lọc bỏ các đáp án trống
          .map((answer, index) => ({
            noidungtl: answer.noidung, // Đổi tên từ 'noidung' thành 'noidungtl'
            dapan: addFormState.correctAnswerIndices.includes(index), // Đổi tên từ 'ladapan' thành 'dapan'
          })),
      };

      // Dòng này rất hữu ích để debug, bạn có thể giữ lại hoặc xóa đi
      console.log('Final Payload to be sent:', JSON.stringify(payload, null, 2));

      // 3. Gọi API với payload đã đúng định dạng
      await apiClient.post('/CauHoi', payload);

      message.success('Thêm câu hỏi mới thành công!');
      isAddModalVisible.value = false;
      fetchData(); // Tải lại dữ liệu bảng
    } catch (error) {
      console.error('Lỗi khi thêm câu hỏi:', error);
      if (error.response) {
        // Log lỗi từ server để dễ dàng debug hơn
        console.error('Server Response Data:', error.response.data);
        const errorMsg = error.response.data.title || JSON.stringify(error.response.data.errors) || 'Có lỗi xảy ra từ server';
        message.error(`Thêm thất bại: ${errorMsg}`);
      } else {
        message.error('Thêm câu hỏi thất bại! Kiểm tra kết nối mạng.');
      }
    } finally {
      addModalLoading.value = false;
    }
  };

  // Xử lý khi nhấn nút Cancel
  const handleAddCancel = () => {
    isAddModalVisible.value = false;
  };

  // Thêm một lựa chọn đáp án
  //const addAnswer = () => {
  //  if (addFormState.dapAn.length < 6) { // Giới hạn số lượng đáp án
  //    addFormState.dapAn.push({ noidung: '' });
  //  } else {
  //    message.warning('Chỉ có thể thêm tối đa 6 đáp án.');
  //  }
  //};

  // Xóa một lựa chọn đáp án
  //const removeAnswer = (indexToRemove) => {
  //  // Xóa đáp án khỏi mảng dapAn
  //  addFormState.dapAn.splice(indexToRemove, 1);

  //  // Xóa index bị xóa khỏi mảng các đáp án đúng
  //  const anwserIndexInCorrect = addFormState.correctAnswerIndices.indexOf(indexToRemove);
  //  if (anwserIndexInCorrect > -1) {
  //    addFormState.correctAnswerIndices.splice(anwserIndexInCorrect, 1);
  //  }

  //  // Cập nhật lại các index còn lại trong mảng đáp án đúng
  //  addFormState.correctAnswerIndices = addFormState.correctAnswerIndices.map(i => {
  //    return i > indexToRemove ? i - 1 : i;
  //  });
  //};
  // BƯỚC 1: THÊM STATE CHO MODAL SỬA
  // ==========================================================
  const isEditModalVisible = ref(false);
  const editModalLoading = ref(false);
  const editFormRef = ref();
  const editModalChapters = ref([]);
  const editModalChaptersLoading = ref(false);
  // State để chứa dữ liệu của câu hỏi đang được sửa
  let editFormState = reactive({
    macauhoi: null,
    maMonHoc: null,
    maChuong: null,
    doKho: 1,
    noidung: '',
    trangthai: true,
    dapAn: [],
    correctAnswerIndices: [],
  });
  const editFormRules = createFormRules(editFormState);
  const validateAnswersField = () => {
    // Kiểm tra xem modal nào đang mở để gọi đúng form ref
    if (isAddModalVisible.value) {
      addFormRef.value?.validateFields('correctAnswerIndices');
    }
    if (isEditModalVisible.value) {
      editFormRef.value?.validateFields('correctAnswerIndices');
    }
  };
  // BƯỚC 2: HÀM MỞ MODAL SỬA
  // ==========================================================
  const openEditModal = async (record) => {
    isEditModalVisible.value = true;
    editModalLoading.value = true; // Bật loading che form

    try {
      // Gọi API để lấy dữ liệu chi tiết của câu hỏi
      const response = await apiClient.get(`/CauHoi/${record.macauhoi}`);
      console.log("DỮ LIỆU THỰC TẾ TỪ API GET:", response.data);
      const data = response.data; // Giả sử API trả về data có cấu trúc giống payload

      // Điền dữ liệu cơ bản
      editFormState.macauhoi = data.macauhoi;
      editFormState.noidung = data.noidung;
      editFormState.trangthai = data.trangthai;
      editFormState.doKho = data.dokho;
      editFormState.maMonHoc = data.mamonhoc;
      editFormState.maChuong = data.machuong;

      // Chuyển đổi mảng đáp án từ API sang định dạng của form
      editFormState.dapAn = data.cauTraLois.map(ans => ({ macautl: ans.macautl, noidung: ans.noidungtl }));
      editFormState.correctAnswerIndices = data.cauTraLois
        .map((ans, index) => (ans.dapan ? index : -1))
        .filter(index => index !== -1);
      // Tải danh sách chương tương ứng với môn học của câu hỏi
      await fetchEditModalChapters(data.mamonhoc,false);

      // Reset trạng thái validation (nếu có)
     /* nextTick(() => editFormRef.value?.resetFields());*/

    } catch (error) {
      console.error("Lỗi khi tải dữ liệu câu hỏi:", error);
      message.error('Không thể tải dữ liệu câu hỏi để sửa.');
      isEditModalVisible.value = false; // Đóng modal nếu lỗi
    } finally {
      editModalLoading.value = false; // Tắt loading
    }
  };

  // Hàm phụ trợ để tải chương cho modal sửa
  const fetchEditModalChapters = async (subjectId,shouldResetChapter = true) => {
    if (shouldResetChapter) {
      editFormState.maChuong = null;
    }
    if (!subjectId) {
      editModalChapters.value = [];
      return;
    }
    editModalChaptersLoading.value = true;
    try {
      const response = await apiClient.get(`/Chuong?mamonhocId=${subjectId}`);
      editModalChapters.value = response.data;
    } catch (error) {
      message.error('Không thể tải danh sách chương.');
    } finally {
      editModalChaptersLoading.value = false;
    }
  };
    // BƯỚC 3: HÀM LƯU THAY ĐỔI
    // ==========================================================
    const handleEditOk = async () => {
      try {
        await editFormRef.value.validate();
        editModalLoading.value = true;

        // Tạo payload, giống hệt payload của hàm thêm
        const payload = {
          noidung: editFormState.noidung,
          dokho: editFormState.doKho,
          mamonhoc: editFormState.maMonHoc,
          machuong: editFormState.maChuong,
          trangthai: editFormState.trangthai,
          daodapan: false,
          cauTraLois: editFormState.dapAn
            .filter(ans => ans.noidung && ans.noidung.trim() !== '')
            .map((answer, index) => ({
              macautl: answer.macautl || 0,
              noidungtl: answer.noidung,
              dapan: editFormState.correctAnswerIndices.includes(index),
            })),
        };
        console.log("Payload gửi đi khi SỬA:", JSON.stringify(payload, null, 2));
        // Gọi API PUT thay vì POST
        await apiClient.put(`/CauHoi/${editFormState.macauhoi}`, payload);

        message.success('Cập nhật câu hỏi thành công!');
        isEditModalVisible.value = false;
        fetchData(); // Tải lại bảng
      } catch (error) {
        console.error("Lỗi khi cập nhật câu hỏi:", error);
        console.error("VALIDATION FAILED - CHI TIẾT:", JSON.stringify(error, null, 2));
        console.error("VALIDATION FAILED - ĐỐI TƯỢNG:", error);
        message.error('Cập nhật thất bại!');
      } finally {
        editModalLoading.value = false;
      }
    };

    const handleEditCancel = () => {
      isEditModalVisible.value = false;
    };
    // BƯỚC 4: SỬA LẠI HÀM CHUNG
    // ==========================================================

    // Sửa lại hàm addAnswer để nhận vào formState
    const addAnswer = (formState) => {
      if (formState.dapAn.length < 6) {
        formState.dapAn.push({ noidung: '' });
      } else {
        message.warning('Chỉ có thể thêm tối đa 6 đáp án.');
      }
    };

    // Sửa lại hàm removeAnswer để nhận vào formState
    const removeAnswer = (formState, indexToRemove) => {
      formState.dapAn.splice(indexToRemove, 1);

      const answerIndexInCorrect = formState.correctAnswerIndices.indexOf(indexToRemove);
      if (answerIndexInCorrect > -1) {
        formState.correctAnswerIndices.splice(answerIndexInCorrect, 1);
      }

      formState.correctAnswerIndices = formState.correctAnswerIndices.map(i => {
        return i > indexToRemove ? i - 1 : i;
      });
    };
  // Lấy danh sách chương cho modal khi chọn môn học
  const fetchModalChapters = async (subjectId) => {
    if (!subjectId) {
      modalChapters.value = [];
      return;
    }
    modalChaptersLoading.value = true;
    try {
      const response = await apiClient.get(`/Chuong?mamonhocId=${subjectId}`);
      modalChapters.value = response.data;
    } catch (error) {
      message.error('Không thể tải danh sách chương cho modal');
    } finally {
      modalChaptersLoading.value = false;
    }
  };
  // Theo dõi sự thay đổi môn học trong modal để tải lại chương
  watch(() => addFormState.maMonHoc, (newVal) => {
    addFormState.maChuong = null; // Reset chương khi đổi môn
    fetchModalChapters(newVal);
  });

  const fetchData = async () => {
    Modalloading.value = true;
    try {
      // Gửi tất cả các giá trị trong object 'filters' làm tham số
      const params = {
        ...filters, 
        pageNumber: pagination.current,
        pageSize: pagination.pageSize,
      };
      const response = await apiClient.get('/CauHoi', { params });
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
      const response = await apiClient.get('/MonHoc');
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
      const response = await apiClient.get(`/Chuong?mamonhocId=${subjectId}`);
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

  const handleDelete = async (record) => {
    Modal.confirm({
      title: 'Xác nhận xóa câu hỏi',
      icon: h(DeleteOutlined),
      content: `Bạn có chắc chắn muốn xóa câu hỏi ${record.macauhoi}?`,
      okText: 'Có',
      okType: 'danger',
      cancelText: 'Không',
      onOk: async () => {
        try {
          await apiClient.delete(`/CauHoi/${record.macauhoi}`);
          message.success('Đã xóa câu hỏi thành công');
          await fetchData();
        } catch (error) {
          message.error('Lỗi khi xóa câu hỏi' + (error.response?.data || error.message));
          console.error(error);
        }
      },
    });
  };

  watch(() => filters.keyword, debounce(() => {
    handleFilterChange();
  }, 500));
  watch(() => editFormState.maMonHoc, (newVal, oldVal) => {
    // Chỉ chạy khi giá trị thực sự thay đổi và không phải lần đầu mở modal
    if (newVal !== oldVal && oldVal !== null) {
      // Gọi hàm tải chương và cho phép reset (mặc định)
      fetchEditModalChapters(newVal);
    }
  });
  onMounted(() => {
    fetchData();
    fetchSubjects();
  });


</script>

