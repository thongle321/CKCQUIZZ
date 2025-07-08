using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Viewmodels.Auth;
using Microsoft.AspNetCore.Identity;
using System.Threading.Tasks;

namespace CKCQUIZZ.Server.Services
{
    public class UserProfileService(UserManager<NguoiDung> _userManager) : IUserProfileService
    {
        public async Task<CurrentUserProfileDTO?> GetUserProfileAsync(string userId)
        {
            var user = await _userManager.FindByIdAsync(userId);
            if (user is null)
            {
                return null;
            }
            var roles = await _userManager.GetRolesAsync(user);
            if (roles is null)
            {
                return null;
            }

            return new CurrentUserProfileDTO
            {
                Mssv = user.Id,
                Avatar = user.Avatar!,
                Fullname = user.Hoten,
                Email = user.Email!,
                Phonenumber = user.PhoneNumber!,
                Gender = user.Gioitinh ?? false,
                Dob = user.Ngaysinh,
                Roles = roles
            };
        }

        public async Task<IdentityResult> UpdateUserProfileAsync(string userId, UpdateUserProfileDTO model)
        {
            var user = await _userManager.FindByIdAsync(userId);
            if (user == null)
            {
                return IdentityResult.Failed(new IdentityError { Description = "Không tìm thấy người dùng" });
            }

            user.Hoten = model.Fullname;
            user.Email = model.Email;
            user.PhoneNumber = model.PhoneNumber;
            user.Gioitinh = model.Gender;
            user.Ngaysinh = model.Dob;
            user.PhoneNumber = model.PhoneNumber;
            user.Avatar = model.Avatar;

            var result = await _userManager.UpdateAsync(user);
            return result;
        }
    }
}