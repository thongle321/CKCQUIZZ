<template>
  <div class="admin-layout-wrapper">
    <DashboardSidebar />
    <div class="main-content-container">
      <Dashboardheader />
      <main class="page-content-area">
        <router-view></router-view>
      </main>
      <DashboardFooter/>
    </div>
  </div>
</template>
<style scoped>


    .admin-layout-wrapper {
      display: flex;
      min-height: 100vh; 
    }

    .main-content-container {
      flex-grow: 1; 
      display: flex;
      flex-direction: column; 
      background-color: #ffffff; 
    }

    .page-content-area {
      padding: 1.5rem; 
      flex-grow: 1; 
      background-color: rgba(255, 255, 255, 0.8);
      backdrop-filter: saturate(200%) blur(30px);
      box-shadow: 0 2px 12px 0 rgba(0,0,0,.05);

    }

 
</style>
<script>
  import Dashboardheader from '../components/Dashboard/DashboardHeader.vue';
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