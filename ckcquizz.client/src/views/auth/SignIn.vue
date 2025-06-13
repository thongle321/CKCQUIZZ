<template>
    <div class="container-fluid">
        <a-row class="row">
            <div class="col-md-6 side-image">
                <div class="text">
                    <p>CHÀO MỪNG ĐẾN VỚI CKC QUIZZ</p>
                    <span>Copyright@2025</span>
                </div>
            </div>

            <div class="col-md-6 right">
                <div class="switch-login-type">
                    <RouterLink :to="{ name: 'SignInTeacher' }" class="switch-link"
                        title="Chuyển sang đăng nhập Giảng viên">
                        <UsersRound :size="18" class="icon-switch" />
                        <span>Giảng viên</span>
                    </RouterLink>
                </div>

                <a-form class="input-box" :model="formState" :rules="formRules" @finish="handleLogin">
                    <div class="quiz-title mb-3">
                        <span>CKC <span class="text-primary">Quizz</span></span>
                    </div>
                    <h5 class="mb-5">ĐĂNG NHẬP</h5>

                    <a-form-item name="email">
                        <div class="input-field">
                            <input type="text" v-model="formState.email" class="input" id="email" required>
                            <label for="email">Email</label>
                        </div>
                    </a-form-item>

                    <a-form-item name="password">
                        <div class="input-field my-3">
                            <input type="password" v-model="formState.password" class="input" id="password" required>
                            <label for="password">Password</label>
                        </div>
                    </a-form-item>

                    <a-form-item v-if="error">
                        <a-alert :message="error" type="error" show-icon />
                    </a-form-item>

                    <div class="d-grid gap-2 col-12 mx-auto">
                        <a-button type="primary" block size="large" html-type="submit" :loading="isLoading">
                            <template #icon>
                                <LogIn style="margin-right: 5px" />
                            </template>
                            ĐĂNG NHẬP
                        </a-button>
                        <a-button type="default" block size="large" @click="handleLoginWithGoogle">
                            <template #icon>
                                <Mail style="margin-right: 5px" />
                            </template>
                            ĐĂNG NHẬP VỚI GOOGLE
                        </a-button>
                    </div>

                    <div class="forgetpass">
                        <span>Bạn quên mật khẩu? <RouterLink class="text-primary" :to="{ name: 'ForgotPassword' }">Nhấn vào đây</RouterLink>
                        </span>
                    </div>
                </a-form>
            </div>
        </a-row>
    </div>
</template>

<script setup>
import { h, reactive, ref } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '@/stores/authStore';
import apiClient from '@/services/axiosServer';
import { LogIn, Mail, UsersRound } from 'lucide-vue-next';

const router = useRouter();
const authStore = useAuthStore();

const formState = reactive({
    email: '',
    password: '',
});

const error = ref(null);
const isLoading = ref(false);

const formRules = {
    email: [
        { required: true, message: 'Vui lòng nhập địa chỉ email!' },
        { type: 'email', message: 'Địa chỉ email không hợp lệ!', trigger: 'blur' },
    ],
    password: [
        { required: true, message: 'Vui lòng nhập mật khẩu!' },
    ],
};

const handleLogin = async () => {
    error.value = null;
    isLoading.value = true;

    try {
        const res = await apiClient.post("/Auth/signin", {
            email: formState.email.trim(),
            password: formState.password
        });

        const data = res.data;
        if (!data.roles.includes('Student')) {
            error.value = "Tài khoản này không có quyền truy cập.";
            return;
        }

        authStore.setUser(data.email, data.roles);
        router.push({ name: "LandingPage" });

    } catch (err) {
        if (err.response?.data) {
            error.value = typeof err.response.data === 'string'
                ? err.response.data
                : 'Email hoặc mật khẩu không chính xác.';
        } else {
            error.value = 'Không thể kết nối đến máy chủ. Vui lòng thử lại sau.';
        }
    } finally {
        isLoading.value = false;
    }
};

const handleLoginWithGoogle = () => {
    window.location.href = "https://localhost:7254/api/Auth/google?returnUrl=https://localhost:50263";
};
</script>

<style scoped>
/* Giữ nguyên toàn bộ style của bạn vì nó đã rất tốt */
.btn-flex {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    font-weight: 600;
    font-size: 1rem;
    height: 45px;
    /* Thêm chiều cao để đồng bộ */
    border: none;
    border-radius: 5px;
}

.side-image {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    background-image: url("../../assets/images/signin.jpg");
    background-size: cover;
    background-position: center;
    height: 100vh;
    color: #fff;
}

.side-image,
.right {
    flex: 1;
    height: 100vh;
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
    background-color: #f8f9fa;
    border: 1px solid #dee2e6;
    border-radius: 50px;
    text-decoration: none;
    color: #495057;
    font-size: 0.875rem;
    font-weight: 500;
    transition: all 0.2s ease-in-out;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

.switch-link:hover {
    background-color: #e9ecef;
    color: #743ae1;
    border-color: #c5b3e0;
    box-shadow: 0 3px 6px rgba(0, 0, 0, 0.08);
    transform: translateY(-1px);
}

.row {
    display: flex;
    flex-wrap: wrap;
    width: 100%;
    height: 100%;
    background: #fff;
}

.text {
    font-weight: bold;
    text-align: center;
    background-color: rgba(0, 0, 0, 0.4);
    padding: 20px;
    border-radius: 8px;
}

.text p {
    font-size: 2rem;
    margin: 0;
    white-space: nowrap;
}

.text span {
    font-size: 0.8rem;
    margin-top: 20px;
    opacity: 0.8;
}

.right {
    display: flex;
    justify-content: center;
    align-items: center;
    position: relative;
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
    color: #40414a;
    font-size: 1rem;
}

.input-box .input-field label {
    position: absolute;
    top: 10px;
    left: 10px;
    pointer-events: none;
    transition: .5s;
}

.input-field .input:focus~label,
.input-field .input:valid~label {
    top: -10px;
    font-size: 13px;
}

.input-box {
    width: 330px;
    box-sizing: border-box;
}

.quiz-title {
    display: flex;
    justify-content: center;
    align-items: center;
    font-size: 2rem;
    font-weight: bold;
}

.text-primary {
    color: #1677ff;
}

.input-box h5 {
    text-align: center;
}

.input-field .input:focus,
.input-field .input:valid {
    border-bottom: 1px solid #743ae1;
}

.submit {
    background: #ececec;
    transition: .4s;
}

.submit:hover {
    background: rgba(37, 95, 156, 0.937);
    color: #fff;
}

.google {
    background: #8DBCC7;
    transition: .4s;
}

.google:hover {
    background: rgba(37, 95, 156, 0.937);
    color: #fff;
}

.forgetpass {
    text-align: center;
    font-size: small;
    margin-top: 25px;
}

span a {
    text-decoration: none;
    font-weight: 700;
    color: #000;
    transition: .5s;
}

span a:hover {
    text-decoration: underline;
    color: #000;
}

@media only screen and (max-width: 768px) {
    .side-image {
        display: none;
    }

    .right {
        flex: 100%;
    }

    .input-box {
        width: 90%;
    }
}
</style>