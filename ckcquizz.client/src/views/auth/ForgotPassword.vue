<template>
  <div class="d-flex justify-content-center align-items-center vh-100">
    <div class="container">
      <div class="row justify-content-md-center">
        <div class="col-12 col-md-11 col-lg-8 col-xl-7 col-xxl-6">
          <div class="bg-white p-4 p-md-5 rounded shadow-sm">
            <div class="row gy-3 mb-5">
              <div class="col-12">
                <div class="text-center">
                  <h2>CKC QUIZZ</h2>
                </div>
              </div>
              <div class="col-12">
                <h2 class="fs-6 fw-normal text-center text-secondary m-0 px-md-5">Cung cấp email của bạn để thay đổi mật
                  khẩu</h2>
              </div>
            </div>
            <!-- Bắt sự kiện @submit và ngăn chặn hành vi mặc định -->
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
                    <!-- Sử dụng v-model để binding dữ liệu -->
                    <input type="email" class="form-control" v-model="email" placeholder="Nhập email của bạn" required>
                  </div>
                </div>
                <!-- Hiển thị thông báo -->
                <div v-if="message" :class="['alert', messageType === 'success' ? 'alert-success' : 'alert-danger']"
                  role="alert">
                  {{ message }}
                </div>
                <div class="col-12">
                  <div class="d-grid">
                    <!-- Disable nút khi đang gửi yêu cầu -->
                    <button class="btn btn-primary btn-lg" type="submit" :disabled="isLoading">
                      <span v-if="isLoading" class="spinner-border spinner-border-sm" role="status"
                        aria-hidden="true"></span>
                      {{ isLoading ? 'Đang xử lý...' : 'Thay đổi mật khẩu' }}
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
                    Quay lại đăng nhập
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

export default {
  name: 'ForgotPasswordForm', // Đặt tên cho component
  data() {
    return {
      email: '', // Biến để lưu trữ email người dùng nhập
      message: '', // Biến để lưu trữ thông báo cho người dùng
      messageType: '', // 'success' hoặc 'error'
      isLoading: false, // Trạng thái đang tải
    };
  },
  methods: {
    async handleForgotPassword() {
      if (!this.email) {
        this.message = 'Vui lòng nhập địa chỉ email của bạn.';
        this.messageType = 'error';
        return;
      }

      this.isLoading = true;
      this.message = '';

      try {
        const response = await axios.post('https://localhost:7254/Auth/forgotpassword', { // Đảm bảo URL này đúng
          email: this.email,
        });

        // Kiểm tra dựa trên HTTP status code và sự tồn tại của thuộc tính 'email' trong phản hồi
        // Vì API hiện tại không trả về 'success' hay 'message'
        if (response.status === 200 && response.data && typeof response.data.email === 'string') {
          // API đã xử lý yêu cầu và trả về email đã xử lý.
          // Chúng ta cần tự tạo message cho người dùng.
          this.message = "Nếu email của bạn (" + response.data.email + ") tồn tại trong hệ thống, một mã đặt lại mật khẩu đã được gửi. Vui lòng kiểm tra hộp thư.";
          this.messageType = 'success';
        } else {
          // Trường hợp không mong đợi hoặc API trả về lỗi mà không có cấu trúc rõ ràng
          this.message = 'Đã có lỗi xảy ra trong quá trình xử lý. Vui lòng thử lại.';
          this.messageType = 'error';
        }
      } catch (error) {
        console.error('Lỗi khi gửi yêu cầu quên mật khẩu:', error);
        if (error.response && error.response.data) {
          const apiError = error.response.data;
          // Nếu API có trả về một cấu trúc lỗi nào đó (ví dụ, nếu là lỗi 400 từ ModelState)
          if (apiError.errors && Array.isArray(apiError.errors) && apiError.errors.length > 0) {
            this.message = apiError.errors.join(' ');
          } else if (apiError.title) { // ASP.NET Core thường trả về 'title' cho lỗi 400
            this.message = apiError.title;
          } else if (typeof apiError === 'string') { // Nếu lỗi chỉ là một chuỗi
            this.message = apiError;
          }
          else {
            this.message = 'Không thể gửi yêu cầu. Vui lòng kiểm tra lại thông tin.';
          }
        } else {
          this.message = 'Đã có lỗi xảy ra khi kết nối đến máy chủ. Vui lòng thử lại sau.';
        }
        this.messageType = 'error';
      } finally {
        this.isLoading = false;
      }
    },
  },
};
</script>
<style scoped>
:global(body) {
  background-image: url("../../assets/images/reset-password.jpg");
  background-size: cover;
}
</style>
