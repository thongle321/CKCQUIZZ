import { createRouter, createWebHistory } from "vue-router";
import admin from './admin.js'
import user from './user.js'
import Error from '../views/404.vue'
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

export default router
