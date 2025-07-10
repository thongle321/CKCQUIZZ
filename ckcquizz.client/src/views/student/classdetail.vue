<template>
    <a-spin class="d-flex justify-content-center align-items-center" :spinning="loading"
        tip="Đang tải chi tiết lớp..." size="large">
        <div v-if="!loading && group" class="container-fluid py-3">
            <a-card class="mb-3 shadow-sm">
                <div class="d-flex justify-content-between align-items-center">
                    <h2 class="h4 mb-0 text-dark">{{ fullClassName }}</h2>
                    <span class="text-danger fw-bold">Sĩ số: {{ group.siso }}</span>
                </div>
            </a-card>

            <a-tabs v-model:activeKey="activeKey">
                <a-tab-pane key="announcements" tab="Thông báo">
                    <a-card :loading="announcementLoading" class="shadow-sm">
                        <a-list item-layout="horizontal" :data-source="announcements"
                            v-if="announcements.length > 0">
                            <template #renderItem="{ item }">
                                <a-list-item class="px-3 py-2 mb-3">
                                    <div class="d-flex justify-content-between align-items-start flex-wrap w-100">
                                        <div class="d-flex align-items-start gap-3">
                                            <a-avatar :size="48" :src="item.avatar">
                                                <template #icon>
                                                    <CircleUserRound />
                                                </template>
                                            </a-avatar>
                                            <div>
                                                <h6 class="fw-bold mb-1 text-dark">{{ item.hoten }}</h6>
                                                <small class="text-secondary">
                                                    Ngày đăng: {{
                                                        new Date(item.thoigiantao).toLocaleDateString('vi-VN') +
                                                        ' ' +
                                                        new Date(item.thoigiantao).toLocaleTimeString('en-US', {
                                                            hour: '2-digit',
                                                            minute: '2-digit',
                                                            hour12: true
                                                        })
                                                    }}
                                                </small>
                                            </div>
                                        </div>

                                        <div class="mt-3 w-100">
                                            <p class="mb-0 text-dark fw-semibold fs-6">{{ item.noidung }}</p>
                                        </div>
                                    </div>
                                </a-list-item>
                            </template>
                        </a-list>
                        <a-empty v-else description="Không có thông báo nào." class="py-5" />
                    </a-card>
                </a-tab-pane>
                <a-tab-pane key="people" tab="Mọi người">
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <a-input v-model:value="searchText" placeholder="Tìm kiếm người dùng..." allow-clear
                                class="w-100">
                                <template #prefix>
                                    <Search size="14" />
                                </template>
                            </a-input>
                        </div>
                    </div>
                    <a-card :loading="peopleLoading" class="shadow-sm">
                        <h5 class="mb-3">Giáo viên</h5>
                        <a-list item-layout="horizontal" :data-source="teachers" v-if="teachers.length > 0">
                            <template #renderItem="{ item }">
                                <a-list-item class="px-3 py-2 mb-3">
                                    <div class="d-flex align-items-center gap-3">
                                        <a-avatar :size="48" :src="item.avatar">
                                            <template #icon>
                                                <CircleUserRound />
                                            </template>
                                        </a-avatar>
                                        <span class="text-primary fw-bold">{{ item.hoten }}</span>
                                    </div>
                                </a-list-item>
                            </template>
                        </a-list>
                        <a-empty v-else description="Không có giáo viên nào." class="py-3" />

                        <h5 class="mb-3 mt-4">Sinh viên</h5>
                        <a-list item-layout="horizontal" :data-source="students" v-if="students.length > 0">
                            <template #renderItem="{ item }">
                                <a-list-item class="px-3 py-2 mb-3">
                                    <div class="d-flex align-items-center gap-3">
                                        <a-avatar :size="48" :src="item.avatar">
                                            <template #icon>
                                                <CircleUserRound />
                                            </template>
                                        </a-avatar>
                                        <span class="text-primary fw-bold">{{ item.hoten }}</span>
                                    </div>
                                </a-list-item>
                            </template>
                        </a-list>
                        <a-empty v-else description="Không có sinh viên ." class="py-3" />
                    </a-card>
                </a-tab-pane>
            </a-tabs>
        </div>

        <a-result v-if="!loading && !group" status="404" title="Không tìm thấy lớp học"
            sub-title="Lớp học bạn đang tìm kiếm không tồn tại hoặc đã bị xóa.">
            <template #extra>
                <router-link to="/student/classes">
                    <a-button type="primary">Quay lại danh sách</a-button>
                </router-link>
            </template>
        </a-result>
    </a-spin>
</template>

<script setup>
import { ref, onMounted, onUnmounted, computed, watch } from 'vue';
import { useRoute } from 'vue-router';
import { message } from 'ant-design-vue';
import { Search, CircleUserRound } from 'lucide-vue-next';
import { Tabs as ATabs, TabPane as ATabPane } from 'ant-design-vue';
import { lopApi } from '@/services/lopService';
import { thongBaoApi } from '@/services/thongBaoService';
import debounce from 'lodash/debounce';
import signalRConnection from '@/services/signalrThongBaoService';

