const admin = [
    {
        path: "/admin",
        component: () => import("@/layouts/admin.vue"),
        children: [
            {
                path: "dashboard",
                name: "admin-dashboard",
                component: () => import("@/views/admin/users/Dashboard.vue"),
                meta: {
                    title: "DashBoard",
                },
            },
            {
                path: "question",
                name: "admin-question",
                component: () => import("@/views/admin/users/QuestionManager.vue"),
                meta: {
                    title: "Question",
                }
            },
            {
                path: "coursegroup",
                name: "admin-coursegroup",
                component: () => import("@/views/admin/users/CourseGroup.vue"),
                meta: {
                    title: "CourseGroup",
                }
            },
            {
                path: "users",
                name: "admin-users",
                component: () => import("@/views/admin/users/Users.vue"),
                meta: {
                    title: "Users",
                }
            },
            {
                path: "subject",
                name: "admin-subject",
                component: () => import("@/views/admin/users/Subject.vue"),
                meta: {
                    title: "Subject",
                }
            },
            {
                path: "assignment",
                name: "admin-assignment",
                component: () => import("@/views/admin/users/Assignment.vue"),
                meta: {
                    title: "Assignment",
                }
            },
            {
                path: "test",
                name: "admin-test",
                component: () => import("@/views/admin/users/Test.vue"),
                meta: {
                    title: "Test",
                }
            },
            {
                path: "notification",
                name: "admin-notification",
                component: () => import("@/views/admin/users/Notification.vue"),
                meta: {
                    title: "Notification",
                }
            }


        ]
    }
]


export default admin;
