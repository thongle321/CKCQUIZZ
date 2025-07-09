import * as signalR from "@microsoft/signalr";
import { useAuthStore } from '@/stores/authStore';

const connection = new signalR.HubConnectionBuilder()
    .withUrl("https://34.31.64.0:7254/notificationHub", {
        accessTokenFactory: () => {
            const authStore = useAuthStore();

            const token = authStore.accessToken || "";
            console.log("SignalR accessTokenFactory: ", token ? "Token present" : "No token");
            return token;
        }
    })
    .withAutomaticReconnect()
    .build();

async function startConnection() {
    try {
        await connection.start();
        console.log("SignalR Connected.");
    } catch (err) {
        console.error("SignalR Connection Error: ", err);
        setTimeout(startConnection, 5000);
    }
}

connection.onclose(async () => {
    await startConnection();
});

export {connection as default, startConnection};