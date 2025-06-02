<template>

  <!-- Sidebar -->
  <nav class="sidebar">
    <div class="sidebar-header">
      <span>CKC Quizz</span>
      <a href="#" class="text-white"><i class="bi bi-moon-stars-fill"></i></a> <!-- Example Icon -->
    </div>
    <ul class="nav flex-column">
      <li class="nav-item">
        
          <router-link :to="{ name: 'admin-dashboard' }" class="nav-link" active-class="active">
            <i class="bi bi-speedometer2"></i> <!-- Placeholder Icon -->
            <span>Tổng quan</span>
            </router-link>
        
      </li>
    </ul>

    <div class="nav-section-title">QUẢN LÝ</div>
    <ul class="nav flex-column">
      <li class="nav-item">
        <router-link :to="{ name: 'admin-coursegroup' }" class="nav-link" active-class="active">
          <i class="bi bi-collection"></i> <!-- Placeholder Icon -->
          <span>Nhóm học phần</span>
          </router-link>
</li>
      <li class="nav-item">
        <router-link :to="{ name: 'admin-question' }" class="nav-link" active-class="active">
          <i class="bi bi-patch-question"></i> <!-- Placeholder Icon -->
          <span>Câu hỏi</span>
          </router-link>
</li>
      <li class="nav-item">
        <router-link :to="{ name: 'admin-users' }" class="nav-link" active-class="active">
          <i class="bi bi-people"></i> <!-- Placeholder Icon -->
          <span>Người dùng</span>
          </router-link>
</li>
      <li class="nav-item">
        <router-link :to="{ name: 'admin-subject' }" class="nav-link" active-class="active">
          <i class="bi bi-book"></i> <!-- Placeholder Icon -->
          <span>Môn học</span>
          </router-link>
</li>
      <li class="nav-item">
        <router-link :to="{ name: 'admin-assignment' }" class="nav-link" active-class="active">
          <i class="bi bi-person-workspace"></i> <!-- Placeholder Icon -->
          <span>Phân công</span>
          </router-link>
</li>
      <li class="nav-item">
        <router-link :to="{ name: 'admin-test' }" class="nav-link" active-class="active">
          <i class="bi bi-file-earmark-text"></i> <!-- Placeholder Icon -->
          <span>Đề kiểm tra</span>
          </router-link>
</li>
      <li class="nav-item">
        <router-link :to="{ name: 'admin-notification' }" class="nav-link" active-class="active">
          <i class="bi bi-chat-left-text"></i> <!-- Placeholder Icon -->
          <span>Thông báo</span>
          </router-link>
</li>
    </ul>

    <div class="nav-section-title mt-auto">QUẢN TRỊ</div> <!-- mt-auto to push to bottom if space allows -->
    <ul class="nav flex-column mb-3">
      <!-- mb-3 for some spacing before end of sidebar -->
      <li class="nav-item">
        <a class="nav-link" href="#">
          <i class="bi bi-people-fill"></i> <!-- Placeholder Icon -->
          Nhóm quyền
        </a>
      </li>
    </ul>
  </nav>
</template>
<style scoped>

  .sidebar {
    width: 260px; /* Adjust width as needed */
    background-color: #003366; /* Dark blue sidebar background */
    color: #ffffff;
    padding-top: 1rem;
    display: flex;
    flex-direction: column;
  }

  .sidebar-header {
    padding: 0.5rem 1.5rem;
    font-size: 1.25rem;
    font-weight: bold;
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 1px solid #004488; /* Slightly lighter border */
  }

  .sidebar .nav-link {
    color: #adb5bd; /* Lighter text color for links */
    padding: 0.75rem 1.5rem;
    display: flex;
    align-items: center;
  }

    .sidebar .nav-link .bi {
      margin-right: 0.75rem;
      font-size: 1.1rem;
    }

    .sidebar .nav-link:hover {
      color: #ffffff;
      background-color: #004080; /* Darker blue on hover */
    }

    .sidebar .nav-link.active {
      color: #ffffff;
      background-color: #00509e; /* Active link background */
      font-weight: 500;
    }

</style>
