<template>
  <a-modal :open="open"
           :title="modalTitle"
           width="1000px"
           :confirm-loading="isSaving"
           @ok="handleSave"
           @cancel="handleCancel"
           ok-text="Lưu lại"
           cancel-text="Hủy">
    <a-spin :spinning="isLoading" tip="Đang tải dữ liệu...">
      <!-- Bộ lọc cho ngân hàng câu hỏi -->
      <a-row :gutter="16" style="margin-bottom: 16px;">
        <a-col :span="8">
          <a-select v-model:value="filters.maChuong" placeholder="Lọc theo chương" allow-clear style="width: 100%" @change="fetchSourceQuestions">
            <a-select-option v-for="chapter in chapters" :key="chapter.machuong" :value="chapter.machuong">
              {{ chapter.tenchuong }}
            </a-select-option>
          </a-select>
        </a-col>
        <a-col :span="8">
          <a-select v-model:value="filters.doKho" placeholder="Lọc theo độ khó" allow-clear style="width: 100%" @change="fetchSourceQuestions">
            <a-select-option :value="null">Tất cả</a-select-option>
            <a-select-option :value="1">Cơ bản</a-select-option>
            <a-select-option :value="2">Trung bình</a-select-option>
            <a-select-option :value="3">Nâng cao</a-select-option>
          </a-select>
        </a-col>
      </a-row>

      <a-transfer v-model:target-keys="targetKeys"
                  :data-source="questionList"
                  :render="item => item.title"
                  :show-search="true"
                  :filter-option="(input, item) => item.title.toLowerCase().includes(input.toLowerCase())"
                  :titles="['Ngân hàng câu hỏi', 'Câu hỏi đã chọn']"
                  :list-style="{ width: '45%', height: '400px' }">
        <template #notFoundContent>
          <a-empty description="Không có dữ liệu" />
        </template>
      </a-transfer>
    </a-spin>
  </a-modal>
</template>

