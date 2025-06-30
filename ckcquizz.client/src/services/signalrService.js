import * as signalR from "@microsoft/signalr";

const connection = new signalR.HubConnectionBuilder()
    .withUrl("https://localhost:7254/notificationHub") // Thay đổi URL này nếu server của bạn chạy trên cổng khác
    .withAutomaticReconnect()
    .build();

async function startConnection() {
    try {
        await connection.start();
        console.log("SignalR Connected.");
    } catch (err) {
        console.error("SignalR Connection Error: ", err);
        setTimeout(startConnection, 5000); // Thử kết nối lại sau 5 giây
    }
}

connection.onclose(async () => {
    await startConnection();
});

export default connection;