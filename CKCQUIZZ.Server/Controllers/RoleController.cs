using CKCQUIZZ.Server.Helpers;
using CKCQUIZZ.Server.Viewmodels;
using CKCQUIZZ.Server.Viewmodels.Role;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
namespace CKCQUIZZ.Server.Controllers;

[ApiController]
[Route("api/[controller]")]
public class RoleController(RoleManager<IdentityRole> _roleManager) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetAll(string keyword, int pageIndex, int pageSize)
    {
        var query = _roleManager.Roles;

        if (!string.IsNullOrEmpty(keyword))
        {
            query = query.Where(x => x.Id.Contains(keyword) || x.Name.Contains(keyword));
        }
        var totalRecords = await query.CountAsync();
        var item = await query.Skip((pageIndex - 1 * pageSize)).Take(pageSize)
        .Select(x => new RoleDTO()
        {
            Id = x.Id,
            Name = x.Name
        })
        .ToListAsync();
        var pagination = new PagedResult<RoleDTO>
        {
            Items = item,
            TotalCount = totalRecords

        };
        return Ok(pagination);
    }
    [HttpPost]
    public async Task<IActionResult> CreateRole(RoleDTO roleDto)
    {
        var role = new IdentityRole()
        {
            Id = roleDto.Id,
            Name = roleDto.Name,
            NormalizedName = roleDto.Name.ToUpper()
        };
        var result = await _roleManager.CreateAsync(role);
        if (result.Succeeded)
        {
            return CreatedAtAction(nameof(GetById), new { id = role.Id }, roleDto);
        }
        else
        {
            return BadRequest(result.Errors);
        }
    }
    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(string id)
    {
        var role = await _roleManager.FindByIdAsync(id);
        if (role is null)
        {
            return NotFound();
        }
        var roleDto = new RoleDTO()
        {
            Id = role.Id,
            Name = role.Name
        };
        return Ok(roleDto);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateRole(string id, [FromBody] RoleDTO roleDto)
    {
        if (id != roleDto.Id)
        {
            return BadRequest();
        }
        var role = await _roleManager.FindByIdAsync(id);
        if (role is null)
        {
            return NotFound();
        }

        role.Name = roleDto.Name;
        role.NormalizedName = roleDto.Name.ToUpper();

        var result = await _roleManager.UpdateAsync(role);
        if (result.Succeeded)
        {
            return NoContent();
        }
        return BadRequest(result.Errors);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteRole(string id)
    {
        var role = await _roleManager.FindByIdAsync(id);
        if (role is null)
        {
            return NotFound();
        }
        var result = await _roleManager.DeleteAsync(role);
        if (result.Succeeded)
        {
            var roleDto = new RoleDTO()
            {
                Id = role.Id,
                Name = role.Name
            };
            return Ok(roleDto);
        }
        return BadRequest(result.Errors);
    }
}
