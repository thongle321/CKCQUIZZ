<template>
    <div class="wrapper">
        <div class="row">
            <div class="col-md-6 side-image">
                <div class="text">
                    <p>Chào mừng đến với CKC QUIZZ</p>
                    <span>Copyright@2025</span>
                </div>

            </div>
            <div class="col-md-6 right">

                <form class="input-box" @submit.prevent="handleLogin">
                    <div class="quiz-title mb-2">
                        <span>CKC <span class="text-primary">Quizz</span>
                        </span>
                    </div>
                    <h5>ĐĂNG NHẬP</h5>
                    <div class="form-group">
                        <label for="email" class="form-label">Email</label>
                        <input type="text" v-model="email" class="form-control" placeholder="Nhập email của bạn"
                            required>
                    </div>
                    <div class="form-group mb-3">
                        <label for="password" class="form-label">Password</label>
                        <input type="password" v-model="password" class="form-control"
                            placeholder="Nhập mật khẩu của bạn" required>
                    </div>
                    <p v-if="error" style="color: red;">{{ error }}</p>
                    <div class="d-grid gap-2 col-12 mx-auto">
                        <button type="submit" class="btn btn-primary mb-2">
                            <font-awesome-icon :icon="['fas', 'right-to-bracket']" />
                            ĐĂNG NHẬP
                        </button>
                        <button type="button" class="btn btn-secondary">
                            <font-awesome-icon :icon="['fab', 'google']" />
                            ĐĂNG NHẬp VỚI GOOGLE
                        </button>
                    </div>
                    <div class="forgetpass">
                        <RouterLink :to="{ name: 'ForgotPassword' }" class="btn btn-sm btn-outline-primary">
                            <font-awesome-icon :icon="['fas', 'lock']" /> Quên mật khẩu
                        </RouterLink>
                    </div>
                </form>
            </div>
        </div>
    </div>
</template>
<script setup>
import { ref } from 'vue'
import apiClient from '@/services/axiosServer';
import { useRouter } from 'vue-router';
const email = ref('')
const password = ref('')
const error = ref(null)
const router = useRouter();
const handleLogin = async () => {
    error.value = null
    try {
        const res = await apiClient.post('/Auth/signin', {
            email: email.value,
            password: password.value
        })

        if (res.status === 200) {
            const data = res.data;

            console.log('Đăng nhập thành công!');
            router.push('/')
        }
    }
    catch (err) {
        console.error('Lỗi đăng nhập:', err);

        if (err.res) {

            const responseData = err.res.data;

            if (responseData && responseData.errors && responseData.errors.length > 0) {
                error.value = responseData.errors[0];
            } else {
                error.value = `Lỗi: ${err.res.status} - ${err.res.statusText}`;
            }

        } else if (err.request) {
            error.value = 'Không nhận được phản hồi từ server. Vui lòng kiểm tra kết nối hoặc thử lại sau.';
        }
        else {
            error.value = 'Đã xảy ra lỗi trong quá trình yêu cầu đăng nhập.';
        }
        console.error(err);
    }
}

</script>
<style scoped>
html,
body {
    margin: 0;
    padding: 0;
    height: 100%;
}

.wrapper {
    background: #ececec;
    width: 100%;
    height: 100vh;
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
}

.text p {
    font-size: 2rem;
    margin: 0;
    white-space: nowrap;
}

.text span {
    font-size: 1rem;
    margin-top: 10px;
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

.input-box {
    width: 330px;
    box-sizing: border-box;
}

.quiz-title {
    display: flex;
    justify-content: center;
    align-items: center;
    font-size: 2rem;
}

.input-box h5 {
    text-align: center;
}

g {
    width: 35px;
    position: absolute;
    top: 30px;
    left: 30px;
}

.forgetpass {
    text-align: center;
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
