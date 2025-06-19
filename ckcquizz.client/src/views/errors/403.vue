<template>
    <div class="error-body">
        <div class="container py-5">
            <div class="row">
                <div class="col-md-2 text-center icon-container">
                    <TriangleAlert :size="96" class="error-icon" />
                    <p class="status-code">Status Code: 403</p>
                </div>
                <div class="col-md-10 content-container">
                    <h3>Rất tiếc! Bạn không thể truy cập trang này.</h3>
                    <p class="description">
                        Quyền truy cập của bạn đã bị từ chối vì lý do bảo mật hoặc do bạn không có quyền hạn cần thiết.
                        <br />Vui lòng quay lại trang trước để tiếp tục.
                    </p>
                    <button class="btn btn-danger" @click="goBack">Quay Lại</button>
                </div>
            </div>
        </div>

        <div id="footer" class="text-center">
            Copyright © 2025, CKC QUIZZ
        </div>
    </div>
</template>

<script setup>
import { useRouter } from 'vue-router';
import { TriangleAlert } from 'lucide-vue-next';

const router = useRouter();

const goBack = () => {
    router.go(-1);
};
</script>

<style scoped>
.error-body {
    background-color: #343a40;
    color: #fff;
    padding-top: 3rem;
    padding-bottom: 3rem;
    min-height: 100vh;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
}

.container {
    width: 100%;
}

.icon-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
}

.error-icon {
    margin-bottom: 1rem;
}

.status-code {
    font-size: 1rem;
    font-weight: bold;
}

.content-container h3 {
    font-weight: bold;
    margin-bottom: 1rem;
}

.description {
    margin-bottom: 1.5rem;
    line-height: 1.6;
}

.btn-danger {
    color: #fff;
    background-color: #dc3545;
    border-color: #dc3545;
    font-weight: bold;
    padding: 0.5rem 1rem;
    border-radius: 0.25rem;
    cursor: pointer;
    transition: background-color 0.2s ease-in-out;
}

.btn-danger:hover {
    background-color: #c82333;
    border-color: #bd2130;
}

#footer {
    text-align: center;
    position: fixed;
    left: 0;
    right: 0;
    bottom: 10px;
    width: 100%;
    color: rgba(255, 255, 255, 0.7);
    font-size: 0.9rem;
}

@media (max-width: 767px) {
    .row {
        flex-direction: column;
        text-align: center;
    }

    .icon-container {
        margin-bottom: 2rem;
    }

    .content-container {
        text-align: center;
    }

    #footer {
        position: relative;
        margin-top: 2rem;
        padding-bottom: 1rem;
    }
}
</style>