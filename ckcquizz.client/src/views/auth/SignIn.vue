<template>
    <div class="wrapper">
        <div class="row">
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
                <form class="input-box" @submit.prevent="handleLogin">
                    <div class="quiz-title mb-3">
                        <span>CKC <span class="text-primary">Quizz</span>
                        </span>
                    </div>
                    <h5 class="mb-5">ĐĂNG NHẬP</h5>
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
                        <button type="submit" class="submit btn-flex">
                            <LogIn></LogIn> ĐĂNG NHẬP
                        </button>
                        <button type="button" class="google btn-flex" @click="handleLoginWithGoogle">
                            <Mail></Mail> ĐĂNG NHẬP VỚI GOOGLE
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
import apiClient from '@/services/axiosServer'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/authStore'
import { LogIn, Mail, UsersRound } from 'lucide-vue-next'

const email = ref('')
const password = ref('')
const error = ref(null)
const router = useRouter();
const authStore = useAuthStore()

const isValidEmail = (email) => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    return emailRegex.test(email);
}
const handleLogin = async () => {

    error.value = null
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
        const res = await apiClient.post("api/Auth/signin", {
            email: email.value.trim(),
            password: password.value
        })

        if (res.status === 200) {
            const data = res.data;
            if (!data.roles.includes('Student')) {
                error.value = "Email hoặc mật khẩu không đúng."
                return

            }
            authStore.setUser(data.email, data.roles)
            router.push({ name: "LandingPage" });
        }
        else {
            error.value = "Đã có lỗi xảy ra trong quá trình đăng nhập. Vui lòng thử lại.";
        }
    }
   catch (err) {
        if (err.response) {
            const { data, status } = err.response;

            if ((status === 400 || status === 403) && typeof data === 'string') {
                error.value = data;
            } else {
                error.value = 'Đăng nhập thất bại. Vui lòng thử lại sau.';
            }
        } else {
            error.value = 'Đã có lỗi xảy ra khi gửi yêu cầu.';
            console.error('Login Error:', err.message);
        }
    }
}
const handleLoginWithGoogle = async () => {
    window.location.href = " https://localhost:7254/api/Auth/google?returnUrl=https://localhost:50263"
}

</script>
<style scoped>
.wrapper {
    background: #ececec;
    width: 100%;
    height: 100vh;
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

i {
    font-weight: 400;
    font-size: 15px;
}

.right {
    display: flex;
    justify-content: center;
    align-items: center;
    position: relative;
}

.input-box header {
    font-weight: 700;
    text-align: center;
    margin-bottom: 45px;
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
}

.input-box .input-field label {
    position: absolute;
    top: 10px;
    left: 10px;
    pointer-events: none;
    transition: .5s;
}

.input-field input:focus~label {
    top: -10px;
    font-size: 13px;
}

.input-field input:valid~label {
    top: -10px;
    font-size: 13px;
    color: #5d5076;
}

.input-box {
    width: 330px;
    box-sizing: border-box;
}

.input-box header {
    font-weight: 700;
    text-align: center;
    margin-bottom: 45px;
}

.quiz-title {
    display: flex;
    justify-content: center;
    align-items: center;
    font-size: 2rem;
    font-weight: bold;
}

.input-box h5 {
    text-align: center;
}

.input-field .input:focus,
.input-field .input:valid {
    border-bottom: 1px solid #743ae1;
}

.submit {
    border: none;
    outline: none;
    height: 45px;
    background: #ececec;
    border-radius: 5px;
    transition: .4s;
}

.submit:hover {
    background: rgba(37, 95, 156, 0.937);
    color: #fff;
}

.google {
    border: none;
    outline: none;
    height: 45px;
    background: #8DBCC7;
    border-radius: 5px;
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
        border-radius: 10px 10px 0 0;
    }

    img {
        width: 35px;
        position: absolute;
        top: 20px;
        left: 47%;
    }

    .text {
        position: absolute;
        top: 70%;
        text-align: center;
    }

    .text p,
    i {
        font-size: 16px;
    }

    .row {
        max-width: 420px;
        width: 100%;
    }
}
</style>