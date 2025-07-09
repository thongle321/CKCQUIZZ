using Microsoft.AspNetCore.SignalR;
using Microsoft.AspNetCore.Authorization;
using CKCQUIZZ.Server.Viewmodels.DeThi;
using CKCQUIZZ.Server.Interfaces;
using System.Security.Claims;

namespace CKCQUIZZ.Server.Hubs
{
    public interface IExamHubClient
    {
        Task ReceiveExam(ExamForClassDto exam);
        Task ReceiveExamStatusUpdate(int made, string newStatus);
        Task ReceiveTabSwitchWarning(ChuyenTabResponseDto response);
        Task ReceiveAutoSubmitCommand(string message);
    }

    [Authorize]
    public sealed class ExamHub(IDeThiService deThiService) : Hub<IExamHubClient>
    {
        private readonly IDeThiService _deThiService = deThiService;

        public async Task ReportTabSwitch(ChuyenTabCanhBaotDto report)
        {
            var studentId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(studentId))
            {
                await Clients.Caller.ReceiveTabSwitchWarning(new ChuyenTabResponseDto
                {
                    SoLanHienTai = 0,
                    NopBai = false,
                    ThongBao = "Không thể xác thực người dùng."
                });
                return;
            }

            try
            {
                var response = await _deThiService.TangSoLanChuyenTab(report.KetQuaId, studentId);

                if (response.NopBai)
                {
                    await Clients.Caller.ReceiveAutoSubmitCommand(response.ThongBao);
                }
                else
                {
                    await Clients.Caller.ReceiveTabSwitchWarning(response);
                }
            }
            catch (Exception ex)
            {
                await Clients.Caller.ReceiveTabSwitchWarning(new ChuyenTabResponseDto
                {
                    SoLanHienTai = 0,
                    NopBai = false,
                    ThongBao = $"Lỗi khi xử lý chuyển tab: {ex.Message}"
                });
            }
        }
    }
}