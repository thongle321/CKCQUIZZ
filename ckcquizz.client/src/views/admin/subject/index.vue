<template>
  <a-card title="Danh sách môn học" style="width: 100%">
    <div class="row">
      <div class="col-6 ">
        <a-input v-model:value="searchText" placeholder="Tìm kiếm môn học..." allow-clear enter-button block>
          <template #prefix>
            <Search size="14" />
          </template>
        </a-input>
      </div>
      <div class="col-6 d-flex justify-content-end">
        <a-button type="primary" @click="showAddModal = true" size="large">
          <template #icon>
            <Plus/>
          </template>
          Thêm môn học
        </a-button>
      </div>
    </div>

    <a-table :dataSource="subject" :columns="columns" :pagination="pagination" rowKey="mamonhoc"
      @change="handleTableChange">
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'actions'">
          <a-tooltip title="Danh sách chương">
            <a-button type="text" @click="openChapterListModal(record)" :icon="h(Info)" />

          </a-tooltip>
          <a-tooltip title="Sửa môn học">
            <a-button type="text" @click="openEditModal(record)" :icon="h(SquarePen)" />
          </a-tooltip>

          <a-tooltip title="Xoá môn học">
            <a-popconfirm title="Bạn có chắc muốn xóa môn học này?" ok-text="Có" cancel-text="Không"
              @confirm="handleDelete(record.mamonhoc)">
              <a-button type="text" danger :icon="h(Trash2)" />
            </a-popconfirm>
          </a-tooltip>
        </template>
      </template>
    </a-table>

    <a-modal title="Thêm môn học mới" v-model:open="showAddModal" @ok="handleAddOk" @cancel="handleAddCancel"
      :confirmLoading="modalLoading" destroyOnClose>
      <a-form ref="subjectForm" :model="newSubject" layout="vertical" :rules="rules">
        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="Mã môn học" required name="mamonhoc">
              <a-input v-model:value="newSubject.mamonhoc" placeholder="VD: 85001" />
            </a-form-item>
          </a-col>

          <a-col :span="12">
            <a-form-item label="Tên môn học" name="tenmonhoc">
              <a-input v-model:value="newSubject.tenmonhoc" placeholder="VD: Toán rời rạc" />
            </a-form-item>
          </a-col>

          <a-col :span="8">
            <a-form-item label="Số tín chỉ" name="sotinchi">
              <a-input-number v-model:value="newSubject.sotinchi" :min="1" :max="10" placeholder="VD: 3"
                style="width: 100%" />
            </a-form-item>
          </a-col>

          <a-col :span="8">
            <a-form-item label="Số tiết lý thuyết" name="sotietlythuyet">
              <a-input-number v-model:value="newSubject.sotietlythuyet" :min="1" :max="100" placeholder="VD: 30"
                style="width: 100%" />
            </a-form-item>
          </a-col>

          <a-col :span="8">
            <a-form-item label="Số tiết thực hành" name="sotietthuchanh">
              <a-input-number v-model:value="newSubject.sotietthuchanh" :min="1" :max="100" placeholder="VD: 15"
                style="width: 100%" />
            </a-form-item>
          </a-col>
        </a-row>
      </a-form>
    </a-modal>
    <a-modal title="Chỉnh sửa môn học" v-model:open="showEditModal" @ok="handleEditOk" @cancel="handleEditCancel"
      :confirmLoading="modalLoading" destroyOnClose>
      <a-form ref="editForm" :model="editSubject" layout="vertical" :rules="rules">
        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="Mã môn học" name="mamonhoc" required>
              <a-input v-model:value="editSubject.mamonhoc" disabled />
            </a-form-item>
          </a-col>

          <a-col :span="12">
            <a-form-item label="Tên môn học" name="tenmonhoc" required>
              <a-input v-model:value="editSubject.tenmonhoc" />
            </a-form-item>
          </a-col>

          <a-col :span="8">
            <a-form-item label="Số tín chỉ" name="sotinchi" required>
              <a-input-number v-model:value="editSubject.sotinchi" :min="1" :max="10" style="width: 100%" />
            </a-form-item>
          </a-col>

          <a-col :span="8">
            <a-form-item label="Số tiết lý thuyết" name="sotietlythuyet" required>
              <a-input-number v-model:value="editSubject.sotietlythuyet" :min="1" :max="100" style="width: 100%" />
            </a-form-item>
          </a-col>

          <a-col :span="8">
            <a-form-item label="Số tiết thực hành" name="sotietthuchanh" required>
              <a-input-number v-model:value="editSubject.sotietthuchanh" :min="1" :max="100" style="width: 100%" />
            </a-form-item>
          </a-col>
        </a-row>
      </a-form>
    </a-modal>
    <a-modal :title="`Danh sách chương: ${currentSubjectForChapters?.tenmonhoc || ''}`"
      v-model:open="showChapterListModal" @cancel="closeChapterListModal" width="700px" :footer="null" destroyOnClose>
      <a-button type="primary" @click="openAddChapterFormModal" style="margin-bottom: 16px;">
        + Thêm chương
      </a-button>
      <a-table :dataSource="chapters" :columns="chapterTableColumns" :loading="chapterListLoading" rowKey="machuong"
        :pagination="false" :key="currentSubjectForChapters?.mamonhoc">
        <template #bodyCell="{ column, record, index }">
          <template v-if="column.key === 'stt'">
            {{ index + 1 }}
          </template>
          <template v-if="column.key === 'actions'">
            <a-tooltip title="Sửa chương">
              <a-button type="text" @click="openEditChapterFormModal(record)" :icon="h(SquarePen)" />
            </a-tooltip>
            <a-tooltip title="Xoá chương">
              <a-popconfirm title="Bạn có chắc muốn xóa chương này?" ok-text="Có" cancel-text="Không"
                @confirm="handleDeleteChapter(record.machuong)">
                <a-button type="text" danger :icon="h(DeleteOutlined)" />
              </a-popconfirm>
            </a-tooltip>
          </template>
        </template>
      </a-table>
      <template #footer>
        <a-button key="back" @click="closeChapterListModal">Thoát</a-button>
      </template>
    </a-modal>

    <a-modal :title="isEditingChapter ? 'Sửa chương' : 'Thêm chương mới'" v-model:open="showChapterFormModal"
      @ok="handleChapterFormOk" @cancel="closeChapterFormModal" :confirmLoading="chapterFormLoading" destroyOnClose>
      <a-form ref="chapterFormRef" :model="currentChapter" layout="vertical" :rules="chapterRules">
        <a-form-item label="Tên chương" name="tenchuong" required>
          <a-input v-model:value="currentChapter.tenchuong" placeholder="Nhập tên chương" />
        </a-form-item>
      </a-form>
    </a-modal>
  </a-card>
