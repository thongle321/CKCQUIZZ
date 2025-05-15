<template>
    <LandingPageHeader />
    <router-view></router-view>
    <LandingPageFooter />
</template>
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