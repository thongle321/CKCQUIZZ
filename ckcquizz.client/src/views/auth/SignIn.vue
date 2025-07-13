<template>
    <div class="container-fluid">
        <div class="row">
            <div class="col-md-6 side-image">
                <div class="text">
                    <p>CHÀO MỪNG ĐẾN VỚI CKC QUIZZ</p>
                    <span class="copyright-text">Copyright@2025</span>
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
                        <span>CKC <span class="text-primary-student">Quizz</span></span>
                    </div>
                    <h5 class="mb-5">ĐĂNG NHẬP SINH VIÊN</h5>

                    <a-form-item name="email">
                        <a-input class="mb-1" v-model:value="formState.email" placeholder="Email" size="large">
                            <template #addonBefore>
                                <Mail size="20" />
                            </template>
                        </a-input>
                    </a-form-item>

                    <a-form-item name="password">
                        <a-input-password class="mb-1" v-model:value="formState.password" placeholder="Mật khẩu"
                            size="large">
                            <template #addonBefore>
                                <LockKeyholeIcon size="20" />
                            </template>
                        </a-input-password>
                    </a-form-item>

                    <a-form-item name="rememberMe">
                        <a-checkbox v-model:checked="formState.rememberMe">Ghi nhớ đăng nhập</a-checkbox>
                    </a-form-item>

                    <a-form-item v-if="error" class="mt-2">
                        <a-alert :message="error" type="error" show-icon />
                    </a-form-item>

                    <div class="d-grid gap-2 col-12 mx-auto mt-4">
                        <a-button class="my-2" type="primary" block size="large" html-type="submit"
                            :loading="isLoading">
                            <template #icon>
                                <LogIn style="margin-right: 6px;" />
                            </template>
                            ĐĂNG NHẬP
                        </a-button>
                        <a-button type="default" block size="large" @click="handleLoginWithGoogle">
                            <template #icon>
                                <svg xmlns="http://www.w3.org/2000/svg"
                                    style="vertical-align: middle; margin-right: 6px;" width="20" height="20"
                                    viewBox="0 0 48 48">
                                    <path fill="#FFC107"
                                        d="M43.611,20.083H42V20H24v8h11.303c-1.649,4.657-6.08,8-11.303,8c-6.627,0-12-5.373-12-12c0-6.627,5.373-12,12-12c3.059,0,5.842,1.154,7.961,3.039l5.657-5.657C34.046,6.053,29.268,4,24,4C12.955,4,4,12.955,4,24c0,11.045,8.955,20,20,20c11.045,0,20-8.955,20-20C44,22.659,43.862,21.35,43.611,20.083z">
                                    </path>
                                    <path fill="#FF3D00"
                                        d="M6.306,14.691l6.571,4.819C14.655,15.108,18.961,12,24,12c3.059,0,5.842,1.154,7.961,3.039l5.657-5.657C34.046,6.053,29.268,4,24,4C16.318,4,9.656,8.337,6.306,14.691z">
                                    </path>
                                    <path fill="#4CAF50"
                                        d="M24,44c5.166,0,9.86-1.977,13.409-5.192l-6.19-5.238C29.211,35.091,26.715,36,24,36c-5.202,0-9.619-3.317-11.283-7.946l-6.522,5.025C9.505,39.556,16.227,44,24,44z">
                                    </path>
                                    <path fill="#1976D2"
                                        d="M43.611,20.083H42V20H24v8h11.303c-0.792,2.237-2.231,4.166-4.087,5.571c0.001-0.001,0.002-0.001,0.003-0.002l6.19,5.238C36.971,39.205,44,34,44,24C44,22.659,43.862,21.35,43.611,20.083z">
                                    </path>
                                </svg>
                            </template>
                            ĐĂNG NHẬP VỚI GOOGLE
                        </a-button>
                    </div>

                    <div class="forgetpass">
                        <span>Bạn quên mật khẩu? <RouterLink class="text-primary" :to="{ name: 'ForgotPassword' }">Nhấn
                                vào đây</RouterLink>
                        </span>
                    </div>
                </a-form>
            </div>
        </div>
    </div>
</template>

<script setup>
import { reactive, ref, onMounted } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { useAuthStore } from '@/stores/authStore';
import apiClient from '@/services/axiosServer';
import { LogIn, UsersRound, Mail, LockKeyholeIcon } from 'lucide-vue-next';

const router = useRouter();
const route = useRoute();
const authStore = useAuthStore();

const formState = reactive({
    email: '',
    password: '',
    rememberMe: false,
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
            password: formState.password,
        });
        const data = res.data;
        if (!data.roles.includes('Student')) {
            error.value = "Email hoặc mật khẩu không chính xác.";
            return;
        }
        authStore.setUser(data, formState.rememberMe);
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
    const backendUrl = 'https://ckcquizz.ddnsking.com:7254/api';
    const frontendReturnUrl = 'https://ckcquizz.ddnsking.com:50263';
    sessionStorage.setItem('googleAuthRememberMe', formState.rememberMe.toString());
    window.location.href = `${backendUrl}/Auth/google?returnUrl=${frontendReturnUrl}`;
};

onMounted(() => {
    const errorFromGoogle = route.query.error;
    if (errorFromGoogle) {
        const decodedError = decodeURIComponent(errorFromGoogle);
        if (decodedError === 'Chỉ được phép đăng nhập bằng email @caothang.edu.vn') {
            error.value = 'Chỉ được phép đăng nhập bằng email @caothang.edu.vn';
        } else if (decodedError === 'google_failed' || decodedError === 'google_auth_failed') {
            error.value = 'Đăng nhập bằng Google thất bại. Vui lòng thử lại.';
        } else {
            error.value = 'Đăng nhập thất bại. Vui lòng thử lại.';
        }
        router.replace({ name: 'SignIn' });
    }
});

</script>

<style scoped>
.container-fluid {
    width: 100%;
    height: 100vh;
    margin: 0;
    padding: 0;

}

.side-image {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    background-image: url("../../assets/images/signin.jpg");
    background-size: cover;
    background-position: center;
    color: #fff;
}

.row {
    display: flex;
    flex-wrap: wrap;
    width: 100%;
    height: 100vh;
    background: #fff;
    margin: 0;
}

.side-image,
.right {
    flex: 1;
    height: 100vh;
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
}

.input-box {
    width: 100%;
    max-width: 380px;
    /* Tăng chiều rộng một chút cho cân đối */
    box-sizing: border-box;
}

.quiz-title {
    display: flex;
    justify-content: center;
    align-items: center;
    font-size: 2rem;
    font-weight: bold;
}

.text-primary-student {
    color: #0056b3;
}

.input-box h5 {
    text-align: center;
    font-weight: 600;
}

.forgetpass {
    text-align: center;
    font-size: small;
    margin-top: 25px;
}

.forgetpass span a {
    text-decoration: none;
    font-weight: 700;
    transition: .5s;
}

.forgetpass span a:hover {
    text-decoration: underline;
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
    color: #0056b3;
    /* Màu của giảng viên cho nhất quán */
    font-size: 0.875rem;
    font-weight: 500;
    transition: all 0.2s ease-in-out;
}

.switch-link:hover {
    background-color: #e9ecef;
}

@media only screen and (max-width: 768px) {
    .side-image {
        display: none;
    }

    .right {
        flex: 100%;
    }

    .row {
        height: auto;
        min-height: 100vh;
    }

    .input-box {
        width: 90%;
    }
}
</style>