</template>
<script setup>
import { ref, onMounted, h, watch, reactive } from "vue";
  import { SquarePen, Trash2, Info, Plus } from 'lucide-vue-next';
  import debounce from 'lodash/debounce';
import { message } from 'ant-design-vue';
  import { Search } from "lucide-vue-next";
import apiClient from "@/services/axiosServer";
const allSubjectsData = ref([]);
const subject = ref([]);
const searchText = ref('');
const pagination = ref({
  current: 1,
  pageSize: 6,
  total: 0,
});
const showAddModal = ref(false);
const showEditModal = ref(false);
  const modalLoading = ref(false);

const newSubject = ref({
  mamonhoc: "",
  tenmonhoc: "",
  sotinchi: 1,
  sotietlythuyet: 1,
  sotietthuchanh: 1,
});

const editSubject = ref({
  mamonhoc: "",
  tenmonhoc: "",
  sotinchi: 1,
  sotietlythuyet: 1,
  sotietthuchanh: 1,
});

const columns = [
  { title: "Mã môn học", dataIndex: "mamonhoc", key: "mamonhoc", width: 150 },
  { title: "Tên môn học", dataIndex: "tenmonhoc", key: "tenmonhoc", width: 150 },
  { title: "Số tín chỉ", dataIndex: "sotinchi", key: "sotinchi", width: 100 },
  { title: "Số tiết LT", dataIndex: "sotietlythuyet", key: "sotietlythuyet", width: 100 },
  { title: "Số tiết TH", dataIndex: "sotietthuchanh", key: "sotietthuchanh", width: 100 },
  { title: "Hành động", key: "actions", fixed: "right", width: 120, },
];
  const checkMaMonHocExists = async (rule, value) => {
    if (!value) return Promise.resolve();

    try {
      await apiClient.get(`/api/MonHoc/${value}`);
      return Promise.reject('Mã môn học đã tồn tại!');
    } catch (error) {
      if (error.response?.status === 404) {
        return Promise.resolve();
      }
      return Promise.reject('Lỗi kiểm tra mã môn học.');
    }
  };

