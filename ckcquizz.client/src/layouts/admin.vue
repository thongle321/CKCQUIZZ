<template>
  <div class="admin-layout-wrapper">
    <DashboardSidebar />
    <div class="main-content-container">
      <Dashboardheader />
      <main class="page-content-area">
        <!-- Nội dung từ router-view sẽ hiển thị ở đây -->
        <!-- Nếu hình ảnh lớn là cố định cho layout admin này, bạn có thể đặt nó ở đây
             hoặc nó sẽ là một phần của component được tải bởi router-view -->
        <router-view></router-view>
      </main>
      <!-- Bạn có thể thêm một component Footer ở đây nếu cần -->
      <!-- <DashboardFooter /> -->
      <DashboardFooter/>
    </div>
  </div>
</template>
<style scoped>


    .admin-layout-wrapper {
      display: flex;
      min-height: 100vh; /* Đảm bảo layout chiếm toàn bộ chiều cao màn hình */
    }

    .main-content-container {
      flex-grow: 1; /* Làm cho container này chiếm hết phần không gian còn lại */
      display: flex;
      flex-direction: column; /* Sắp xếp header, page-content, footer (nếu có) theo chiều dọc */
      background-color: #ffffff; /* Màu nền cho khu vực nội dung chính */
    }

    .page-content-area {
      padding: 1.5rem; /* Giống như .main-area trong HTML gốc */
      flex-grow: 1; /* Cho phép khu vực này mở rộng, đẩy footer xuống (nếu có) */
      background-color: #f0f2f5; /* Màu nền cho khu vực chứa hình ảnh/nội dung route */
      /* Nếu bạn có một container cố định cho hình ảnh như .main-image-container trong HTML gốc,
       bạn có thể thêm style cho nó ở đây hoặc trong component con (nếu hình ảnh là một phần của component con) */
    }

 
</style>
<script>
  import Dashboardheader from '../components/Dashboard/Dashboardheader.vue';
  import DashboardSidebar from '../components/Dashboard/DashboardSidebar.vue';
  import DashboardFooter from '../components/Dashboard/DashboardFooter.vue';
  export default {
    components: {
      Dashboardheader,
      DashboardSidebar,
      DashboardFooter
    }
  }
</script>
