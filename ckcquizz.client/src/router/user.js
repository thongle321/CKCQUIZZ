const user = [
    {
        path: "/",
        component: () => import("@/layouts/home.vue"),
        children: [
            {
                path: "",
                name: "LandingPage",
                component: () => import("@/views/LandingPage.vue")
            }

        ],

    },
    {
        path: "/auth/signin",
        name: "SignIn",
        component: () => import("@/views/auth/SignIn.vue")
    }
]


export default user;