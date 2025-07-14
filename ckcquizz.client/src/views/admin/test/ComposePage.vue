<template>
  <a-page-header style="border: 1px solid rgb(235, 237, 240); margin-bottom: 16px; background-color: #fff;"
                 :title="`Soạn câu hỏi cho bộ đề : ${deThi ? deThi.tende : '...'}`"
                 @back="() => router.back()" />
  <a-spin :spinning="pageLoading">
    <a-row :gutter="16" v-if="deThi">
      <a-col :span="12">
        <QuestionBankList :ma-mon-hoc="deThi.monthi"
                          :existing-question-ids="existingQuestionIds"
                          @selection-change="handleBankSelectionChange">
        <template #extra>
          <a-tooltip title="Thêm các câu hỏi đã chọn vào đề thi">
            <a-button type="primary"
                      :disabled="selectedFromBank.length === 0"
                      :loading="isAdding"
                      @click="addQuestionsToTest">
              Thêm vào đề ({{ selectedFromBank.length }})
            </a-button>
          </a-tooltip>
        </template>
        </QuestionBankList>
      </a-col>
      <a-col :span="12">
        <a-card :title="`Câu hỏi trong đề (${questionsInTest.length} câu)`" :bordered="false">
            <template #extra>
              <!-- Nút xóa hàng loạt -->
              <a-popconfirm title="Bạn có chắc chắn muốn xóa các câu hỏi đã chọn?"
                            ok-text="Xoá"
                            cancel-text="Huỷ"
                            :disabled="selectedInTestKeys.length === 0"
                            @confirm="removeSelectedQuestions">
                <a-button type="primary" danger :disabled="selectedInTestKeys.length === 0">
                  Xóa câu hỏi đã chọn ({{ selectedInTestKeys.length }})
                </a-button>
              </a-popconfirm>
            </template>

            <a-table :columns="testQuestionsColumns"
                     :data-source="questionsInTest"
                     :row-key="record => record.macauhoi"
                     size="small"
                     :pagination="{ pageSize: 15, hideOnSinglePage: true }"
                     :row-selection="rowSelectionInTest">
              <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'noiDung'">
                  <div v-html="record.noiDung" class="question-content"></div>
                </template>
              </template>
            </a-table>
          </a-card>
      </a-col>
    </a-row>
    <a-empty v-else-if="!pageLoading" description="Không tìm thấy thông tin đề thi." />
  </a-spin>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { message } from 'ant-design-vue';
import { DeleteOutlined } from '@ant-design/icons-vue';
import QuestionBankList from './QuestionBankList.vue';
import apiClient from '@/services/axiosServer';

const props = defineProps({
  id: {
    type: [String, Number],
    required: true,
  },
});

const router = useRouter();

const pageLoading = ref(true);
const isAdding = ref(false);
const deThi = ref(null); // Thông tin chi tiết của đề thi
const questionsInTest = ref([]); // Danh sách câu hỏi trong đề (bên phải)
  const selectedFromBank = ref([]); // ID câu hỏi được chọn từ ngân hàng (bên trái)
  const selectedInTestKeys = ref([]);//State để lưu các key (ID) câu hỏi được chọn để xóa

const testQuestionsColumns = [
  { title: 'Nội dung', dataIndex: 'noiDung', key: 'noiDung' },
  { title: 'Độ khó', dataIndex: 'doKho', key: 'doKho', width: 100 },
];
 const rowSelectionInTest = computed(() => ({
    selectedRowKeys: selectedInTestKeys.value,
    onChange: (keys) => {
      selectedInTestKeys.value = keys;
    },
  }));
const existingQuestionIds = computed(() => questionsInTest.value.map(q => q.macauhoi));

// 3. Hàm fetch dữ liệu ban đầu
const fetchInitialData = async () => {
  pageLoading.value = true;
  try {
    // Lấy thông tin chi tiết đề thi
    const deThiRes = await apiClient.get(`/DeThi/${props.id}`);
    deThi.value = deThiRes.data;

    // Lấy danh sách câu hỏi đã có trong đề
    const questionsRes = await apiClient.get(`/SoanThaoDeThi/${props.id}/cauhoi`);
    questionsInTest.value = questionsRes.data;
  } catch (error) {
    message.error("Lỗi: Không thể tải dữ liệu của đề thi.");
    console.error(error);
    deThi.value = null;
  } finally {
    pageLoading.value = false;
  }
};


const handleBankSelectionChange = (selectedKeys) => {
  selectedFromBank.value = selectedKeys;
};

const addQuestionsToTest = async () => {
  if (selectedFromBank.value.length === 0) return;
  isAdding.value = true;
  try {
    await apiClient.post(`/SoanThaoDeThi/${props.id}/cauhoi`, { cauHoiIds: selectedFromBank.value });
    message.success(`Đã thêm ${selectedFromBank.value.length} câu hỏi vào đề.`);
    selectedFromBank.value = [];

    const questionsRes = await apiClient.get(`/SoanThaoDeThi/${props.id}/cauhoi`);
    questionsInTest.value = questionsRes.data;

  } catch (error) {
    message.error("Lỗi: Không thể thêm câu hỏi vào đề thi.");
  } finally {
    isAdding.value = false;
  }
};

  const removeSelectedQuestions = async () => {
    const idsToRemove = selectedInTestKeys.value;
    if (idsToRemove.length === 0) return;

    try {
      await apiClient.delete(`/SoanThaoDeThi/${props.id}/cauhoi`, {
        data: { cauHoiIds: idsToRemove }
      });

      message.success(`Đã xóa ${idsToRemove.length} câu hỏi khỏi đề thi.`);

      questionsInTest.value = questionsInTest.value.filter(
        q => !idsToRemove.includes(q.macauhoi)
      );
      selectedInTestKeys.value = [];

    } catch (error) {
      const errorMessage = error.response?.data?.message || "Đã xảy ra lỗi khi ẩn đề thi.";
      message.error(errorMessage);
    }
  };
onMounted(() => {
  fetchInitialData();
});
</script>

<style scoped>
  .question-content {
    max-height: 60px;
    overflow-y: auto;
    word-break: break-word;
  }
</style>
