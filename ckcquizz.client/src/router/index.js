import { createRouter, createWebHistory } from "vue-router";
import admin from './admin.js';
import user from './user.js';
import student from './student.js';
import Error404 from '../views/errors/404.vue';
import Error403 from '../views/errors/403.vue';
import { useAuthStore } from '@/stores/authStore.js';

const routes = [
  ...admin,
  ...user,
  ...student,
  {
    path: '/403-forbidden',
    name: 'Error403',
    component: Error403,
    meta: {
      title: '403 - Cấm Truy Cập'
    }
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'Error404',
    component: Error404,
    meta: {
      title: '404 - Không Tìm Thấy'
    }
  }
];

const router = createRouter({
  history: createWebHistory(),
  routes
});

router.beforeEach((to, from, next) => {
  document.title = to.meta.title || 'CKC Quizz';

  const authStore = useAuthStore();

  if (to.meta.guest && authStore.isAuthenticated) {
    if (authStore.userRoles.includes('Admin') || authStore.userRoles.includes('Teacher')) {
      return next({ name: 'admin-dashboard' });
    }
    return next({ name: 'student-dashboard' });
  }

  if (to.meta.requiresAuth) {
    if (!authStore.isAuthenticated) {
      return next({
        name: 'SignIn',
        query: { redirect: to.fullPath }
      });
    }

    const requiredRoles = to.meta.allowedRoles;
    if (requiredRoles && requiredRoles.length > 0) {
      const hasPermission = authStore.userRoles.some(role => requiredRoles.includes(role));

      if (!hasPermission) {
        console.warn(`PERMISSION DENIED: Cần [${requiredRoles.join(', ')}], nhưng chỉ có [${authStore.userRoles.join(', ')}]`);
        return next({ name: 'Error403' });
      }
    }
  }

  return next();
});

export default router;