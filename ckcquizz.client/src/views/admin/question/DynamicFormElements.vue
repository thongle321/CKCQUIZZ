<template>
  <div>
    <div v-if="formState.hasImage">
      <a-form-item label="Tải lên hình ảnh" name="hinhanhUrl">
        <a-upload :file-list="formState.fileList"
                  name="file"
                  list-type="picture"
                  action="https://localhost:7254/api/Files/upload"
                  :max-count="1"
                  @change="handleImageUpload"
                  @remove="handleImageRemove">
          <a-button>
            <upload-outlined />
            Chọn ảnh (Tối đa 1 ảnh)
          </a-button>
        </a-upload>

      </a-form-item>
    </div>

    <!-- 2. DÀNH CHO CÂU HỎI TỰ LUẬN -->
    <div v-if="formState.loaiCauHoi === 'essay'">
      <a-divider>Đáp án / Gợi ý</a-divider>
      <a-form-item label="Nội dung đáp án mẫu (không bắt buộc)" name="dapAnTuLuan">
        <a-textarea v-model:value="formState.dapAnTuLuan" :rows="3" placeholder="Nhập đáp án mẫu hoặc gợi ý" />
      </a-form-item>
    </div>

    <!-- 3. DÀNH CHO CÁC LOẠI CÓ LỰA CHỌN -->
    <div v-if="['single_choice', 'multiple_choice', 'image'].includes(formState.loaiCauHoi)">
      <a-divider>Các lựa chọn</a-divider>

      <!-- HIỂN THỊ CHO 1 ĐÁP ÁN ĐÚNG -->
      <a-form-item v-if="formState.loaiCauHoi === 'single_choice'" label="Chọn đáp án đúng" name="correctAnswer" :rules="[{ required: true, message: 'Vui lòng chọn đáp án đúng!' }]">
        <a-radio-group v-model:value="formState.correctAnswer" style="width: 100%;">
          <div v-for="(answer, index) in formState.dapAn" :key="index" class="answer-item">
            <a-radio :value="index" />
            <a-input v-model:value="answer.noidung" :placeholder="`Nội dung lựa chọn ${index + 1}`" />
            <DeleteOutlined v-if="formState.dapAn.length > 2" @click="removeAnswer(index)" class="delete-icon" />
          </div>
        </a-radio-group>
      </a-form-item>

      <!-- HIỂN THỊ CHO NHIỀU ĐÁP ÁN ĐÚNG & HÌNH ẢNH -->
      <a-form-item v-if="['multiple_choice', 'image'].includes(formState.loaiCauHoi)" label="Chọn các đáp án đúng" name="correctAnswer" :rules="[{ required: true, type: 'array', min: 1, message: 'Vui lòng chọn ít nhất một đáp án đúng!' }]">
        <a-checkbox-group v-model:value="formState.correctAnswer" style="width: 100%;">
          <div v-for="(answer, index) in formState.dapAn" :key="index" class="answer-item">
            <a-checkbox :value="index" />
            <a-input v-model:value="answer.noidung" :placeholder="`Nội dung lựa chọn ${index + 1}`" />
            <DeleteOutlined v-if="formState.dapAn.length > 2" @click="removeAnswer(index)" class="delete-icon" />
          </div>
        </a-checkbox-group>
      </a-form-item>

      <a-button type="dashed" @click="addAnswer" style="width: 100%">
        <PlusOutlined /> Thêm lựa chọn
      </a-button>
    </div>
  </div>
</template>

<script setup>
import { defineProps, defineEmits } from 'vue';
import { message } from 'ant-design-vue';
import { PlusOutlined, DeleteOutlined, UploadOutlined } from '@ant-design/icons-vue';
import apiClient from '../../../services/axiosServer';

const props = defineProps({
  formState: { type: Object, required: true },
});
/*  const urlImage = await apiClient.get('Files/upload');*/
const emit = defineEmits(['update:fileList']);

const handleImageUpload = (info) => {
  emit('update:fileList', info.fileList);
  if (info.file.status === 'done') {
    message.success(`${info.file.name} tải lên thành công.`);
    props.formState.hinhanhUrl = info.file.response.url; // Sử dụng tên thống nhất
  } else if (info.file.status === 'error') {
    message.error(`${info.file.name} tải lên thất bại.`);
    props.formState.hinhanhUrl = null;
  }
};

const handleImageRemove = () => {
  props.formState.hinhanhUrl = null;
  emit('update:fileList', []);
};

const addAnswer = () => {
  if (props.formState.dapAn.length < 6) {
    props.formState.dapAn.push({ noidung: '' });
  } else {
    message.warning('Chỉ có thể thêm tối đa 6 lựa chọn.');
  }
};

const removeAnswer = (indexToRemove) => {
  props.formState.dapAn.splice(indexToRemove, 1);
  const correctAnswer = props.formState.correctAnswer;

  if (typeof correctAnswer === 'number') {
    if (correctAnswer === indexToRemove) props.formState.correctAnswer = null;
    else if (correctAnswer > indexToRemove) props.formState.correctAnswer--;
  } else if (Array.isArray(correctAnswer)) {
    const idxInCorrect = correctAnswer.indexOf(indexToRemove);
    if (idxInCorrect > -1) correctAnswer.splice(idxInCorrect, 1);
    props.formState.correctAnswer = correctAnswer.map(i => (i > indexToRemove ? i - 1 : i));
  }
};
</script>

<style scoped>
  .answer-item {
    display: flex;
    align-items: center;
    margin-bottom: 8px;
    gap: 8px;
  }

  .delete-icon {
    color: red;
    cursor: pointer;
  }
</style>
