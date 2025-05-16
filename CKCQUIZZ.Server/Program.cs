using CKCQUIZZ.Server.Data;
using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Identity.Client;
using Scalar.AspNetCore;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowVueApp", 
        builder =>
        {
            builder.WithOrigins("https://localhost:50263") 
                   .AllowAnyHeader() 
                   .AllowAnyMethod() 
                   .AllowCredentials(); 
        });
});

builder.Services.AddDbContext<CkcquizzContext>(options => options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));
builder.Services.AddIdentityCore<NguoiDung>()
                .AddRoles<IdentityRole>()
                .AddSignInManager()
                .AddEntityFrameworkStores<CkcquizzContext>();

builder.Services.Configure<IdentityOptions>(options => {
    options.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(1);
    options.Lockout.MaxFailedAccessAttempts = 5;
    options.Lockout.AllowedForNewUsers = true;
    options.SignIn.RequireConfirmedPhoneNumber = false;
    options.SignIn.RequireConfirmedAccount = false;
    options.SignIn.RequireConfirmedEmail = false;
    options.Password.RequireDigit = false;           
    options.Password.RequiredLength = 8;             
    options.Password.RequireNonAlphanumeric = false; 
    options.Password.RequireLowercase = false;       
    options.Password.RequireUppercase = false;       
    options.Password.RequiredUniqueChars = 1;      
    options.User.RequireUniqueEmail = true;

});
builder.Services.AddAuthentication(options => {
    options.DefaultAuthenticateScheme = 
    options.DefaultChallengeScheme = 
    options.DefaultForbidScheme =
    options.DefaultScheme = 
    options.DefaultSignInScheme = 
    options.DefaultSignOutScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddCookie(IdentityConstants.ApplicationScheme)
.AddBearerToken(IdentityConstants.BearerScheme);
builder.Services.AddAuthorizationBuilder();

builder.Services.AddOpenApi();

builder.Services.AddTransient<SeedData>();

builder.Services.AddScoped<ITokenService, TokenService>();
var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        Console.WriteLine("Seeding data");

        var seedData =  services.GetService<SeedData>();

        seedData.Seed().Wait();

        Console.WriteLine("Database seeding completed successfully."); // Thông báo thành công
    }
    catch (Exception ex)
    {
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "An error occurred while seeding the database.");
    }
}
if(app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.MapScalarApiReference();
}
app.UseDefaultFiles();
app.MapStaticAssets();


app.UseHttpsRedirection();

app.UseRouting();
app.UseCors("AllowVueApp");

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.MapFallbackToFile("/index.html");

app.Run();
//"Token": "this_is_a_very_secure_token_key__trolllllllllllllllllllllllllllll_1234567890!",
