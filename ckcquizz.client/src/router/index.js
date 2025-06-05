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
router.beforeEach((to, from, next) => {
  const authStore = useAuthStore()
  const requiresAuth = to.matched.some(record => record.meta.requiresAuth)

  if (requiresAuth && !authStore.isAuthenticated) {
    next({ name: 'LandingPage' })
  }
  const allowedRoles = to.meta.allowedRoles;
  if (allowedRoles && allowedRoles.length > 0) {
    const userRoles = authStore.userRoles || []
    const hasPermission = userRoles.some(role => allowedRoles.includes(role))
    if (!hasPermission) {
      return next({ name: 'admin-dashboard' });
    }
  }
  next()
})
export default router
