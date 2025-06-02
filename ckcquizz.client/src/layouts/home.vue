<template>
    <LandingPageHeader />
    <router-view></router-view>
    <LandingPageFooter />
</template>
<style>
@import url(../assets/css/custom.css);
@import url(../assets/css/dashmix.css);
@import url(../../node_modules/bootstrap/dist/css/bootstrap.min.css);
</style>
<script>
import LandingPageHeader from '../components/LandingPageHeader.vue';
import LandingPageFooter from '../components/LandingPageFooter.vue';

export default {
    components: {
        LandingPageHeader,
        LandingPageFooter
    }
}
</script>
