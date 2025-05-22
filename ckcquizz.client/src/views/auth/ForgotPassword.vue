<template>
  <div class="d-flex justify-content-center align-items-center vh-100">
    <div class="container">
      <div class="row justify-content-md-center">
        <div class="col-12 col-md-11 col-lg-8 col-xl-7 col-xxl-6">
          <div class="bg-white p-4 p-md-5 rounded shadow-sm">
            <div class="row gy-3 mb-5">
              <div class="col-12">
                <div class="text-center display-6">
                  <span>CKC <span class="text-primary">Quizz</span>
                  </span>
                </div>
              </div>
              <div class="col-12">
                <h2 class="fs-6 fw-normal text-center text-secondary m-0 px-md-5">Cung cấp email của bạn để thay đổi mật
                  khẩu</h2>
              </div>
            </div>
            <form @submit.prevent="handleForgotPassword">
              <div class="row gy-3 gy-md-4 overflow-hidden">
                <div class="col-12">
                  <label for="email" class="form-label">Email <span class="text-danger">*</span></label>
                  <div class="input-group">
                    <span class="input-group-text">
                      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor"
                        class="bi bi-envelope" viewBox="0 0 16 16">
                        <path
                          d="M0 4a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2V4Zm2-1a1 1 0 0 0-1 1v.217l7 4.2 7-4.2V4a1 1 0 0 0-1-1H2Zm13 2.383-4.708 2.825L15 11.105V5.383Zm-.034 6.876-5.64-3.471L8 9.583l-1.326-.795-5.64 3.47A1 1 0 0 0 2 13h12a1 1 0 0 0 .966-.741ZM1 11.105l4.708-2.897L1 5.383v5.722Z" />
                      </svg>
                    </span>
                    <input type="email" class="form-control" v-model="email" placeholder="Nhập email của bạn">
                  </div>
                </div>
                <div v-if="message" :class="['alert', messageType === 'success' ? 'alert-success' : 'alert-danger']"
                  role="alert">
                  {{ message }}
                </div>
                <div class="col-12">
                  <div class="d-grid">
                    <button class="btn btn-primary btn-lg" type="submit" :disabled="isLoading">
                      <span v-if="isLoading" class="spinner-border spinner-border-sm" role="status"
                        aria-hidden="true"></span>
                      {{ isLoading ? 'Đang xử lý...' : 'Gửi yêu cầu' }}
                    </button>
                  </div>
                </div>
              </div>
            </form>
            <div class="row">
              <div class="col-12">
                <hr class="mt-5 mb-4 border-secondary-subtle">
                <div class="d-flex gap-4 justify-content-center">
                  <RouterLink :to="{ name: 'SignIn' }" class="link-secondary text-decoration-none">
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

<script>
import axios from 'axios';
import { useRouter } from 'vue-router';
export default {
  name: 'ForgotPassword',
  setup() {
    const router = useRouter();
    return { router };
  },
  data() {
    return {
      email: '',
      isLoading: false,
      message: '',
      messageType: ''
    };
  },
  methods: {
    async handleForgotPassword() {
      this.message = '';
      this.messageType = '';

      if (!this.email) {
        this.message = 'Vui lòng nhập địa chỉ email.';
        return;
      }
      const emailRegex = /^[\w.+-]+@(gmail\.com|caothang\.edu\.vn)$/;
      
      if (!emailRegex.test(this.email)) {
        this.message = 'Định dạng Email không hợp lệ.';
        return;
      }

      this.isLoading = true;

      try {
        const response = await axios.post("https://localhost:7254/Auth/forgotpassword", {
          Email: this.email
        });

        if (response.status === 200 && response.data && response.data.email) {
          this.message = `Một mã OTP đã được gửi tới email ${response.data.email}. Vui lòng kiểm tra hộp thư của bạn.`;
          this.messageType = 'success';
          const userEmail = response.data.email;
          this.email = '';

          setTimeout(() => {
            this.$router.push({ name: 'VerifyPassword', query: { email: userEmail } });
          }, 2000);
        } else {
          this.message = 'Yêu cầu đã được gửi, nhưng phản hồi không như mong đợi.';
          this.messageType = 'warning';
        }

      } catch (error) {
        this.messageType = 'danger';

        if (error.response) {
          const { status, data } = error.response;

          if (status === 400) {
            if (data?.errors?.Email?.[0]) {
              this.message = data.errors.Email[0];
            } else if (data?.errors) {
              const firstErrorKey = Object.keys(data.errors)[0];
              this.message = data.errors[firstErrorKey]?.[0] || data.title || "Dữ liệu không hợp lệ.";
            } else if (typeof data === 'string') {
              this.message = data;
            } else {
              this.message = "Email không hợp lệ hoặc có lỗi dữ liệu. Vui lòng kiểm tra lại.";
            }
          } else if (status === 401) {

            this.message = data;
          } else {
            this.message = `Đã có lỗi từ máy chủ (mã lỗi: ${status}). Vui lòng thử lại sau.`;
          }
        } else if (error.request) {
          this.message = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng của bạn.';
        } else {
          this.message = 'Đã có lỗi xảy ra khi gửi yêu cầu.';
        }

        if (!this.message) {
          this.message = "Đã có lỗi không xác định xảy ra. Vui lòng thử lại.";
        }
      } finally {
        this.isLoading = false;
      }
    }
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