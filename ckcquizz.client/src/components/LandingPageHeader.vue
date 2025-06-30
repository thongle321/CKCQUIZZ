<template>
  <div class="sidebar-dark side-scroll page-header-fixed page-header-glass main-content-boxed remember-theme">
    <!-- Header -->
    <header id="page-header">
      <div class="content-header">
        <div class="space-x-1 d-flex align-items-center space-x-2 animated zoomInRight">
          <GraduationCap color="#0D6EFD" />
          <RouterLink :to="{ name: 'LandingPage' }" class="link-fx fw-bold">
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
              <template v-if="!authStore.isAuthenticated">
                <RouterLink :to="{ name: 'SignIn' }" class="btn btn-hero btn-primary rounded-pill">
                  <LogIn :size="20"></LogIn> Đăng nhập
                </RouterLink>
              </template>
              <template v-else>
                <RouterLink :to="{ name: authStore.userRoles.includes('Student') ? 'student-class-list' : 'admin-home' }"
                  class="btn btn-hero btn-primary rounded-pill">
                  Dashboard
                </RouterLink>
              </template>
            </li>
          </ul>
        </div>
      </div>
    </header>
  </div>
</template>
<script setup>
import { RouterLink } from 'vue-router';
import { LogIn, GraduationCap } from 'lucide-vue-next';
import { useAuthStore } from '@/stores/authStore'
const authStore = useAuthStore();
</script>