const route = useRoute();
const classId = computed(() => route.params.id);

const group = ref(null)
const loading = ref(true)
const peopleLoading = ref(false)
const students = ref([])
const teachers = ref([])
const searchText = ref('');
const activeKey = ref('people')
const announcements = ref([])
const announcementLoading = ref(true)
const pagination = ref({
current: 1,
pageSize: 10,
total: 0,
});


const subjectName = computed(() => {
if (group.value && group.value.monHocs && group.value.monHocs.length > 0) {
    return group.value.monHocs[0];
}
return 'Chưa có môn học';
});

const fullClassName = computed(() => {
if (!group.value) {
    return 'Thông tin lớp học';
}
const className = group.value.tenlop || '';
const academicYear = group.value.namhoc || '';
const semester = group.value.hocky || '';

return `${subjectName.value} - NH ${academicYear} - HK${semester} - ${className}`;
});

const fetchGroupDetails = async () => {
try {
    const responseData = await lopApi.getById(classId.value);
    if (responseData) {
        group.value = responseData;
    } else {
        message.error('Không tải được thông tin lớp. Vui lòng thử lại.');
    }
} catch (error) {
    message.error('Không tải được thông tin lớp.');
}
};

const fetchPeople = async () => {
peopleLoading.value = true;
try {
    // Fetch students
    const studentParams = {
        searchQuery: searchText.value,
        page: pagination.value.current,
        pageSize: pagination.value.pageSize,
    };
    const studentRes = await lopApi.getStudentsInClass(classId.value, studentParams);
    if (studentRes && studentRes.items) {
        students.value = studentRes.items;
        pagination.value.total = studentRes.totalCount;
    } else {
        message.error('Không tải được danh sách sinh viên. Vui lòng thử lại.');
        students.value = [];
        pagination.value.total = 0;
    }

    const teacherRes = await lopApi.getTeachersInClass(classId.value);
    if (teacherRes) {
        teachers.value = teacherRes;
    } else {
        message.error('Không tải được danh sách giáo viên. Vui lòng thử lại.');
        teachers.value = [];
    }

} catch (error) {
    message.error('Không tải được danh sách người dùng.');
    students.value = [];
    teachers.value = [];
    pagination.value.total = 0;
} finally {
    peopleLoading.value = false;
}
};

watch(searchText, debounce(() => {
pagination.value.current = 1;
fetchPeople();
}, 500));

watch(activeKey, (newKey) => {
if (newKey === 'announcements' && announcements.value.length === 0) {
    fetchAnnouncements();
}
});

const handleTableChange = (pager) => {
pagination.value.current = pager.current;
pagination.value.pageSize = pager.pageSize;
fetchPeople();
};

const fetchAnnouncements = async () => {
announcementLoading.value = true;
try {

    const res = await thongBaoApi.getAnnouncementsByClassId(classId.value);
    console.log(res);
    if (Array.isArray(res) && res.length > 0) {
        announcements.value = res;
    } else {
        announcements.value = [];
    }
} catch (error) {
    message.error('Không tải được danh sách thông báo.');
    console.log(error)
    announcements.value = [];
} finally {
    announcementLoading.value = false;
}
};

const initializeData = async () => {
loading.value = true;
await fetchGroupDetails();
if (activeKey.value === 'people') {
    await fetchPeople();
} else if (activeKey.value === 'announcements') {
    await fetchAnnouncements();
}
loading.value = false;
};

const joinGroup = (id) => {
    if (signalRConnection.state === 'Connected') {
        try {
            signalRConnection.invoke("JoinClassGroup", id.toString());
            console.log(`Joined SignalR group: class-${id}`);
        } catch (err) {
            console.error('Error joining group:', err);
        }
    }
};

const leaveGroup = (id) => {
    if (signalRConnection.state === 'Connected') {
        try {
            signalRConnection.invoke("LeaveClassGroup", id.toString());
            console.log(`Left SignalR group: class-${id}`);
        } catch (err) {
            console.error('Error leaving group:', err);
        }
    }
};



watch(classId, (newId, oldId) => {
    if (newId !== oldId) {
        if (oldId) {
            leaveGroup(oldId);
        }
        joinGroup(newId);
        initializeData();
    }
}, { immediate: true });

onMounted(() => {
    initializeData();

    joinGroup(classId.value);

    signalRConnection.on("ReceiveNotification", (notification) => {
        console.log("Received real-time notification:", notification);

        if (notification.malops && notification.malops.includes(parseInt(classId.value))) {
            announcements.value.unshift(notification);
            message.info(`Thông báo mới: ${notification.noidung}`);
        }
    });
});

onUnmounted(() => {
    if (classId.value) {
        leaveGroup(classId.value);
    }
    
    signalRConnection.off("ReceiveNotification");
});
</script>
<style scoped>
.class-title {
margin: 0;
font-size: 20px;
font-weight: bold;
color: black;
}

.class-size {
font-size: 16px;
color: #e84118;
font-weight: bold;
}
</style>