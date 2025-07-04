<template>
        <footer id="page-footer" class="footer-static bg-body-extra-light text-center">
            <div class="content py-4">
                <!-- Footer Navigation -->
                <div class="row items-push fs-sm border-bottom pt-4">
                    <div class="col-6 col-md-4">
                        <h3 class="fw-semibold">Thông tin</h3>
                        <ul class="list list-simple-mini">
                            <li>
                                <router-link class="fw-semibold text-dark" :to="{ name: 'PrivacyPolicy' }">
                                    Chính sách bảo mật
                                </router-link>
                            </li>
                            <li>
                                <router-link class="fw-semibold text-dark" :to="{ name: 'TermsOfUse' }">
                                    Điều khoản sử dụng
                                </router-link>
                            </li>
                            <li>
                                <router-link class="fw-semibold text-dark" :to="{ name: 'GuidePage' }">
                                    Hướng dẫn
                                </router-link>
                            </li>
                        </ul>
                    </div>
                    <div class="col-md-4">
                        <h3 class="fw-semibold">Địa chỉ</h3>
                        <div class="fs-sm push">
                            Trường Cao Đẳng Kỹ Thuật Cao Thắng<br>
                            65 Huỳnh Thúc Kháng, P.Bến Nghé, Q.1, Tp.HCM.<br>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <h3 class="fw-semibold">Kết nối</h3>
                        <ul class="list list-simple-mini">
                            <li>
                                <a href="#" style="margin-right: 10px;">
                                    <FacebookIcon style="fill: black"size="20"></FacebookIcon>
                                </a>
                                <a>
                                    <XIcon size="20"></XIcon>
                                </a>
                            </li>
                        </ul>
                    </div>
                </div>

                <div class="row fs-md pt-4">
                    <div class="col-md-6 offset-md-3 text-center">
                        <p class="d-flex justify-content-center align-items-center gap-1"><Copyright stroke-width="1.5" size="16"/> Copyright 2025 CKCQuiz</p>
                    </div>
                </div>
            </div>
        </footer>
</template>
<script setup>
import {FacebookIcon, XIcon} from 'vue3-simple-icons'
import { Copyright } from 'lucide-vue-next';

</script>