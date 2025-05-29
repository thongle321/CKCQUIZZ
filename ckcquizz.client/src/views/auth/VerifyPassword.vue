<template>
  <div class="d-flex justify-content-center align-items-center vh-100">
    <div class="container">
      <div class="row justify-content-md-center">
        <div class="col-12 col-md-11 col-lg-8 col-xl-7 col-xxl-6">
          <div class="bg-white p-4 p-md-5 rounded shadow-sm">
            <div class="row gy-3 mb-5">
              <div class="col-12">
                <div class="text-center display-6">
                  <span>CKC <span class="text-primary">Quizz</span></span>
                </div>
              </div>
              <div class="col-12">
                <h2 class="fs-6 fw-normal text-center text-secondary m-0 px-md-5">Nhập mã OTP mà bạn
                  nhận được trong email ({{ emailForVerification }}) để xác thực.</h2>
              </div>
            </div>
            <form @submit.prevent="handleVerifyOtp">
              <div class="row gy-3 gy-md-4 overflow-hidden">
                <div class="col-12">
                  <label for="otp" class="form-label">OTP <span class="text-danger">*</span></label>
                  <otp :digit-count="6" @update:otp="otpValue = $event"></otp>
                  <!-- Sửa tên component thành otp-input nếu tên file là OTP.vue -->
                </div>
                <div v-if="message"
                  :class="['alert mt-3', messageType === 'success' ? 'alert-success' : 'alert-danger']" role="alert">
                  {{ message }}
                </div>
                <div class="col-12">
                  <div class="d-grid">
                    <button class="btn btn-primary btn-lg" type="submit" :disabled="isLoading">
                      <span v-if="isLoading" class="spinner-border spinner-border-sm" role="status"
                        aria-hidden="true"></span>
                      {{ isLoading ? 'Đang xác thực...' : 'Xác thực' }}
                    </button>
                  </div>
                </div>
              </div>
            </form>
            <div class="row mt-3">
              <div class="col-12 text-center">
                <RouterLink :to="{ name: 'ForgotPassword' }">Yêu cầu gửi lại OTP?</RouterLink>
              </div>
            </div>
            <div class="row">
              <div class="col-12">
                <hr class="mt-5 mb-4 border-secondary-subtle">
                <div class="d-flex gap-4 justify-content-center">
                  <RouterLink :to="{ name: 'ForgotPassword' }" class="link-secondary text-decoration-none">
                    Quay lại
                  </RouterLink>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import axios from 'axios';
import otp from "@/components/Auth/OTP.vue";
import { ref, onMounted } from "vue";
import { useRoute, useRouter } from 'vue-router';

const otpValue = ref('');
const emailForVerification = ref('');
const isLoading = ref(false);
const message = ref('');
const messageType = ref('');

const route = useRoute();
const router = useRouter();

onMounted(() => {
  if (route.query.email) {
    emailForVerification.value = route.query.email;
  } else {
    message.value = 'Không tìm thấy thông tin email. Vui lòng thử lại từ bước yêu cầu OTP.';
    messageType.value = 'danger';
    setTimeout(() => {
      router.push({ name: 'ForgotPassword' });
    }, 3000);
  }
});

async function handleVerifyOtp() {
  if (!otpValue.value || otpValue.value.length !== 6) {
    message.value = 'Vui lòng nhập đủ 6 chữ số OTP.';
    messageType.value = 'danger';
    return;
  }
  if (!emailForVerification.value) {
    message.value = 'Lỗi: không có thông tin email để xác thực.';
    messageType.value = 'danger';
    return;
  }

  isLoading.value = true;
  message.value = '';
  messageType.value = '';

  try {
    const response = await axios.post("https://localhost:7254/Auth/verifyotp", {
      email: emailForVerification.value,
      otp: otpValue.value
    });

    if (response.status === 200 && response.data) {
      message.value = response.data.message || "Xác thực OTP thành công. Bạn sẽ được chuyển đến trang đặt lại mật khẩu.";
      messageType.value = 'success';
      // Lưu token và email để sử dụng ở trang Reset Password
      // Ví dụ: localStorage.setItem('resetPasswordToken', response.data.passwordResetToken);
      // localStorage.setItem('resetEmail', response.data.email);

      // Chuyển hướng đến trang Reset Password
      setTimeout(() => {
        router.push({
          name: 'ResetPassword', // Thay bằng tên route của trang đặt lại mật khẩu
          query: {
            email: response.data.email,
            token: response.data.passwordResetToken
          }
        });
      }, 2000);
    }
  } catch (error) {
    messageType.value = 'danger';
    if (error.response && error.response.data) {
      message.value = error.response.data.message || error.response.data.title || "Mã OTP không hợp lệ hoặc đã hết hạn.";
      if (error.response.data.errors) { // Nếu backend trả về lỗi validation chi tiết
        const firstErrorKey = Object.keys(error.response.data.errors)[0];
        message.value = error.response.data.errors[firstErrorKey][0];
      }
    } else if (error.request) {
      message.value = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.';
    } else {
      message.value = 'Đã có lỗi xảy ra khi gửi yêu cầu.';
    }
    console.error("Verify OTP Error:", error);
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
}

.container .bg-white {
  box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15) !important;
}
</style>