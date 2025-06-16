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
                            Đặt lại mật khẩu cho tài khoản của bạn
                        </a-typography-paragraph>
                    </div>

                    <a-form layout="vertical" :model="formModel" :rules="formRules" @finish="handleResetPassword">
                        <a-form-item label="Email">
                            <a-input v-model:value="formModel.email" disabled size="large" readonly>
                                <template #prefix>
                                    <MailOutlined />
                                </template>
                            </a-input>
                        </a-form-item>

                        <a-form-item has-feedback label="Mật khẩu mới" name="newPassword">
                            <a-input-password v-model:value="formModel.newPassword" placeholder="Nhập mật khẩu mới"
                                size="large" />
                        </a-form-item>

                        <a-form-item has-feedback label="Xác nhận mật khẩu mới" name="confirmPassword">
                            <a-input-password v-model:value="formModel.confirmPassword"
                                placeholder="Nhập lại mật khẩu mới" size="large" />
                        </a-form-item>

                        <a-form-item v-if="message">
                            <a-alert :message="message" :type="messageType" show-icon />
                        </a-form-item>

                        <a-form-item>
                            <a-button class="my-2" type="primary" html-type="submit" :loading="isLoading" block
                                size="large">
                                {{ isLoading ? 'Đang xử lý...' : 'Đặt lại mật khẩu' }}
                            </a-button>
                        </a-form-item>
                    </a-form>

                    <div v-if="messageType === 'success'" class="text-center mt-3">
                        <RouterLink :to="{ name: 'SignIn' }">
                            <a-button type="primary" ghost>Đi đến trang Đăng nhập</a-button>
                        </RouterLink>
                    </div>

                    <a-divider />

                    <div class="text-center">
                        <RouterLink class="text-decoration-none" :to="{ name: 'ForgotPassword' }">
                            Yêu cầu lại OTP?
                        </RouterLink>
                    </div>
                </a-card>
            </a-col>
        </a-row>
    </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import apiClient from '@/services/axiosServer';
import { MailOutlined } from '@ant-design/icons-vue';
import { notification } from 'ant-design-vue';

const router = useRouter();
const route = useRoute();

const formModel = reactive({
    email: '',
    token: '',
    newPassword: '',
    confirmPassword: '',
});

const isLoading = ref(false);
const message = ref('');
const messageType = ref('');

const validateConfirmPassword = (rule, value) => {
    if (value === '') {
        return Promise.reject('Vui lòng xác nhận mật khẩu của bạn!');
    } else if (value !== formModel.newPassword) {
        return Promise.reject("Mật khẩu bạn đã nhập không khớp!");
    } else {
        return Promise.resolve();
    }
};

const formRules = {
    newPassword: [
        { required: true, message: 'Vui lòng nhập mật khẩu mới!' },
        { min: 6, message: 'Mật khẩu phải có ít nhất 6 ký tự!', trigger: 'blur' },
    ],
    confirmPassword: [
        { required: true, validator: validateConfirmPassword, trigger: 'blur' },
    ],
};

onMounted(() => {
    formModel.email = route.query.email || '';
    formModel.token = route.query.token || '';

    if (!formModel.email || !formModel.token) {
        notification.error({
            message: 'Lỗi truy cập',
            description: 'Thông tin đặt lại mật khẩu không hợp lệ. Đang chuyển hướng...',
            duration: 3
        });
        setTimeout(() => {
            router.push({ name: 'ForgotPassword' });
        }, 3000);
    }
});

const handleResetPassword = async () => {
    isLoading.value = true;
    message.value = '';

    try {
        const response = await apiClient.post('/Auth/resetpassword', {
            email: formModel.email,
            token: formModel.token,
            newPassword: formModel.newPassword,
            confirmPassword: formModel.confirmPassword
        });

        message.value = response.data.message || 'Mật khẩu đã được đặt lại thành công!';
        messageType.value = 'success';

    } catch (error) {
        messageType.value = 'error';
        if (error.response?.data) {
            message.value = error.response.data.message || error.response.data.title || "Có lỗi xảy ra, vui lòng thử lại.";
        } else {
            message.value = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.';
        }
    } finally {
        isLoading.value = false;
    }
};
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


</style>