<script setup>
  import { ref, reactive, watch, computed } from 'vue';
  import { message } from 'ant-design-vue';
  import apiClient from '@/services/axiosServer';

  // === 1. ĐỊNH NGHĨA PROPS VÀ EMITS ĐỂ GIAO TIẾP VỚI CHA ===
  const props = defineProps({
    open: { type: Boolean, required: true },
    deThi: { type: Object, default: () => null },
  });
  const emit = defineEmits(['update:open', 'save']);

  // === 2. STATE CỦA COMPONENT ===
  const isLoading = ref(false);
  const isSaving = ref(false);
  const questionList = ref([]); // Ngân hàng câu hỏi (bên trái)
  const targetKeys = ref([]); // Các câu hỏi đã chọn (bên phải)
  const chapters = ref([]);
  const filters = reactive({ maChuong: null, doKho: null });
  const currentMaMonHoc = ref(null);

  const modalTitle = computed(() => {
    return props.deThi ? `Chọn câu hỏi cho: ${props.deThi.tende}` : 'Chọn câu hỏi';
  });
  const initializeData = async () => {
    isLoading.value = true;
    console.clear();
    console.log("%c[MODAL] Bắt đầu tải dữ liệu...", "color: blue");

    try {
      const detailRes = await apiClient.get(`/DeThi/${props.deThi.made}`);
      currentMaMonHoc.value = detailRes.data.monthi;
      console.log("[MODAL] ✅ Lấy chi tiết đề thi thành công. Mã môn học:", currentMaMonHoc.value);

      if (!currentMaMonHoc.value) {
        message.error("Không thể xác định môn học của đề thi.");
        return;
      }

      console.log("[MODAL] Chuẩn bị gọi Promise.all...");
      const [chaptersRes, targetRes, sourceRes] = await Promise.all([
        apiClient.get(`/Chuong?mamonhocId=${currentMaMonHoc.value}`),
        // === SỬA LỖI URL Ở ĐÂY ===
        apiClient.get(`/dethi/${props.deThi.made}/cauhoi`),
        apiClient.get('/CauHoi', { params: { maMonHoc: currentMaMonHoc.value, pageSize: 1000 } }),
      ]);
      console.log("[MODAL] ✅ Promise.all hoàn thành!");

      // Bây giờ log này sẽ chạy
      console.log("[MODAL] Dữ liệu chương:", chaptersRes.data);
      console.log("[MODAL] Dữ liệu câu hỏi đã chọn:", targetRes.data);
      console.log("[MODAL] Dữ liệu ngân hàng câu hỏi:", sourceRes.data);

      chapters.value = chaptersRes.data;
      const targetQuestions = targetRes.data || [];
      const sourceQuestions = sourceRes.data?.items || [];

      targetKeys.value = targetQuestions.map(q => (q.maCauHoi || q.id).toString());

      const allQuestionsMap = new Map();
      const format = (q) => ({
        key: (q.macauhoi || q.maCauHoi || q.id).toString(),
        title: q.noidung || q.noiDung || `Câu hỏi #${q.macauhoi}`,
      });

      targetQuestions.forEach(q => allQuestionsMap.set(format(q).key, format(q)));
      sourceQuestions.forEach(q => {
        const formatted = format(q);
        if (!allQuestionsMap.has(formatted.key)) {
          allQuestionsMap.set(formatted.key, formatted);
        }
      });

      questionList.value = Array.from(allQuestionsMap.values());
      console.log("[MODAL] ✅ Gán dữ liệu vào state thành công!");

    } catch (err) {
      message.error("Lỗi khi tải dữ liệu. Vui lòng kiểm tra Console (F12).");
      // === THÊM LOG LỖI CHI TIẾT VÀO ĐÂY ===
      console.error("%c[MODAL] Lỗi trong initializeData:", "color: red; font-weight: bold", err);
      if (err.response) {
        console.error("Lỗi API chi tiết:", {
          url: err.config.url,
          status: err.response.status,
          data: err.response.data
        });
      }
    } finally {
      isLoading.value = false;
    }
  };

  const fetchSourceQuestions = async () => {

    isLoading.value = true;
    try {
      const params = {
        maMonHoc: currentMaMonHoc.value,
        maChuong: filters.machuong,
        doKho: filters.doKho,
        pageSize: 1000,
      };
      const res = await apiClient.get('/CauHoi', { params });
      const sourceQuestions = res.data.items;

      const allQuestionsMap = new Map();
      const currentTargetItems = questionList.value.filter(q => targetKeys.value.includes(q.key));
      currentTargetItems.forEach(item => allQuestionsMap.set(item.key, item));

      sourceQuestions.forEach(q => {
        const item = formatQuestionForTransfer(q);
        if (!allQuestionsMap.has(item.key)) {
          allQuestionsMap.set(item.key, item);
        }
      });
      questionList.value = Array.from(allQuestionsMap.values());

    } catch (err) {
      message.error("Lỗi khi lọc câu hỏi.");
    } finally {
      isLoading.value = false;
    }
  }

  const handleSave = async () => {
    isSaving.value = true;
    try {
      const payload = {
        maCauHois: targetKeys.value.map(key => parseInt(key, 10))
      };
      await apiClient.post(`/dethi/${props.deThi.made}/cap-nhat-chi-tiet`, payload);
      message.success("Cập nhật đề thi thành công!");
      emit('save'); // Báo cho cha đã lưu xong
      handleCancel(); // Đóng modal
    } catch (err) {
      message.error("Lỗi khi lưu.");
    } finally {
      isSaving.value = false;
    }
  };

  const handleCancel = () => {
    emit('update:open', false); // Báo cho cha để đóng modal
  };

  const formatQuestionForTransfer = (q) => ({
    key: (q.macauhoi || q.maCauHoi || q.id).toString(),
    title: q.noidung || q.noiDung || `Câu hỏi #${q.macauhoi}`,
  });

  // === 3. DÙNG WATCH ĐỂ PHẢN ỨNG KHI MODAL ĐƯỢC MỞ ===
  watch(() => props.open, (isOpen) => {
    if (isOpen && props.deThi?.made) {
      initializeData();
    }
  });
</script>
