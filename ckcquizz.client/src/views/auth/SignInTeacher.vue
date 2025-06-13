<template>
    <div class="wrapper teacher-wrapper">
        <div class="row no-container-effect">
            <div class="col-md-6 side-image teacher-side-image">
                <div class="text">
                    <p>CKC QUIZZ - CỔNG GIẢNG VIÊN</p>
                    <span>Quản lý và tạo bài kiểm tra hiệu quả</span>
                    <span class="copyright-text">Copyright@2025</span>
                </div>
            </div>
            <div class="col-md-6 right">
                <div class="switch-login-type">
                    <RouterLink :to="{ name: 'SignIn' }" class="switch-link" title="Chuyển sang đăng nhập Học sinh">
                        <UserRound :size="18" class="icon-switch" />
                        <span>Học sinh</span>
                    </RouterLink>
                </div>

                <form class="input-box" @submit.prevent="handleLogin">
                    <div class="quiz-title mb-3">
                        <span>CKC <span class="text-teacher-primary">Quizz</span></span>
                    </div>
                    <h5 class="mb-5">ĐĂNG NHẬP GIẢNG VIÊN</h5>
                    <div class="input-field">
                        <input type="text" v-model="email" class="input">
                        <label for="email">Email</label>
                    </div>
                    <div class="input-field">
                        <input type="password" v-model="password" class="input">
                        <label for="password">Password</label>
                    </div>
                    <p v-if="error" style="color: red;">{{ error }}</p>
                    <div class="d-grid gap-2 col-12 mx-auto">
                        <button type="submit" class="submit btn-flex teacher-submit">
                            <LogIn :size="20"></LogIn> ĐĂNG NHẬP
                        </button>
                    </div>
                    <div class="forgetpass">
                        <span>Bạn quên mật khẩu? <RouterLink :to="{ name: 'ForgotPassword' }">Nhấn vào đây</RouterLink>
                        </span>
                    </div>
                </form>
            </div>
        </div>
    </div>
</template>


<script setup>
import { ref } from 'vue'
import { useRouter, RouterLink } from 'vue-router'
import apiClient from '@/services/axiosServer'
import { useAuthStore } from '@/stores/authStore'
import { LogIn, UserRound } from 'lucide-vue-next'

const email = ref('');
const password = ref('');
const error = ref(null);
const router = useRouter();
const authStore = useAuthStore();
const isValidEmail = (email) => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    return emailRegex.test(email);
}

const handleLogin = async () => {
    error.value = null;
    if (!email.value.trim()) {
        error.value = "Vui lòng nhập địa chỉ email."
        return
    }
    if (!isValidEmail(email.value.trim())) {
        error.value = "Địa chỉ email không hợp lệ."
        return
    }
    if (!password.value) {
        error.value = "Vui lòng nhập mật khẩu."
        return
    }

    try {

        const apiUrl = `/Auth/signin`;
        const res = await apiClient.post(apiUrl, {
            email: email.value,
            password: password.value
        });

        if (res.status === 200) {
            const data = res.data;
            if (!data.roles.includes('Teacher') && !data.roles.includes('Admin')) {
                error.value = "Email hoặc mật khẩu không đúng"
                return
            }
            authStore.setUser(data.email, data.roles);
            router.push({ name: "admin-dashboard" });

        }
        else {
            error.value = "Đã có lỗi xảy ra trong quá trình đăng nhập. Vui lòng thử lại.";
        }

    }
    catch (err) {
        if (err.response) {
            const responseData = err.response.data;
            const statusCode = err.response.status;

            if (statusCode === 400 && responseData && responseData.errors) {
                const validationErrors = responseData.errors;
                if (validationErrors.Password && validationErrors.Password.length > 0) {
                    error.value = validationErrors.Password[0];
                } else if (validationErrors.Email && validationErrors.Email.length > 0) {
                    error.value = validationErrors.Email[0];
                } else {
                    const firstErrorKey = Object.keys(validationErrors)[0];
                    if (firstErrorKey && validationErrors[firstErrorKey] && validationErrors[firstErrorKey].length > 0) {
                        error.value = validationErrors[firstErrorKey][0];
                    } else if (responseData.title) {
                        error.value = responseData.title;
                    } else {
                        error.value = "Lỗi xác thực dữ liệu không xác định.";
                    }
                }
            }
            else if (typeof responseData === 'string' && responseData) {
                error.value = responseData;
            }
            else if (responseData && responseData.title) {
                error.value = responseData.title;
            }
            else {
                error.value = 'Đã xảy ra lỗi trong quá trình đăng nhập. Vui lòng thử lại.';
            }
        } else if (err.request) {
            error.value = 'Không nhận được phản hồi từ máy chủ. Vui lòng kiểm tra kết nối mạng.';
        } else {
            error.value = 'Lỗi khi gửi yêu cầu đăng nhập: ' + err.message;
        }
    }
};
</script>
<style scoped>
.wrapper {
    background: #f0f2f5;
    width: 100%;
    height: 100vh;
}