const rules = {
  mamonhoc: [
    { required: true, message: "Vui lòng nhập mã môn học", trigger: "blur" },
    { validator: checkMaMonHocExists, trigger: 'blur' },
  ],
  tenmonhoc: [
    { required: true, message: "Vui lòng nhập tên môn học", trigger: "blur" },
  ],
  sotinchi: [
    { required: true, type: 'number', min: 1, message: "Tín chỉ phải ≥ 1", trigger: "change" },
  ],
  sotietlythuyet: [
    { required: true, type: 'number', min: 1, message: "Số tiết LT phải ≥ 1", trigger: "change" },
  ],
  sotietthuchanh: [
    { required: true, type: 'number', min: 0, message: "Số tiết TH phải ≥ 0", trigger: "change" },
  ],
};

const fetchAllSubjects = async () => {
  modalLoading.value = true;
  try {
    const response = await apiClient.get("/api/MonHoc");
    allSubjectsData.value = response.data.map(item => ({
      mamonhoc: item.mamonhoc,
      tenmonhoc: item.tenmonhoc,
      sotinchi: item.sotinchi,
      sotietlythuyet: item.sotietlythuyet,
      sotietthuchanh: item.sotietthuchanh,
      trangthai: item.trangthai
    }));
    updateDisplayedSubjects();
  } catch (error) {
    console.error("Lỗi khi tải toàn bộ môn học:", error);
    allSubjectsData.value = [];
    updateDisplayedSubjects();
  } finally {
    modalLoading.value = false;
  }
};

const updateDisplayedSubjects = () => {
  let dataToProcess = [...allSubjectsData.value];
  const keywordLower = searchText.value.trim().toLowerCase();

  if (keywordLower) {
    dataToProcess = allSubjectsData.value.filter((item) => {
      const maMonAsString = String(item.mamonhoc);
      const maMonMatch = maMonAsString.toLowerCase().includes(keywordLower);

      const tenMonMatch = item.tenmonhoc && typeof item.tenmonhoc === 'string'
        ? item.tenmonhoc.toLowerCase().includes(keywordLower)
        : false;
      return maMonMatch || tenMonMatch;
    });
  }

  pagination.value.total = dataToProcess.length;
  const start = (pagination.value.current - 1) * pagination.value.pageSize;
  const end = start + pagination.value.pageSize;
  subject.value = dataToProcess.slice(start, end);
};

const debouncedSearch = debounce(() => {
  pagination.value.current = 1;
  updateDisplayedSubjects();
}, 300);

watch(searchText, () => {
  debouncedSearch();
});

const handleTableChange = (newPagination) => {
  pagination.value.current = newPagination.current;
  pagination.value.pageSize = newPagination.pageSize;
  updateDisplayedSubjects();
};

