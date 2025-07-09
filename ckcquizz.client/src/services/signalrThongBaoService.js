import * as signalR from "@microsoft/signalr";
import { useAuthStore } from '@/stores/authStore';

const connection = new signalR.HubConnectionBuilder()
    .withUrl("https://34.31.64.0:7254/notificationHub", {
        accessTokenFactory: () => {
            const authStore = useAuthStore();

            const token = authStore.accessToken || "";
            return token;
        }
    })
    .withAutomaticReconnect()
    .build();

async function startConnection() {
    const authStore = useAuthStore();
    if (!authStore.accessToken) {
        return;
    }
    try {
        await connection.start();

    } catch (err) {
        if (authStore.accessToken) {
            setTimeout(startConnection, 5000);
        } else {
        }
    }
}

connection.onclose(async () => {
    const authStore = useAuthStore();
    if (authStore.accessToken) {
        await startConnection();
    } else {
    }
});

export {connection as default, startConnection};