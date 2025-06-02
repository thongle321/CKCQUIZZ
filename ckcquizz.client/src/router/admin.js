const admin = [
    {
        path: "/admin",
        component: () => import("@/layouts/admin.vue"),
        children: [
            {
                path: "dashboard",
                name: "admin-dashboard",
                component: () => import("@/views/admin/dashboard/index.vue"),
                meta: {
                    title: "DashBoard",
                },
            },
            {
                path: "question",
                name: "admin-question",
                component: () => import("@/views/admin/question/index.vue"),
                meta: {
                    title: "Question",
                }
            },
            {
                path: "coursegroup",
                name: "admin-coursegroup",
                component: () => import("@/views/admin/coursegroup/index.vue"),
                meta: {
                    title: "CourseGroup",
                }
            },
            {
                path: "users",
                name: "admin-users",
                component: () => import("@/views/admin/users/index.vue"),
                meta: {
                    title: "Users",
                }
            },
            {
                path: "subject",
                name: "admin-subject",
                component: () => import("@/views/admin/subject/index.vue"),
                meta: {
                    title: "Subject",
                }
            },
            {
                path: "assignment",
                name: "admin-assignment",
                component: () => import("@/views/admin/assignment/index.vue"),
                meta: {
                    title: "Assignment",
                }
            },
            {
                path: "test",
                name: "admin-test",
                component: () => import("@/views/admin/test/index.vue"),
                meta: {
                    title: "Test",
                }
            },
            {
                path: "notification",
                name: "admin-notification",
                component: () => import("@/views/admin/notification/index.vue"),
                meta: {
                    title: "Notification",
                }
            }


        ]
    }
]


export default admin;
