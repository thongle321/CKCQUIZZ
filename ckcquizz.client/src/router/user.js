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
        path: "signinteacher",
        name: "SignInTeacher",
        component: () => import("@/views/auth/SignInTeacher.vue"),
        meta: {
          title: "Đăng nhập giáo viên",
        }
      },
      {
        path: "forgotpassword",
        name: "ForgotPassword",
        component: () => import("@/views/auth/ForgotPassword.vue"),
        meta: {
          title: "Quên mật khẩu",
        }
      },
      {
        path: "verifypassword",
        name: "VerifyPassword",
        component: () => import("@/views/auth/VerifyPassword.vue"),
        meta: {
          title: "Xác thực mật khẩu",
        }
      },
      {
        path: "resetpassword",
        name: "ResetPassword",
        component: () => import("@/views/auth/ResetPassword.vue"),
        meta: {
          title: "Thay đổi mật khẩu",
        }
      },
    ]
  },
]


export default user;
