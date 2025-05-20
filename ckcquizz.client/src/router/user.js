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
        meta: {
            title: 'Trang chủ',
        },

    },
  {
    path: "/auth",
    children: [
      {
        path: "signin",
        name: "SignIn",
        component: () => import("@/views/auth/SignIn.vue"),
        meta: {
          title: "Đăng nhập",
        }
      },
      {
        path: "resetpassword",
        name: "ResetPassword",
        component: () => import("@/views/auth/ForgotPassword.vue"),
        meta: {
          title: "Quên mật khẩu",
        }
      },
    ]
        //path: "/auth/signin",
        //name: "SignIn",
        //component: () => import("@/views/auth/SignIn.vue"),
        //meta: {
        //    title: 'Đăng nhập',
        //},
  },
]


export default user;
