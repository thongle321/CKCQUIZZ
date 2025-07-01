import { createApp } from 'vue'
import Antd from 'ant-design-vue'
import { message } from 'ant-design-vue'
import router from './router/index.js'
import App from './App.vue'
import { createPinia } from 'pinia'
import vue3lottie from 'vue3-lottie'
import { startConnection as startThongBaoConnection } from './services/signalrThongBaoService.js';
import { startConnection as startDeThiConnection } from './services/signalrDeThiService.js';

import 'bootstrap/dist/css/bootstrap.min.css';
import 'bootstrap/dist/js/bootstrap.bundle.min.js';

const app = createApp(App);

const pinia = createPinia()

app.use(Antd);

app.use(router);

app.use(vue3lottie)

app.use(pinia);

app.mount('#app');

startThongBaoConnection();
startDeThiConnection();

app.config.globalProperties.$message = message;
