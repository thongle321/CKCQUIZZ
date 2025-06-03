<script setup>
import { RouterLink } from 'vue-router';
</script>

<template>
  <div class="sidebar-dark side-scroll page-header-fixed page-header-glass main-content-boxed remember-theme">
    <!-- Header -->
    <header id="page-header">
      <div class="content-header">
        <div class="space-x-1 d-flex align-items-center space-x-2 animated zoomInRight">
          <RouterLink :to="{ name: 'LandingPage'}" class="link-fx fw-bold">
            <span class="fs-4 text-dual">CKC </span><span class="fs-4 text-primary">Quizz</span>
          </RouterLink>
        </div>
        <div class="space-x-1">
          <ul class="nav-main nav-main-horizontal nav-main-hover nav">
            <li class="nav-main-item">
              <!-- <a class="btn btn-hero rounded-pill btn-primary px-3" data-toggle="class-toggle"
                data-target="#dark-mode-toggler" data-class="far fa" onclick="Dashmix.layout('dark_mode_toggle');"
                href="javascript:void(0)">
                <font-awesome-icon icon="fa fa-moon" id="dark-mode-toggler"></font-awesome-icon>
              </a> -->
            </li>

            <li class="nav-main-item">
              <RouterLink :to="{ name: 'SignIn'}" class="btn btn-hero btn-primary rounded-pill">
                <font-awesome-icon icon="fa fa-right-to-bracket me-2"></font-awesome-icon> Đăng nhập
               </RouterLink>
            </li>
          </ul>
        </div>
      </div>
    </header>
  </div>
</template>
<style scoped>
</style>