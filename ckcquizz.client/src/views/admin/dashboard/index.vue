<template>
  <main class="main-area">
    <div>
      <img src="../../../assets/images/nhatruyenthong.png" alt="dashboard img"
        class="main-image">
    </div>
  </main>
</template>
<style scoped>
body,
html {
  height: 100%;
  margin: 0;
  background-color: #f8f9fa;

}

.wrapper {
  display: flex;
  min-height: 100vh;
}



.nav-section-title {
  padding: 1rem 1.5rem 0.5rem;
  font-size: 0.8rem;
  color: #8697a7;
  text-transform: uppercase;
  font-weight: bold;
}



.main-image {
  width: 100%;
  height: auto;
  max-height: 70vh;
  object-fit: cover;
  border-radius: 0.25rem;
}
</style>
<script setup>
  import { useAuthStore } from '@/stores/authStore'
  const authStore = useAuthStore()

</script>

