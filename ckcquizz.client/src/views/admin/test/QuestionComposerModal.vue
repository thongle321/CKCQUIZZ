<template>
  <a-modal :open="open"
           title="Soạn câu hỏi cho đề thi"
           width="95vw"
           :footer="null"
           @cancel="handleCancel"
           :destroyOnClose="true">
    <a-spin :spinning="isLoading">
      <a-row :gutter="16">
        <!-- CỘT BÊN TRÁI: NGÂN HÀNG CÂU HỎI -->
        <a-col :span="11">
          <QuestionBankList v-if="deThi"
                            :ma-mon-hoc="deThi.mamonhoc"
                            :existing-question-ids="existingQuestionIds"
                            @selection-change="handleBankSelectionChange" />
        </a-col>

        <!-- CỘT GIỮA: CÁC NÚT HÀNH ĐỘNG -->
        <a-col :span="2" style="display: flex; flex-direction: column; align-items: center; justify-content: center;">
          <a-tooltip title="Thêm câu hỏi đã chọn vào đề thi">
            <a-button type="primary"
                      :disabled="selectedFromBank.length === 0"
                      :loading="isAdding"
                      @click="addQuestionsToTest"
                      style="margin-bottom: 16px;">
              Thêm câu hỏi
            </a-button>
          </a-tooltip>
        </a-col>

        <!-- CỘT BÊN PHẢI: CÁC CÂU HỎI TRONG ĐỀ THI -->
        <a-col :span="11">
          <a-card :title="`Câu hỏi trong đề (${questionsInTest.length} câu)`" :bordered="false">
            <a-table :columns="testQuestionsColumns"
                     :data-source="questionsInTest"
                     :row-key="record => record.macauhoi"
                     size="small"
                     :pagination="{ pageSize: 15, hideOnSinglePage: true }">
              <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'noiDung'">
                  <div v-html="record.noiDung" class="question-content"></div>
                </template>
                <template v-if="column.key === 'action'">
                  <a-tooltip title="Xóa khỏi đề thi">
                    <a-popconfirm title="Xoá câu hỏi này khỏi đề thi?"
                                  ok-text="Xoá"
                                  cancel-text="Huỷ"
                                  @confirm="removeQuestionFromTest(record.macauhoi)">
                      <a-button type="text" danger size="small">
                        <template #icon>
                          <DeleteOutlined />
                        </template>
                      </a-button>
                    </a-popconfirm>
                  </a-tooltip>
                </template>
              </template>
            </a-table>
          </a-card>
        </a-col>
      </a-row>
    </a-spin>
  </a-modal>
</template>

<script setup>
import { ref, watch, computed } from 'vue';
import { message } from 'ant-design-vue';
import { RightOutlined, DeleteOutlined } from '@ant-design/icons-vue';
import QuestionBankList from './QuestionBankList.vue';
import apiClient from '@/services/axiosServer';

const props = defineProps({
  open: Boolean,
  deThi: Object,
});

const emit = defineEmits(['update:open', 'saved']);

const isLoading = ref(true);
const isAdding = ref(false);

const questionsInTest = ref([]); // Danh sách câu hỏi trong đề (bên phải)
const selectedFromBank = ref([]); // ID câu hỏi được chọn từ ngân hàng (bên trái)

// Cấu hình cột cho bảng câu hỏi trong đề
const testQuestionsColumns = [
  { title: 'Nội dung', dataIndex: 'noiDung', key: 'noiDung' },
  { title: 'Độ khó', dataIndex: 'doKho', key: 'doKho', width: 100 },
  { title: 'Hành động', key: 'action', width: 80, align: 'center' },
];
const existingQuestionIds = computed(() => questionsInTest.value.map(q => q.macauhoi));
//  Lấy danh sách câu hỏi đã có trong đề thi
const fetchTestQuestions = async () => {
  if (!props.deThi?.made) return;
  isLoading.value = true;
  try {
    const response = await apiClient.get(`/SoanThaoDeThi/${props.deThi.made}/cauhoi`);
    questionsInTest.value = response.data;
  } catch (error) {
    message.error("Lỗi: Không thể tải danh sách câu hỏi của đề thi.");
    console.error(error);
  } finally {
    isLoading.value = false;
  }
};
const handleBankSelectionChange = (selectedKeys) => {
  selectedFromBank.value = selectedKeys;
};
//Thêm các câu hỏi đã chọn vào đề thi
const addQuestionsToTest = async () => {
    if (selectedFromBank.value.length === 0) return;
    isAdding.value = true;
    try {
        const payload = {
            cauHoiIds: selectedFromBank.value
        };
      await apiClient.post(`/SoanThaoDeThi/${props.deThi.made}/cauhoi`, payload);
      message.success(`Đã thêm ${selectedFromBank.value.length} câu hỏi vào đề.`);
      selectedFromBank.value = [];

        // Tải lại danh sách câu hỏi trong đề để cập nhật và reset selection
        await fetchTestQuestions();
        emit('saved');

    } catch (error) {
        message.error("Lỗi: Không thể thêm câu hỏi vào đề thi.");
        console.error(error);
    } finally {
        isAdding.value = false;
    }
}
//Xoá một câu hỏi khỏi đề thi
  const removeQuestionFromTest = async (questionIdToRemove) => {
    const originalQuestions = [...questionsInTest.value];
    questionsInTest.value = questionsInTest.value.filter(q => q.macauhoi !== questionIdToRemove);
    try {
      await apiClient.delete(`/SoanThaoDeThi/${props.deThi.made}/cauhoi/${questionIdToRemove}`);
        message.success("Đã xoá câu hỏi khỏi đề thi.");
        emit('saved');

    } catch (error) {
      message.error("Lỗi: Không thể xoá câu hỏi khỏi đề thi.");
      questionsInTest.value = originalQuestions;
        console.error(error);
    }
}

const handleCancel = () => {
  emit('update:open', false);
};
  watch(() => props.open, (isOpen) => {
    if (isOpen && props.deThi) {
      // Reset state khi modal mở để đảm bảo dữ liệu mới
      questionsInTest.value = [];
      selectedFromBank.value = [];
      fetchTestQuestions();
    }
  }, { immediate: true });
</script>

<style scoped>
  .question-content {
    max-height: 60px;
    overflow-y: auto;
    word-break: break-word;
  }
</style>
