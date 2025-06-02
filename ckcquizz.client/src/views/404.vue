<template>
  <section class="d-flex align-items-center min-vh-100 py-5 page-not-found">
    <div class="container py-5">
      <div class="row align-items-center">
        <div class="col-md-6 order-md-2 lottie-column">
          <div class="lc-block">
            <Vue3Lottie :animationData="NotFoundAnimationData" :height="400" :width="400" :loop="true" :autoPlay="true">

            </Vue3Lottie>

          </div>
        </div>
        <div class="col-md-6 text-center text-md-start content-column">
          <div class="lc-block mb-3">
            <div>
              <h1 class="display-1 fw-bold text-muted">{{ errorCode }}</h1>
            </div>
          </div>
          <div class="lc-block mb-5">
            <div>
              <p class="rfs-11 fw-light">{{ message }}</p>
            </div>
          </div>
          <div class="lc-block">
            <router-link :to="{ name: 'LandingPage' }" class="btn btn-lg btn-primary" role="button">
              {{ buttonText }}
            </router-link>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
import { ref } from 'vue';
import { Vue3Lottie } from 'vue3-lottie';

import NotFoundAnimationData from '../assets/json/404.json'; 

const errorCode = ref('Error 404');
const message = ref('Trang bạn đang tìm kiếm đã bị di chuyển, xóa bỏ hoặc có thể chưa từng tồn tại.');
const buttonText = ref('Quay lại trang chủ');

</script>
