import { createRouter, createWebHistory } from "vue-router";
import admin from './admin.js'
import user from './user.js'
import Error from '../views/404.vue'
import { useAuthStore } from '@/stores/authStore.js'
const routes = [...admin, ...user,
{
  path: '/:pathMatch(.*)*',
  name: 'Error',
  component: Error,
  meta: {
    title: '404 - Không tìm thấy'
  }
}
];


const router = createRouter({
  history: createWebHistory(),
  routes
})
router.beforeEach((to) => {
  const { title } = to.meta;
  const defaultTitle = 'Default Title';

  document.title = title || defaultTitle

})
// Thiết lập Navigation Guard
router.beforeEach((to, from, next) => {
  const authStore = useAuthStore()
  const requiresAuth = to.matched.some(record => record.meta.requiresAuth)

  if (requiresAuth && !authStore.isAuthenticated) {
    // Nếu chưa xác thực, chuyển hướng về trang chủ hoặc trang đăng nhập
    next({ name: 'LandingPage' })
  } else {
    // Nếu đã xác thực hoặc tuyến đường không yêu cầu xác thực, tiếp tục
    next()
  }
})
export default router