const subjectForm = ref(null);
const editForm = ref(null);

  const handleAddOk = async () => {
    try {
      // 1. Validate form trên client trước
      await subjectForm.value.validate();
      modalLoading.value = true;
      const maMonHocToCheck = newSubject.value.mamonhoc;
      if (!maMonHocToCheck) {
        message.error("Vui lòng nhập mã môn học!");
        modalLoading.value = false;
        return;
      }
      // 2. GỬI YÊU CẦU KIỂM TRA TRÙNG LẶP
      try {
        await apiClient.get(`/api/MonHoc/${maMonHocToCheck}`);
        // Nếu lệnh await ở trên chạy thành công (không ném ra lỗi 404)
        // có nghĩa là MÃ MÔN HỌC ĐÃ TỒN TẠI.
        message.error(`Mã môn học '${maMonHocToCheck}' đã tồn tại! Vui lòng chọn mã khác.`);
        modalLoading.value = false;
        return; // Dừng hàm tại đây

      } catch (error) {
        if (error.response && error.response.status === 404) {
          // Mã hợp lệ, không cần làm gì, cứ để code chạy tiếp xuống dưới.
          console.log("Mã môn học hợp lệ, có thể thêm mới.");
        } else {
          // Nếu là một lỗi khác (ví dụ: mất mạng, lỗi server 500...), thì báo lỗi và dừng lại.
          console.error("Lỗi khi kiểm tra mã môn học:", error);
          message.error("Không thể kiểm tra được mã môn học. Vui lòng thử lại.");
          modalLoading.value = false;
          return;
        }
      }

      // 3. NẾU KIỂM TRA OK, TIẾN HÀNH THÊM MỚI
      const payload = {
        mamonhoc: Number(newSubject.value.mamonhoc),
        tenmonhoc: newSubject.value.tenmonhoc,
        sotinchi: newSubject.value.sotinchi,
        sotietlythuyet: newSubject.value.sotietlythuyet,
        sotietthuchanh: newSubject.value.sotietthuchanh,
        trangthai: true,
      };

      // Gửi yêu cầu POST để tạo mới
      await apiClient.post("/api/MonHoc", payload);

      message.success("Thêm môn học thành công!");
      showAddModal.value = false;
      subjectForm.value.resetFields();
      newSubject.value = { mamonhoc: "", tenmonhoc: "", sotinchi: 1, sotietlythuyet: 1, sotietthuchanh: 1 };
      await fetchAllSubjects(); // Tải lại danh sách

    } catch (error) {
      // Bắt các lỗi khác, ví dụ lỗi validation của form
      if (error?.message?.includes("validate")) {
        console.log("Lỗi validate form thêm:", error);
        // Thường thì Ant Design Vue đã tự hiển thị lỗi, không cần message.error
      } else {
        message.error("Đã xảy ra lỗi khi thêm môn học!");
      }
    } finally {
      modalLoading.value = false;
    }
  };

const handleAddCancel = () => {
  showAddModal.value = false;
  subjectForm.value.resetFields();
  newSubject.value = {
    mamonhoc: "", tenmonhoc: "", sotinchi: 1, sotietlythuyet: 1, sotietthuchanh: 1,
  };
};

const openEditModal = (record) => {
  editSubject.value = { ...record };
  showEditModal.value = true;
};

const handleEditOk = () => {
  editForm.value.validate().then(async () => {
    modalLoading.value = true;
    try {
      const payloadToUpdate = {
        tenmonhoc: editSubject.value.tenmonhoc,
        sotinchi: editSubject.value.sotinchi,
        sotietlythuyet: editSubject.value.sotietlythuyet,
        sotietthuchanh: editSubject.value.sotietthuchanh,
        trangthai: editSubject.value.trangthai,
      };
      await apiClient.put(`/api/MonHoc/${editSubject.value.mamonhoc}`, payloadToUpdate);
      showEditModal.value = false;
      await fetchAllSubjects();
    } catch (error) {
      console.error("Lỗi sửa môn học:", error);
    } finally {
      modalLoading.value = false;
    }
  }).catch((errorInfo) => {
    console.log("Lỗi validate form sửa:", errorInfo);
  });
};

const handleEditCancel = () => {
  showEditModal.value = false;
};

