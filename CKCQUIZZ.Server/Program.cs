using CKCQUIZZ.Server.Data;
using CKCQUIZZ.Server.Interfaces;
using CKCQUIZZ.Server.Models;
using CKCQUIZZ.Server.Services; 
using CKCQUIZZ.Server.Viewmodels;
using FluentValidation;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Scalar.AspNetCore;
using CKCQUIZZ.Server.Authorization;
using Microsoft.AspNetCore.Authentication;
using System.Reflection;
using QuestPDF.Infrastructure;
var builder = WebApplication.CreateBuilder(args);

QuestPDF.Settings.License = LicenseType.Community;

builder.Services.AddSignalR();

builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.ReferenceHandler = System.Text.Json.Serialization.ReferenceHandler.IgnoreCycles;
    });
builder.Services.AddValidatorsFromAssembly(typeof(Program).Assembly, includeInternalTypes: true);
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        builder =>
        {
            builder.SetIsOriginAllowed(origin => true)
                   .AllowAnyHeader()
                   .AllowAnyMethod()
                   .AllowCredentials();
        });
});
builder.Services.AddControllers().AddJsonOptions(options =>
{
    options.JsonSerializerOptions.Converters.Add(new System.Text.Json.Serialization.JsonStringEnumConverter());
});
builder.Services.AddDbContext<CkcquizzContext>(options => options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));
builder.Services.AddIdentity<NguoiDung, ApplicationRole>()
                .AddEntityFrameworkStores<CkcquizzContext>()
                .AddDefaultTokenProviders();

builder.Services.Configure<IdentityOptions>(options =>
{
    options.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(15);
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
    options.Tokens.EmailConfirmationTokenProvider = TokenOptions.DefaultEmailProvider;
    options.Tokens.PasswordResetTokenProvider = TokenOptions.DefaultEmailProvider;

});

builder.Services.Configure<smtpSettings>(builder.Configuration.GetSection("smtpSettings"));
builder.Services.Configure<DataProtectionTokenProviderOptions>(options => options.TokenLifespan = TimeSpan.FromMinutes(30));

builder.Services.Configure<SecurityStampValidatorOptions>(o =>
    o.ValidationInterval = TimeSpan.FromMinutes(1));

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultForbidScheme =
    options.DefaultScheme =
    options.DefaultSignInScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultSignOutScheme = JwtBearerDefaults.AuthenticationScheme;
})

.AddCookie(options =>
{
    options.Cookie.HttpOnly = true;
    options.Cookie.SecurePolicy = CookieSecurePolicy.Always;
    options.Cookie.SameSite = SameSiteMode.None;
})
.AddGoogle(options =>
{
    var clientId = builder.Configuration["Authentication:Google:ClientId"];
    var clientSecret = builder.Configuration["Authentication:Google:ClientSecret"];
    if (clientId is null)
    {
        throw new ArgumentNullException(nameof(clientId));
    }
    if (clientSecret is null)
    {
        throw new ArgumentNullException(nameof(clientSecret));
    }
    options.ClientId = clientId;
    options.ClientSecret = clientSecret;
    options.SignInScheme = CookieAuthenticationDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    var signingKey = builder.Configuration["JWT:SigningKey"]
?? throw new InvalidOperationException("JWT:SigningKey is not configured.");
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidIssuer = builder.Configuration["JWT:Issuer"],
        ValidateAudience = true,
        ValidAudience = builder.Configuration["JWT:Audience"],
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(System.Text.Encoding.UTF8.GetBytes(signingKey)),
        ValidateLifetime = true,
        ClockSkew = TimeSpan.Zero
    };
    options.Events = new JwtBearerEvents
    {
        OnMessageReceived = ctx =>
        {
            ctx.Request.Cookies.TryGetValue("accessToken", out var accessToken);

            if (string.IsNullOrEmpty(accessToken) && ctx.Request.Query.ContainsKey("access_token"))
            {
                accessToken = ctx.Request.Query["access_token"];
            }

            if (!string.IsNullOrEmpty(accessToken))
            {
                ctx.Token = accessToken;
            }
            return Task.CompletedTask;
        }
    };
});
builder.Services.AddAuthorization(options =>
{
    var permissionType = typeof(Permissions);
    var permissionConstants = permissionType.GetNestedTypes()
        .SelectMany(t => t.GetFields(BindingFlags.Public | BindingFlags.Static))
        .Where(fi => fi.FieldType == typeof(string))
        .Select(x => (string)x.GetValue(null)!)
        .ToList();

    foreach (var permission in permissionConstants)
    {
        options.AddPolicy($"Permission.{permission}", policy =>
            policy.Requirements.Add(new PermissionRequirement(permission)));
    }
});

builder.Services.AddAuthorizationBuilder();

builder.Services.AddSingleton<IAuthorizationHandler, PermissionAuthorizationHandler>();

builder.Services.AddOpenApi(options => {options.AddDocumentTransformer<BearerSecuritySchemeTransformer>(); });
builder.Services.AddHttpContextAccessor();
builder.Services.AddSingleton<IAuthorizationHandler, PermissionAuthorizationHandler>();
builder.Services.AddTransient<SeedData>();
builder.Services.AddTransient<IEmailSender, EmailSenderService>();
builder.Services.AddTransient<IClaimsTransformation, Claims>();
builder.Services.AddScoped<ITokenService, TokenService>();
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IMonHocService, MonHocService>();
builder.Services.AddScoped<IChuongService, ChuongService>();
builder.Services.AddScoped<IPermissionService, PermissionService>();
builder.Services.AddScoped<ICauHoiService, CauHoiService>();
builder.Services.AddScoped<IFileService, FileService>();
builder.Services.AddScoped<IDeThiService, DeThiService>();
builder.Services.AddScoped<INguoiDungService>(provider =>
    new NguoiDungService(
        provider.GetRequiredService<UserManager<NguoiDung>>(),
        provider.GetRequiredService<RoleManager<ApplicationRole>>()
    ));
builder.Services.AddScoped<ILopService, LopService>();
builder.Services.AddScoped<IPhanCongService, PhanCongService>();
builder.Services.AddScoped<ISoanThaoDeThiService, SoanThaoDeThiService>();
builder.Services.AddScoped<IThongBaoService, ThongBaoService>();
builder.Services.AddScoped<IUserProfileService, UserProfileService>();
builder.Services.AddHostedService<CKCQUIZZ.Server.BackgroundServices.ExamStatusUpdaterService>();
builder.Services.AddScoped<IDashboardService, DashboardService>();
builder.Services.AddSingleton<IActiveUserService, ActiveUserService>();

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        Console.WriteLine("Seeding data");

        var seedData = services.GetService<SeedData>();

        seedData?.Seed().Wait();

        Console.WriteLine("Database seed thành công");
    }
    catch (Exception ex)
    {
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "Có lỗi khi seeding");
    }
}
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.MapScalarApiReference(options =>
    {
        options.WithTheme(ScalarTheme.Moon)
        .WithDarkMode(true)
        .WithDarkModeToggle(false);
    });
}
app.UseDefaultFiles();

app.UseStaticFiles();
app.UseHttpsRedirection();

app.UseRouting();

app.UseCors("AllowAll");

app.UseCookiePolicy();

app.UseAuthentication();

app.UseAuthorization();

app.MapHub<CKCQUIZZ.Server.Hubs.NotificationHub>("/notificationHub");
app.MapHub<CKCQUIZZ.Server.Hubs.ExamHub>("/examHub");

app.MapControllers();

app.MapFallbackToFile("/index.html");

app.Run();
