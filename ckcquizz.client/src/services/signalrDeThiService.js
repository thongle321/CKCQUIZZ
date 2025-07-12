import * as signalR from "@microsoft/signalr";
import { useAuthStore } from '@/stores/authStore';

const connection = new signalR.HubConnectionBuilder()
    .withUrl("https://34.31.64.0:7254/examHub", {
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

    if (connection.state === signalR.HubConnectionState.Disconnected) {
        try {
            await connection.start();
        } catch (err) {
            if (authStore.accessToken) {
                setTimeout(startConnection, 5000);
            } else {
            }
        }
    } else {
    }
}

connection.onclose(async (error) => {
    const authStore = useAuthStore();
    if (authStore.accessToken) {
        await startConnection();
    }
});


export {connection as default, startConnection};