<template>
  <a-card title="Danh sách môn học" style="width: 100%">
    <div class="row">
      <div class="col-6 ">
        <a-input v-model:value="searchText" placeholder="Tìm kiếm môn học..." allow-clear enter-button block class="mb-4"  >
          <template #prefix>
            <Search size="14" />
          </template>
        </a-input>
      </div>
    </div>
    <a-table :dataSource="subject" :columns="columns" :pagination="pagination" rowKey="mamonhoc"
             @change="handleTableChange">
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'actions'">
          <a-tooltip title="Danh sách chương">
            <a-button type="text" @click="openChapterListModal(record)" :icon="h(Info)" />
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
              <a-button type="text" danger :icon="h(Trash2)" @click="handleDeleteChapter(record)" />
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
  import { ref, reactive,onMounted, h, watch } from "vue";
  import { SquarePen, Trash2, Plus,Info } from 'lucide-vue-next';
  import debounce from 'lodash/debounce';
  import { message, Modal } from 'ant-design-vue';
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
    { title: "Họ tên", dataIndex: "hoten", key: "hoten", width: 150 },
    { title: "Tên môn học", dataIndex: "tenmonhoc", key: "tenmonhoc", width: 100 },
    { title: "Hành động", key: "actions", fixed: "right", width: 120, },
  ];


  const rules = {
    mamonhoc: [
      { required: true, message: "Vui lòng nhập mã môn học", trigger: "blur" },
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
      const response = await apiClient.get("/api/PhanCong/my-assignments");
      allSubjectsData.value = response.data.map(item => ({
        mamonhoc: item.mamonhoc,
        hoten: item.hoten,
        tenmonhoc: item.tenmonhoc,
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

  const openEditModal = (record) => {
    editSubject.value = { ...record };
    showEditModal.value = true;
  };
  //Chương
  
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
const handleDeleteChapter = (record) => {
  Modal.confirm({
    title: 'Xác nhận xóa chương',
    content: `Bạn có chắc chắn muốn xóa chương "${record.tenchuong}" không? Hành động này không thể hoàn tác.`,
    okText: 'Xóa',
    okType: 'danger',
    cancelText: 'Hủy',
    async onOk() { 
      try {
        await apiClient.delete(`/api/chuong/${record.machuong}`);
        message.success(`Đã xóa thành công chương "${record.tenchuong}"`);
        // Tải lại danh sách chương
        await fetchChaptersBySubjectId(currentSubjectForChapters.value.mamonhoc);
      } catch (error) {
        message.error('Lỗi khi xóa chương: ' + (error.response?.data?.title || error.message));
        console.error(error);
      }
    },
  });
};
  const handleDelete = async (monhoc) => {
    Modal.confirm({
      title: 'Xác nhận xóa môn học',
      content: `Bạn có chắc chắn muốn xóa môn học ${monhoc.tenmonhoc}?`,
      okText: 'Có',
      okType: 'danger',
      cancelText: 'Không',
      onOk: async () => {
        try {
          await apiClient.delete(`/api/MonHoc/${monhoc.mamonhoc}`);
          message.success('Đã xóa môn học thành công');
          await fetchAllSubjects();
        } catch (error) {
          message.error('Lỗi khi xóa môn học' + (error.response?.data || error.message));
          console.error(error);
        }
      },
    });
  };
  onMounted(() => {
    fetchAllSubjects();
  });
</script>
