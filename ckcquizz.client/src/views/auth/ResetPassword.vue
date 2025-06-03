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
                                <h2 class="fs-6 fw-normal text-center text-secondary m-0 px-md-5">
                                    Đặt lại mật khẩu của bạn
                                </h2>
                            </div>
                        </div>
                        <form @submit.prevent="handleResetPassword">
                            <div class="row gy-3 gy-md-4 overflow-hidden">
                                <div class="col-12">
                                    <label for="email" class="form-label">Email</label>
                                    <div class="input-group mb-3">
                                        <span class="input-group-text">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16"
                                                fill="currentColor" class="bi bi-envelope" viewBox="0 0 16 16">
                                                <path
                                                    d="M0 4a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2V4Zm2-1a1 1 0 0 0-1 1v.217l7 4.2 7-4.2V4a1 1 0 0 0-1-1H2Zm13 2.383-4.708 2.825L15 11.105V5.383Zm-.034 6.876-5.64-3.471L8 9.583l-1.326-.795-5.64 3.47A1 1 0 0 0 2 13h12a1 1 0 0 0 .966-.741ZM1 11.105l4.708-2.897L1 5.383v5.722Z" />
                                            </svg>
                                        </span>
                                        <input type="email" class="form-control" id="email" :value="email" readonly>
                                    </div>
                                </div>

                                <div class="col-12">
                                    <label for="newPassword" class="form-label">Mật khẩu mới <span
                                            class="text-danger">*</span></label>
                                    <div class="input-group mb-3">
                                        <input type="password" class="form-control"
                                            :class="{ 'is-invalid': errors.newPassword }" id="newPassword"
                                            v-model="newPassword" placeholder="Nhập mật khẩu mới" required>
                                    </div>
                                    <div v-if="errors.newPassword" class="invalid-feedback d-block">
                                        {{ errors.newPassword }}
                                    </div>
                                </div>

                                <div class="col-12">
                                    <label for="confirmPassword" class="form-label">Xác nhận mật khẩu mới <span
                                            class="text-danger">*</span></label>
                                    <div class="input-group mb-3">
                                        <input type="password" class="form-control"
                                            :class="{ 'is-invalid': errors.confirmPassword }" id="confirmPassword"
                                            v-model="confirmPassword" placeholder="Nhập lại mật khẩu mới" required>
                                    </div>
                                    <div v-if="errors.confirmPassword" class="invalid-feedback d-block">
                                        {{ errors.confirmPassword }}
                                    </div>
                                </div>

                                <div v-if="message"
                                    :class="['alert mt-3', messageType === 'success' ? 'alert-success' : 'alert-danger']"
                                    role="alert">
                                    {{ message }}
                                </div>
                                <!-- Để hiển thị các lỗi chung từ API (nếu có) -->
                                <div v-if="apiGeneralError" class="alert alert-danger mt-3" role="alert">
                                    {{ apiGeneralError }}
                                </div>

                                <div class="col-12">
                                    <div class="d-grid">
                                        <button class="btn btn-primary btn-lg" type="submit" :disabled="isLoading">
                                            <span v-if="isLoading" class="spinner-border spinner-border-sm"
                                                role="status" aria-hidden="true"></span>
                                            {{ isLoading ? 'Đang xử lý...' : 'Đặt lại mật khẩu' }}
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </form>
                        <div class="row mt-4" v-if="messageType === 'success'">
                            <div class="col-12 text-center">
                                <RouterLink :to="{ name: 'SignIn' }" class="btn btn-outline-primary">
                                    Đến trang Đăng nhập
                                </RouterLink>
                            </div>
                        </div>
                        <div class="row mt-3" v-else>
                            <div class="col-12 text-center">
                                <RouterLink :to="{ name: 'ForgotPassword' }"
                                    class="link-secondary text-decoration-none">
                                    Yêu cầu lại OTP?
                                </RouterLink>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, onMounted, reactive } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import axios from 'axios';

const route = useRoute();
const router = useRouter();

const email = ref('');
const token = ref('');
const newPassword = ref('');
const confirmPassword = ref('');

const isLoading = ref(false);
const message = ref('');
const messageType = ref('');
const apiGeneralError = ref('');

const errors = reactive({
    newPassword: '',
    confirmPassword: ''
});

onMounted(() => {
    email.value = route.query.email || '';
    token.value = route.query.token || '';

    if (!email.value || !token.value) {
        message.value = 'Thông tin đặt lại mật khẩu không hợp lệ hoặc đã hết hạn. Vui lòng thử lại từ bước yêu cầu OTP.';
        messageType.value = 'danger';
        setTimeout(() => {
            router.push({ name: 'ForgotPassword' });
        }, 3000);
    }
});

function validateForm() {
    let isValid = true;

    errors.newPassword = '';
    errors.confirmPassword = '';
    message.value = '';
    apiGeneralError.value = '';

    if (!newPassword.value) {
        errors.newPassword = 'Mật khẩu mới là bắt buộc.';
        isValid = false;
    } else if (newPassword.value.length < 6) {
        errors.newPassword = 'Mật khẩu phải có ít nhất 6 ký tự.';
        isValid = false;
    }

    if (!confirmPassword.value) {
        errors.confirmPassword = 'Xác nhận mật khẩu mới là bắt buộc.';
        isValid = false;
    } else if (newPassword.value && confirmPassword.value !== newPassword.value) {
        errors.confirmPassword = 'Mật khẩu mới và mật khẩu xác nhận không khớp.';
        isValid = false;
    }
    return isValid;
}

async function handleResetPassword() {
    if (!validateForm()) {
        return;
    }

    isLoading.value = true;


    try {
        const response = await axios.post('https://localhost:7254/api/Auth/resetpassword', {
            email: email.value,
            token: token.value,
            newPassword: newPassword.value,
            confirmPassword: confirmPassword.value
        });

        if (response.status === 200 && response.data) {
            message.value = response.data.message || 'Mật khẩu đã được đặt lại thành công!';
            messageType.value = 'success';
            newPassword.value = '';
            confirmPassword.value = '';
        }
    } catch (error) {
        messageType.value = 'danger';
        if (error.response && error.response.data) {
            const data = error.response.data;
            console.log("API Error Data:", data); g

            let hasFieldErrors = false;
            if (data.errors) {
                if (data.errors.NewPassword && data.errors.NewPassword.length > 0) {
                    errors.newPassword = data.errors.NewPassword[0];
                    hasFieldErrors = true;
                }
                if (data.errors.ConfirmPassword && data.errors.ConfirmPassword.length > 0) {
                    errors.confirmPassword = data.errors.ConfirmPassword[0];
                    hasFieldErrors = true;
                }
            }

            if (data.Message && typeof data.Message === 'string') {
                if (!hasFieldErrors) {
                    message.value = data.Message;
                } else {
                    apiGeneralError.value = data.Message;
                }
            } else if (typeof data === 'string' && !hasFieldErrors) {
                message.value = data;
            } else if (!hasFieldErrors && !message.value) {
                message.value = 'Đã xảy ra lỗi khi đặt lại mật khẩu. Vui lòng thử lại.';
            }

        } else if (error.request) {
            message.value = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.';
        } else {
            message.value = 'Đã có lỗi xảy ra khi gửi yêu cầu.';
        }
        console.error("Reset Password Error:", error);
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

.invalid-feedback {
    display: block;
    /* Đảm bảo thông báo lỗi luôn hiển thị */
}
</style>