const handleDelete = async (mamonhocId) => {
  modalLoading.value = true;
  try {
    await apiClient.delete(`/api/MonHoc/${mamonhocId}`);
    await fetchAllSubjects();
  } catch (error) {
    console.error("Lỗi xóa môn học:", error);
  } finally {
    modalLoading.value = false;
  }
};

const showChapterListModal = ref(false);
const chapterListLoading = ref(false);
const currentSubjectForChapters = ref(null);
const chapters = ref([]);

const showChapterFormModal = ref(false);
const chapterFormLoading = ref(false);
const isEditingChapter = ref(false);
const chapterFormRef = ref();

const currentChapter = reactive({
  machuong: null,
  tenchuong: '',
  mamonhoc: null,
  trangthai: true,
});
const chapterTableColumns = [
  { title: 'STT', key: 'stt', width: 70 },
  { title: 'Tên chương', dataIndex: 'tenchuong', key: 'tenchuong' },
  { title: 'Hành động', key: 'actions', width: 120, align: 'center' },
];

const chapterRules = {
  tenchuong: [{ required: true, message: 'Vui lòng nhập tên chương!', trigger: 'blur' }],
};

const openChapterListModal = async (subjectRecord) => {
  currentSubjectForChapters.value = subjectRecord;
  showChapterListModal.value = true;
  await fetchChaptersBySubjectId(subjectRecord.mamonhoc);
};

const closeChapterListModal = () => {
  showChapterListModal.value = false;
  chapters.value = [];
  currentSubjectForChapters.value = null;
};


const fetchChaptersBySubjectId = async (subjectId) => {
  if (!subjectId) return;
  chapterListLoading.value = true;
  chapters.value = [];
  try {

    const timestamp = new Date().getTime();
    const response = await apiClient.get(`/api/chuong/?mamonhocId=${subjectId}&_=${timestamp}`);
    chapters.value = response.data;

  } catch (error) {
    console.error("Lỗi khi tải danh sách chương:", error);
    message.error('Không thể tải danh sách chương.');
  } finally {
    chapterListLoading.value = false;
  }
};


const openAddChapterFormModal = () => {
  isEditingChapter.value = false;
  Object.assign(currentChapter, {
    machuong: null,
    tenchuong: '',
    mamonhoc: currentSubjectForChapters.value.mamonhoc,
    trangthai: true,
  });
  showChapterFormModal.value = true;
};


const openEditChapterFormModal = (chapterRecord) => {
  isEditingChapter.value = true;
  Object.assign(currentChapter, chapterRecord);
  showChapterFormModal.value = true;
};

const closeChapterFormModal = () => {
  showChapterFormModal.value = false;
};


const handleChapterFormOk = async () => {
  try {
    await chapterFormRef.value.validate();
    chapterFormLoading.value = true;

    const payload = {
      tenchuong: currentChapter.tenchuong,
      mamonhoc: currentChapter.mamonhoc,
      trangthai: currentChapter.trangthai,
    };

    if (isEditingChapter.value) {
      await apiClient.put(`/api/chuong/${currentChapter.machuong}`, payload);
      message.success('Cập nhật chương thành công!');
    } else {
      await apiClient.post('/api/chuong', payload);
      message.success('Thêm chương mới thành công!');
    }

    closeChapterFormModal();
    await fetchChaptersBySubjectId(currentSubjectForChapters.value.mamonhoc);
  } catch (error) {
    console.error("Lỗi khi lưu chương:", error);
    message.error('Đã có lỗi xảy ra. Vui lòng thử lại.');
  } finally {
    chapterFormLoading.value = false;
  }
};


const handleDeleteChapter = async (chapterId) => {
  try {
    await apiClient.delete(`/api/chuong/${chapterId}`);
    message.success('Xóa chương thành công!');
    await fetchChaptersBySubjectId(currentSubjectForChapters.value.mamonhoc);
  } catch (error) {
    console.error("Lỗi khi xóa chương:", error);
    message.error('Không thể xóa chương này.');
  }
};

onMounted(() => {
  fetchAllSubjects();
});
</script>
