<template>
  <!DOCTYPE html>
  <html lang="vi">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SGU Test Dashboard</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons (Optional, or use your preferred icon library) -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.3/font/bootstrap-icons.css" rel="stylesheet">

  </head>
  <body>
  


     

        <!-- Main Area -->
        <main class="main-area">
          <div class="main-image-container">
            <!-- REPLACE THIS SRC with your actual image path -->
            <img src="https://via.placeholder.com/1200x600.png?text=Building+Image+Placeholder" alt="Main building image" class="main-image">
          </div>
        </main>

       
 


  </body>
</html>
</template>
<style scoped>
  body, html {
    height: 100%;
    margin: 0;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif; /* Example font stack */
    background-color: #f8f9fa; /* Light gray background for the page */
  }

  .wrapper {
    display: flex;
    min-height: 100vh;
  }

  

  .nav-section-title {
    padding: 1rem 1.5rem 0.5rem;
    font-size: 0.8rem;
    color: #8697a7; /* Muted color for section titles */
    text-transform: uppercase;
    font-weight: bold;
  }

  
  .main-area {
    padding: 1.5rem;
    flex-grow: 1;
    background-color: #f0f2f5; /* Slightly off-white for the main image area */
  }

  .main-image-container {
    background-color: #ffffff; /* White background behind the image */
    padding: 1rem; /* Optional padding around the image */
    border-radius: 0.25rem;
    box-shadow: 0 0.125rem 0.25rem rgba(0,0,0,.075);
  }

  .main-image {
    width: 100%;
    height: auto; /* Maintain aspect ratio */
    max-height: 70vh; /* Limit image height */
    object-fit: cover; /* Cover the area, might crop */
    border-radius: 0.25rem;
  }


</style>
<script setup>

  // Import Bootstrap JS
  import 'bootstrap/dist/js/bootstrap.bundle.min.js'

</script>
