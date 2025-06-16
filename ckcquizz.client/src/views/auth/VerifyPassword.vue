<template>
  <div class="container-fluid">
    <a-row justify="center" align="middle" style="height: 100vh">
      <a-col :xs="22" :sm="16" :md="12" :lg="10" :xl="8" :xxl="7">
        <a-card class="shadow-lg" :body-style="{ padding: '2rem 2.5rem' }">
          <div class="text-center mb-5">
            <a-typography-title :level="2" class="mb-2">
              <span>CKC <span class="text-primary">Quizz</span></span>
            </a-typography-title>
            <a-typography-paragraph type="secondary" v-if="emailForVerification">
              Nhập mã OTP đã được gửi tới email
              <strong>{{ emailForVerification }}</strong>
            </a-typography-paragraph>
          </div>

          <a-form layout="vertical" :model="otpModel" @finish="handleVerifyOtp">
            <a-form-item label="Mã xác thực" name="otp" :rules="otpRules">
              <otp :digit-count="6" @update:otp="otpModel.otp = $event"></otp>
            </a-form-item>

            <a-form-item v-if="message">
              <a-alert :message="message" :type="messageType" show-icon />
            </a-form-item>

            <a-form-item>
              <a-button type="primary" html-type="submit" :loading="isLoading" block size="large">
                {{ isLoading ? 'Đang xác thực...' : 'Xác thực' }}
              </a-button>
            </a-form-item>
          </a-form>

          <div class="text-center">
            <a-button type="link" @click="handleResendOtp" :loading="isResending">
              {{ isResending ? 'Đang gửi...' : 'Chưa nhận được mã? Gửi lại' }}
            </a-button>
          </div>

          <a-divider />

          <div class="text-center">
            <RouterLink :to="{ name: 'ForgotPassword' }">
              Quay lại
            </RouterLink>
          </div>
        </a-card>
      </a-col>
    </a-row>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from "vue";
import { useRoute, useRouter } from 'vue-router';
import apiClient from '@/services/axiosServer';
import otp from "@/components/Auth/OTP.vue";
import { notification } from 'ant-design-vue';

const router = useRouter();
const route = useRoute();

const otpModel = ref({
  otp: '',
});

const emailForVerification = ref('');
const isLoading = ref(false);
const isResending = ref(false);
const message = ref('');
const messageType = ref('success');

const otpRules = [
  { required: true, message: 'Vui lòng nhập mã OTP!' },
  { len: 6, message: 'Mã OTP phải có đúng 6 chữ số!', trigger: 'blur' },
];



const handleVerifyOtp = async () => {
  isLoading.value = true;
  message.value = '';

  try {
    const response = await apiClient.post("/Auth/verifyotp", {
      email: emailForVerification.value,
      otp: otpModel.value.otp
    });

    message.value = response.data.message || "Xác thực thành công!";
    messageType.value = 'success';

    setTimeout(() => {
      router.push({
        name: 'ResetPassword',
        query: {
          email: response.data.email,
          token: response.data.passwordResetToken
        }
      })
    }, 2000);

  } catch (error) {
    messageType.value = 'error';
    if (error.response?.data) {
      message.value = error.response.data.message || error.response.data.title || "Mã OTP không hợp lệ hoặc đã hết hạn.";
    } else {
      message.value = 'Không thể kết nối đến máy chủ. Vui lòng thử lại.';
    }
  } finally {
    isLoading.value = false;
  }
}

const handleResendOtp = async () => {
  isResending.value = true;
  try {
    await apiClient.post("/Auth/forgotpassword", {
      Email: emailForVerification.value
    });
    notification.success({
      message: 'Thành công',
      description: `Một mã OTP mới đã được gửi tới email ${emailForVerification.value}.`
    });
  } catch (error) {
    notification.error({
      message: 'Gửi lại thất bại',
      description: 'Đã có lỗi xảy ra. Vui lòng thử lại sau.'
    });
  } finally {
    isResending.value = false;
  }
}

onMounted(() => {
  if (route.query.email) {
    emailForVerification.value = route.query.email;
  } else {
    notification.error({
      message: 'Lỗi truy cập',
      description: 'Không tìm thấy thông tin email. Đang chuyển hướng về trang yêu cầu OTP.',
      duration: 3
    });
    setTimeout(() => {
      router.push({ name: 'ForgotPassword' })
    }, 3000);
  }
})
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