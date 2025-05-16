<template>
    <div class="wrapper">
        <div class="row">
            <div class="col-md-6 side-image">
                <div class="text">
                    <p>Chào mừng đến với CKC QUIZ</p>
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
                        <label for="email">Email</label>
                        <input type="text" v-model="email" class="form-control" required>
                    </div>
                    <div class="form-group mb-3">
                        <label for="password">Password</label>
                        <input type="password" v-model="password" class="form-control" required>
                    </div>
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
                        <button class="btn btn-sm btn-outline-primary"><a href="#" class="text-dark"><font-awesome-icon :icon="['fas', 'lock']" /> Quên mật khẩu</a></button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</template>
<script>
import axios from 'axios';
export default {
    data() {
        return {
            email: "",
            password: "",
        };
    },
    methods: {
        async handleLogin() {
            try {
                const res = await axios.post("http://localhost:5100/Auth/signin", {
                    email: this.email,
                    password: this.password
                });

                const { token, email } = res.data;

                localStorage.setItem("authToken", token);

                alert("Đăng nhập thành công!"); 
                this.$router.push("/")
            }
            catch (err) {
                alert("Đăng nhập thất bại!" + (err.response?.data || err.message)); 
            }
        }
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