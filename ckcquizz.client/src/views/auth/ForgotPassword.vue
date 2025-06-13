<template>
  <div class="container-fluid">
    <a-row justify="center" align="middle" style="height: 100vh">
      <a-col :xs="22" :sm="16" :md="12" :lg="10" :xl="8" :xxl="7">
        <a-card class="shadow-lg" :body-style="{ padding: '2rem 2.5rem' }">
          <div class="text-center mb-5">
            <a-typography-title :level="2" class="mb-2">
              <span>CKC <span class="text-primary">Quizz</span></span>
            </a-typography-title>
            <a-typography-paragraph type="secondary">
              Cung cấp email của bạn để thay đổi mật khẩu
            </a-typography-paragraph>
          </div>

          <a-form layout="vertical" :model="emailModel" @finish="handleForgotPassword">
            <a-form-item label="Email" name="email" :rules="emailRules">
              <a-input class="mb-2" v-model:value="emailModel.email" placeholder="Nhập email của bạn" size="large">
                <template #prefix>
                  <Mail size="16" />
                </template>
              </a-input>
            </a-form-item>

            <a-form-item v-if="message">
              <a-alert :message="message" :type="messageType" show-icon />
            </a-form-item>

            <a-form-item>
              <a-button class="mt-3" type="primary" html-type="submit" :loading="isLoading" block size="large">
                {{ isLoading ? 'Đang xử lý...' : 'Gửi yêu cầu' }}
              </a-button>
            </a-form-item>
          </a-form>

          <a-divider />
          <div class="text-center">
            <RouterLink :to="{ name: 'SignIn' }">
              Quay lại đăng nhập
            </RouterLink>
          </div>
        </a-card>
      </a-col>
    </a-row>
  </div>
</template>

<script setup lang="js">
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import apiClient from '@/services/axiosServer';
import { Mail } from 'lucide-vue-next';

const router = useRouter();

const emailModel = ref({ email: ''});

const isLoading = ref(false);
const message = ref('');
const messageType = ref('success');

const emailRules = [
  { required: true, message: 'Vui lòng nhập địa chỉ email!', trigger: 'blur' },
  { pattern: /^[a-zA-Z0-9._%+-]+@([a-zA-Z0-9.-]+\.[a-zA-Z]{2,}|caothang\.edu\.vn)$/, message: 'Email không đúng định dạng', trigger: ['blur', 'change'] }
]
const handleForgotPassword = async () => {
  message.value = '';
  isLoading.value = true;

  try {
    const response = await apiClient.post("/Auth/forgotpassword", {
      Email: emailModel.value.email
    });

    message.value = `Một mã OTP đã được gửi tới email ${emailModel.value.email}. Vui lòng kiểm tra hộp thư của bạn.`;
    messageType.value = 'success';
    const userEmail = emailModel.value.email;
    emailModel.value.email = '';

    setTimeout(() => {
      router.push({ name: 'VerifyPassword', query: { email: userEmail } });
    }, 2000);

  } catch (error) {
    messageType.value = 'error';
    if (error.response) {
      const { status, data } = error.response;
      if (status === 404) {

        message.value = data;
      } else if (status === 400 && data.errors) {
        const firstErrorKey = Object.keys(data.errors)[0];
        message.value = data.errors[firstErrorKey]?.[0] || 'Dữ liệu không hợp lệ.';
      }

    } else {
      message.value = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng của bạn.';
    }
  } finally {
    isLoading.value = false;
  }
}
</script>

<style scoped>
:global(body) {
  background-image: url("../../assets/images/reset-password.jpg");
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
  background-attachment: fixed;
}

.text-primary {
  color: #1677ff;
}

.text-center {
  text-align: center;
}
</style>