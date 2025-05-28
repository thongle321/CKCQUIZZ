<template>

  <!-- Content Header -->
  <header class="content-header">
    <div class="btn-group me-2">
      <button type="button" class="btn btn-light"><i class="bi bi-three-dots-vertical"></i></button> <!-- Placeholder Icon -->
      <button type="button" class="btn btn-light"><i class="bi bi-tools"></i></button> <!-- Placeholder Icon -->
    </div>
    <div class="dropdown">
      <button class="btn btn-light dropdown-toggle" type="button" id="userDropdown" data-bs-toggle="dropdown" aria-expanded="false">
        <i class="bi bi-person-circle"></i> <!-- Placeholder Icon -->
      </button>
      <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="userDropdown">
        <li><a class="dropdown-item" href="#">Profile</a></li>
        <li><a class="dropdown-item" href="#">Settings</a></li>
        <li><hr class="dropdown-divider"></li>
        <li><a class="dropdown-item" href="#">Logout</a></li>
      </ul>
    </div>
  </header>

</template>
<style scoped>

  .content-header {
    padding: 1rem 1.5rem;
    background-color: #ffffff;
    border-bottom: 1px solid #dee2e6; /* Light border */
    display: flex;
    justify-content: right;
    align-items: flex-end;
    margin-right:50px;
  }

    .content-header .btn-group .btn, .content-header .dropdown .btn {
      color: #6c757d; /* Icon button color */
    }

      .content-header .btn-group .btn:hover, .content-header .dropdown .btn:hover {
        color: #000000;
      }

</style>
