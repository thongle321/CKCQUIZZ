import * as signalR from "@microsoft/signalr";
import { useAuthStore } from '@/stores/authStore';

const connection = new signalR.HubConnectionBuilder()
    .withUrl("https://34.31.64.0:7254/examHub", {
        accessTokenFactory: () => {
            const authStore = useAuthStore();
            const token = authStore.accessToken || "";
            console.log("SignalR ExamHub accessTokenFactory: ", token ? "Token present" : "No token");
            return token;
        }
    })
    .withAutomaticReconnect()
    .build();

async function startConnection() {
    try {
        await connection.start();
        console.log("SignalR Connected successfully.");
        console.log("SignalR connection state:", connection.state);
    } catch (err) {
        console.error("SignalR Connection Error: ", err);
        setTimeout(startConnection, 5000); 
    }
}

connection.onclose(async () => {
    await startConnection();
});


export {connection as default, startConnection};