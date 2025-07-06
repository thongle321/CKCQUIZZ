<template>
  <a-card title="Danh sách môn học" style="width: 100%">
    <a-row>
      <a-col :span="24">
        <a-input v-model:value="searchText" placeholder="Tìm kiếm môn học..." allow-clear enter-button block
          class="mb-4">
          <template #prefix>
            <Search size="14" />
          </template>
        </a-input>
      </a-col>
    </a-row>
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

    <a-modal :title="`Danh sách chương: ${currentSubjectForChapters?.tenmonhoc || ''}`"
      v-model:open="showChapterListModal" @cancel="closeChapterListModal" width="700px" :footer="null" destroyOnClose>
      <a-button type="primary" @click="openAddChapterFormModal" style="margin-bottom: 16px;"
        v-if="userStore.canCreate('Chuong')">
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
              <a-button type="text" @click="openEditChapterFormModal(record)" :icon="h(SquarePen)"
                v-if="userStore.canUpdate('Chuong')" />
            </a-tooltip>
            <a-tooltip title="Xoá chương">
              <a-button type="text" danger :icon="h(Trash2)" @click="handleDeleteChapter(record)"
                v-if="userStore.canDelete('Chuong')" />
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
import { ref, reactive, onMounted, h, watch } from "vue";
import { SquarePen, Trash2, Plus, Info } from 'lucide-vue-next';
import debounce from 'lodash/debounce';
import { message, Modal } from 'ant-design-vue';
import { Search } from "lucide-vue-next";
import apiClient from "@/services/axiosServer";
import { useUserStore } from '@/stores/userStore';

const userStore = useUserStore();
const allSubjectsData = ref([]);
const subject = ref([]);
const searchText = ref('');
const pagination = ref({
  current: 1,
  pageSize: 6,
  total: 0,
});
const modalLoading = ref(false);

const columns = [
  { title: "Mã môn học", dataIndex: "mamonhoc", key: "mamonhoc", width: 150 },
  { title: "Họ tên", dataIndex: "hoten", key: "hoten", width: 150 },
  { title: "Tên môn học", dataIndex: "tenmonhoc", key: "tenmonhoc", width: 100 },
  { title: "Hành động", key: "actions", align: "center", width: 120, },
];


const fetchAllSubjects = async () => {
  try {
    if (!userStore.canView('Chuong')) {
      allSubjectsData.value = [];
      pagination.value.total = 0; 
      return;
    }
    const response = await apiClient.get("/PhanCong/my-assignments");
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
  tenchuong: [{ required: true, message: 'Tên chương là bắt buộc', trigger: 'blur' }],
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

    const response = await apiClient.get(`/chuong/?mamonhocId=${subjectId}`);
    chapters.value = (response.data || []).filter(item => item.trangthai === true); 

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
      await apiClient.put(`/chuong/${currentChapter.machuong}`, payload);
      message.success('Cập nhật chương thành công!');
    } else {
      await apiClient.post('/chuong', payload);
      message.success('Thêm chương mới thành công!');
    }

    closeChapterFormModal();
    await fetchChaptersBySubjectId(currentSubjectForChapters.value.mamonhoc);
  } catch (error) {
    if (error.response && error.response.status === 404) {
      message.error('Thao tác thất bại. Chương này có thể đã bị xóa hoặc bạn không có quyền chỉnh sửa.');
    } else {
      message.error('Đã có lỗi xảy ra. Vui lòng thử lại.');
    }
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
        await apiClient.delete(`/chuong/${record.machuong}`);
        message.success(`Đã xóa thành công chương "${record.tenchuong}"`);
        await fetchChaptersBySubjectId(currentSubjectForChapters.value.mamonhoc);
      } catch (error) {
        if (error.response && error.response.status === 404) {
          message.error('Xóa thất bại. Chương này có thể đã bị người khác xóa hoặc bạn không có quyền.');
        } else {
          message.error('Lỗi khi xóa chương: ' + (error.response?.data?.title || error.message));
        }
      }
    },
  });
};

onMounted(async () => {
  await userStore.fetchUserPermissions();
  fetchAllSubjects();
});
</script>
