<template>
    <main id="main-container" class="">
        <!-- Hero -->
        <div id="hero-1" class="hero hero-bubbles hero-lg overflow-hidden">
            <div class="hero-inner">
                <span class="hero-bubble hero-bubble-lg bg-warning" style="top: 20%; left: 10%;"></span>
                <span class="hero-bubble bg-success" style="top: 20%; left: 80%;"></span>
                <span class="hero-bubble hero-bubble-sm bg-xwork" style="top: 40%; left: 25%;"></span>
                <span class="hero-bubble hero-bubble-lg bg-xmodern" style="top: 10%; left: 20%;"></span>
                <span class="hero-bubble hero-bubble-lg bg-xeco" style="top: 30%; left: 90%;"></span>
                <span class="hero-bubble hero-bubble-lg bg-danger" style="top: 35%; left: 20%;"></span>
                <span class="hero-bubble hero-bubble-lg bg-warning" style="top: 60%; left: 35%;"></span>
                <span class="hero-bubble bg-info" style="top: 60%; left: 80%;"></span>
                <span class="hero-bubble hero-bubble-lg bg-xdream" style="top: 75%; left: 70%;"></span>
                <span class="hero-bubble hero-bubble-lg bg-xpro" style="top: 75%; left: 10%;"></span>
                <span class="hero-bubble bg-xplay" style="top: 90%; left: 90%;"></span>
                <div class="position-relative d-flex align-items-center justify-content-center">
                    <div class="content content-full">
                        <div class="row g-6 w-100 py-7 overflow-hidden mx-4">
                            <div
                                class="col-md-6 order-md-last py-4 d-md-flex align-items-md-center justify-content-md-end">
                                <img class="img-fluid animated flipInX" src="../assets/images/landingpage.png"
                                    alt="Hero Promo">
                            </div>
                            <div class="col-md-6 py-4 d-flex align-items-center" data-class="animated fadeInLeft">
                                <div class="text-center text-md-start">
                                    <h1 class="fw-bold fs-2 mb-3" style="color: #eae9da;">
                                        Hệ thống thi và tạo đề thi trắc nghiệm online tốt nhất.
                                    </h1>
                                    <p class="fw-medium mb-4">
                                        Hỗ trợ bạn các chức năng tốt nhất để dễ dàng tạo và quản lý ngân hàng câu
                                        hỏi,
                                        đề thi trắc nghiệm, bài giảng.
                                        Tổ chức các kỳ thi online, giao bài tập về nhà trên mọi nền tảng Web,
                                        Mobile...
                                    </p>
                                    <RouterLink :to="{ name: 'SignIn' }" class="btn btn-alt-primary py-2 px-3 m-1">
                                        <ArrowRight class="me-1"></ArrowRight>Tham gia ngay
                                    </RouterLink>
                                    <a class="btn btn-alt-secondary py-2 px-3 m-1 btn--scroll-to" data-target="#section--1">
                                        <ArrowDown class="me-1"></ArrowDown>
                                        Tìm hiểu thêm
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="position-relative" id="section--1">
            <div class="position-absolute top-0 end-0 bottom-0 start-0 skew-y-1"></div>
            <div class="position-relative">
                <div class="content content-full my-5">
                    <div class="row g-4 justify-content-center text-center">

                        <!-- Box 1 -->
                        <div class="col-12 col-md-6 col-xl-4" data-class="animated flipInX">
                            <div class="box-feature w-100 py-4 px-2 rounded-4"
                                style="background-color: rgba(85, 107, 47, 0.8)">
                                <div class="d-inline-block shadow-sm rounded p-1 mb-4">
                                    <div class="d-inline-block bg-xinspire-light rounded p-4">
                                        <Boxes class="text-xinspire-dark" size="48"></Boxes>
                                    </div>
                                </div>
                                <h3 class="h4 fw-bold mb-1">Lưu trạng thái khi gặp sự cố</h3>
                                <p class="fw-medium mb-0">
                                    Tính năng Lưu đáp án khi gặp sự cố giúp người dùng bảo vệ kết quả bài kiểm tra
                                    trắc nghiệm một cách dễ dàng và tiện lợi.
                                </p>
                            </div>
                        </div>

                        <!-- Box 2 -->
                        <div class="col-12 col-md-6 col-xl-4" data-class="animated flipInX">
                            <div class="box-feature w-100 py-4 px-2 rounded-4"
                                style="background-color: rgba(85, 107, 47, 0.8);">
                                <div class="d-inline-block shadow-sm rounded p-1 mb-4">
                                    <div class="d-inline-block bg-xplay-lighter rounded p-4">
                                        <CodeXml class="text-xplay" size="48"></CodeXml>
                                    </div>
                                </div>
                                <h3 class="h4 fw-bold mb-1">Tạo đề thi tự động</h3>
                                <p class="fw-medium mb-0">
                                    Giúp nâng cao chính xác và hiệu quả của quá trình tạo đề thi, đồng thời tiết kiệm
                                    thời gian và công sức cho người dùng.
                                </p>
                            </div>
                        </div>

                        <!-- Box 3 -->
                        <div class="col-12 col-md-6 col-xl-4" data-class="animated flipInX">
                            <div class="box-feature w-100 py-4 px-2 rounded-4"
                                style="background-color: rgba(85, 107, 47, 0.8)">
                                <div class="d-inline-block shadow-sm rounded p-1 mb-4">
                                    <div class="d-inline-block bg-xpro-lighter rounded p-4">
                                        <Rocket class="text-xpro" size="48" stroke-width="3"></Rocket>
                                    </div>
                                </div>
                                <h3 class="h4 fw-bold mb-1">Phân loại câu hỏi</h3>
                                <p class="fw-medium mb-0">
                                    Đưa ra các câu hỏi phù hợp với nhu cầu của người dùng, giúp tạo ra bài kiểm tra
                                    trắc nghiệm chất lượng và hiệu quả.
                                </p>
                            </div>
                        </div>

                    </div>
                </div>
            </div>
        </div>

        <!-- END Section 1 -->

        <!-- Section 2 -->
        <div class="" id="section--2">
            <div class="content content-full">
                <div class="row">
                    <div class="order-md-1 col-md-6 d-flex align-items-center justify-content-center">
                        <img src="../assets/images/landingpage_2.png" alt="" class="feature__img "
                            data-class="animated fadeInRight">
                    </div>
                    <div class="order-md-0 col-md-6 d-flex align-items-center">
                        <div>
                            <h3 class="h3 mb-4 fw-bolder" data-class="animated fadeInUp" data-offset="-200"
                                style="color: #5A827E">
                                Dễ dàng tạo bài thi online
                            </h3>
                            <p class="mb-4 fw-bolder" data-class="animated fadeInUp" data-offset="-200"
                                style="color: #5A827E">Hệ thống dễ dàng tạo đề
                                thi với nhiều tuỳ chọn, giúp giảng viên
                                tạo
                                đề thi nhanh chóng</p>
                            <ul class="mb-4 m-0 list-unstyled" style="color: #5A827E">
                                <li class="list-landing" data-class="animated fadeInUp" data-offset="-200"
                                    data-timeout="200">
                                    <CircleCheck size="20" class="me-1"></CircleCheck>
                                    Tạo bài
                                    kiểm tra với nhiều dạng câu hỏi
                                </li>
                                <li class="list-landing" data-class="animated fadeInUp" data-offset="-200"
                                    data-timeout="400">
                                    <CircleCheck size="20" class="me-1"></CircleCheck>
                                    Câu hỏi
                                    chọn 1 kết quả
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>

            <div class="content content-full">
                <div class="row">
                    <div class="order-md-0 col-md-6 d-flex align-items-center justify-content-center">
                        <img src="../assets/images/landingpage_3.png" alt="" class="feature__img "
                            data-class="animated fadeInLeft">
                    </div>
                    <div class="order-md-1 col-md-6 d-flex align-items-center">
                        <div>
                            <h3 class="h3 mb-4 fw-bolder " data-class="animated fadeInUp" data-offset="-200"
                                style="color: #5A827E">
                                Lên trước lịch làm bài hoặc giới hạn thời gian làm bài thi
                            </h3>
                            <p class="fw-bolder" data-class="animated fadeInUp" data-offset="-200"
                                style="color: #5A827E">
                                Bạn có thể cài đặt thời gian để học sinh chỉ làm bài trong khung thời gian qui
                                định:
                            </p>
                            <ul class="mb-4 m-0 list-unstyled" style="color: #5A827E">
                                <li class="list-landing " data-class="animated fadeInUp" data-offset="-200"
                                    data-timeout="200">
                                    <CircleCheck size="20" class="me-1"></CircleCheck> Qui định
                                    thời gian cho bài làm
                                </li>
                                <li class="list-landing " data-class="animated fadeInUp" data-offset="-200"
                                    data-timeout="400">
                                    <CircleCheck size="20" class="me-1"></CircleCheck> Qui định
                                    thời gian có thể bắt đầu làm bài
                                </li>
                                <li class="list-landing " data-class="animated fadeInUp" data-offset="-200"
                                    data-timeout="600">
                                    <CircleCheck size="20" class="me-1"></CircleCheck> Qui định
                                    thời gian kết thúc hiệu lực làm bài
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>

            <div class="content content-full">
                <div class="row">
                    <div class="order-md-1 col-md-6 d-flex align-items-center justify-content-center">
                        <img src="../assets/images/landingpage_4.png" alt="" class="feature__img "
                            data-class="animated fadeInRight">
                    </div>
                    <div class="order-md-0 col-md-6 d-flex align-items-center">
                        <div>
                            <h3 class="h3 mb-4 fw-bolder " data-class="animated fadeInUp" data-offset="-200"
                                style="color: #5A827E">
                                Học sinh làm bài trực tuyến trên web hoặc ứng dụng
                            </h3>
                            <p class="mb-2 fw-bolder" data-class="animated fadeInUp" data-offset="-200"
                                style="color: #5A827E">Hệ thống tạo đề thi trắc
                                nghiệm của chúng tôi cho phép học sinh
                                làm bài
                                kiểm tra trực tuyến dễ dàng.</p>
                            <ul class="mb-4 m-0 list-unstyled" style="color: #5A827E">
                                <li class="list-landing" data-class="animated fadeInUp" data-offset="-200"
                                    data-timeout="200">
                                    <CircleCheck size="20" class="me-1"></CircleCheck> Bảo mật
                                    thông tin
                                </li>
                                <li class="list-landing " data-class="animated fadeInUp" data-offset="-200"
                                    data-timeout="400">
                                    <CircleCheck size="20" class="me-1"></CircleCheck> Giao diện
                                    làm bài kiểm tra trực quan và dễ tương tác
                                </li>
                                <li class="list-landing " data-class="animated fadeInUp" data-offset="-200"
                                    data-timeout="600">
                                    <CircleCheck size="20" class="me-1"></CircleCheck> Giao diện
                                    tuỳ biến theo kích thước màn hình
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="" id="developer">
            <div class="content content-full">
                <div class="pt-7 pb-5">
                    <div class="position-relative">
                        <h2 class="fw-bold mb-2 text-center " data-class="animated fadeInDown" data-offset="-200">
                            <span class="text-primary">Đội ngũ phát triển</span>
                        </h2>
                    </div>
                    <div class="row">
                        <div class="p-3 col-3" data-class="animated flipInX">
                            <a href="https://github.com/thongle321"
                                class="block block-rounded bg-gd-primary text-center">
                                <div class="block-content block-content-full bg-gd-sea">
                                    <img class="img-avatar img-avatar-thumb" src="https://github.com/thongle321.png"
                                        alt="">
                                </div>
                                <div class="block-content block-content-full bg-black-10">
                                    <p class="fw-semibold text-white mb-0">Lê Nguyễn Hoàng Thông</p>
                                    <p class="fs-sm text-white-75 mb-0">
                                        0306221377
                                    </p>
                                </div>
                            </a>
                        </div>
                        <div class="p-3 col-3" data-class="animated flipInX">
                            <a href="https://github.com/thongNatsumi"
                                class="block block-rounded bg-gd-primary text-center">
                                <div class="block-content block-content-full bg-gd-sea">
                                    <img class="img-avatar img-avatar-thumb" src="https://github.com/thongNatsumi.png"
                                        alt="">
                                </div>
                                <div class="block-content block-content-full bg-black-10">
                                    <p class="fw-semibold text-white mb-0">Nguyễn Ngọc Thông</p>
                                    <p class="fs-sm text-white-75 mb-0">
                                        0306221378
                                    </p>
                                </div>
                            </a>
                        </div>
                        <div class="p-3 col-3" data-class="animated flipInX">
                            <a href="https://github.com/dxhoangsteve"
                                class="block block-rounded bg-gd-primary text-center">
                                <div class="block-content block-content-full bg-gd-sea">
                                    <img class="img-avatar img-avatar-thumb" src="https://github.com/dxhoangsteve.png"
                                        alt="">
                                </div>
                                <div class="block-content block-content-full bg-black-10">
                                    <p class="fw-semibold text-white mb-0">Đinh Xuân Hoàng</p>
                                    <p class="fs-sm text-white-75 mb-0">
                                        0306221022
                                    </p>
                                </div>
                            </a>
                        </div>
                        <div class="p-3 col-3" data-class="animated flipInX">
                            <a href="https://github.com/minhhieu0420"
                                class="block block-rounded bg-gd-primary text-center">
                                <div class="block-content block-content-full bg-gd-sea">
                                    <img class="img-avatar img-avatar-thumb" src="https://github.com/minhhieu0420.png"
                                        alt="">
                                </div>
                                <div class="block-content block-content-full bg-black-10">
                                    <p class="fw-semibold text-white mb-0">Hoàng Minh Hiếu</p>
                                    <p class="fs-sm text-white-75 mb-0">
                                        0306221020
                                    </p>
                                </div>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>
