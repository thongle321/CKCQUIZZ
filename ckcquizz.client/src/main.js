import { createApp } from 'vue'
import Antd from 'ant-design-vue'
import { message } from 'ant-design-vue'
import router from './router/index.js'
import App from './App.vue'
import '@/assets/css/dashmix.css';
import '@/assets/css/custom.css';
import 'ant-design-vue/dist/reset.css';
import 'bootstrap/dist/css/bootstrap.min.css'
import 'bootstrap/dist/css/bootstrap-grid.min.css'

import { library } from '@fortawesome/fontawesome-svg-core'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { fas } from '@fortawesome/free-solid-svg-icons'
import { fab } from '@fortawesome/free-brands-svg-icons'
import { far } from '@fortawesome/free-regular-svg-icons'

library.add(fas,fab,far);

const app = createApp(App);

app.component('font-awesome-icon', FontAwesomeIcon);

app.use(Antd);

app.use(router);

app.mount('#app');

app.config.globalProperties.$message = message;