.row.no-container-effect {
    display: flex;
    flex-wrap: wrap;
    width: 100%;
    height: 100%;

    background: #fff;

}

.btn-flex {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    font-weight: 600;
    font-size: 1rem;
}

.side-image {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    background-size: cover;
    background-position: center;
    color: #fff;
    padding: 20px;
}

.teacher-side-image {

    background-image: url("../../assets/images/signin.jpg");
}

.side-image,
.right {
    flex: 1;
    height: 100%;
}

.text {
    font-weight: bold;
    text-align: center;
    background-color: rgba(0, 0, 0, 0.4);
    padding: 20px;
    border-radius: 8px;
}

.text p {
    font-size: 1.8rem;
    margin: 0 0 10px 0;
    white-space: normal;
}

.text span {
    font-size: 1rem;
    display: block;
}

.text span.copyright-text {
    font-size: 0.8rem;
    margin-top: 20px;
    opacity: 0.8;
}

.right {
    display: flex;
    justify-content: center;
    align-items: center;
    position: relative;
    padding: 20px;
    overflow-y: auto;
}

.switch-login-type {
    position: absolute;
    top: 25px;
    right: 25px;
    z-index: 10;
}

.switch-link {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 8px 14px;
    background-color: #e9ecef;
    border: 1px solid #ced4da;
    border-radius: 50px;
    text-decoration: none;
    color: #0056b3;
    font-size: 0.875rem;
    font-weight: 500;
    transition: all 0.2s ease-in-out;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

.switch-link:hover {
    background-color: #dde2e6;
    /* Màu hover */
    color: #003f80;
    border-color: #b1bbc4;
    box-shadow: 0 3px 6px rgba(0, 0, 0, 0.08);
    transform: translateY(-1px);
}


.input-box {
    width: 100%;
    max-width: 380px;
    box-sizing: border-box;
}

.quiz-title {
    display: flex;
    justify-content: center;
    align-items: center;
    font-size: 2rem;
    font-weight: bold;
}

.text-teacher-primary {
    color: #0056b3;
}

.input-box h5 {
    text-align: center;
    color: #333;
    font-weight: 600;
}

.input-field {
    display: flex;
    flex-direction: column;
    position: relative;
    padding: 0 10px 0 10px;
}

.input {
    height: 45px;
    width: 100%;
    background: transparent;
    border: none;
    border-bottom: 1px solid rgba(0, 0, 0, 0.2);
    outline: none;
    margin-bottom: 20px;
    color: #40414a;
    font-size: 1rem;
}

.input-box .input-field label {
    position: absolute;
    top: 10px;
    left: 10px;
    pointer-events: none;
    transition: .5s;
    color: #6c757d;
}

.input-field input:focus~label,
.input-field input:valid~label {
    top: -10px;
    font-size: 13px;
    color: #0056b3;
}

.input-field .input:focus,
.input-field .input:valid {
    border-bottom: 1px solid #0056b3;
}

.submit {
    border: none;
    outline: none;
    height: 45px;
    border-radius: 5px;
    transition: .4s;
    color: #fff;
    text-transform: uppercase;
}

.teacher-submit {
    background: #007bff;
}

.teacher-submit:hover {
    background: #0056b3;
}


.forgetpass {
    text-align: center;
    font-size: small;
    margin-top: 25px;
}

.forgetpass span a {
    text-decoration: none;
    font-weight: 700;
    color: #007bff;
    transition: .5s;
}

.forgetpass span a:hover {
    text-decoration: underline;
    color: #0056b3;
}

@media only screen and (max-width: 768px) {

    .row.no-container-effect {
        flex-direction: column;
        height: auto;
        min-height: 100vh;
    }

    .side-image {

        height: 250px;
        min-height: auto;
        flex: none;
    }

    .right {
        flex: 1;
        height: auto;
        padding: 30px 15px;
    }

    .text p {
        font-size: 1.5rem;
    }

    .text span {
        font-size: 0.9rem;
    }

    .input-box {
        max-width: 100%;
    }

    .switch-login-type {
        top: 15px;
        right: 15px;
    }

    .switch-link {
        padding: 6px 10px;
        font-size: 0.8rem;
    }
}
</style>