</template>
<style scoped>
#developer {
    background-color: #E1EACD;

}

#section--2 {
    background-color: rgba(231, 242, 228, 0.4);

}

#section--1 {
    background-color: rgba(240, 236, 201, 0.4);
}

#hero-1 {
    background-color: #44838F;
}

h1,
h2,
h3,
p,
a {
    color: #eae9da
}
</style>
<script setup>
import { onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useAuthStore } from '@/stores/authStore';
import apiClient from '@/services/axiosServer';
const route = useRoute();
const router = useRouter();
const authStore = useAuthStore();
import { ArrowRight, ArrowDown, Boxes, CodeXml, Rocket, CircleCheck } from 'lucide-vue-next';

onMounted(async () => {
    const accessToken = route.query.accessToken;
    const refreshToken = route.query.refreshToken;
    if (accessToken && refreshToken) {

        const rememberMe = sessionStorage.getItem('googleAuthRememberMe') === 'true';
        const storage = rememberMe ? localStorage : sessionStorage;


        storage.setItem('accessToken', accessToken);
        storage.setItem('refreshToken', refreshToken);
        storage.setItem('rememberMe', rememberMe.toString());
        sessionStorage.removeItem('googleAuthRememberMe');

        router.replace({ path: route.path, query: {} });

        try {
            const response = await apiClient.get('/Auth/current-user-profile');
            const userProfile = response.data; 

            const userData = {
                id: userProfile.mssv,
                email: userProfile.email,
                fullname: userProfile.fullname, 
                roles: userProfile.roles,
                token: { 
                    accessToken: accessToken,
                    refreshToken: refreshToken
                }
            };

            authStore.setUser(userData, rememberMe);


        } catch (error) {
            authStore.logout();
            router.push({ name: 'SignIn' });
        }
    }
    document.querySelectorAll('.btn--scroll-to').forEach(button => {
        button.addEventListener('click', function(e) {
            e.preventDefault();
            const targetId = this.dataset.target;
            if (targetId) {
                const targetElement = document.querySelector(targetId);
                if (targetElement) {
                    targetElement.scrollIntoView({ behavior: 'smooth' });
                }
            }
        });
    });
});
</script>