using CKCQUIZZ.Server.Interfaces;
using Microsoft.Extensions.Configuration;
using System.Threading.Tasks;
using MailKit.Net.Smtp; 
using MailKit.Security; 
using MimeKit;
using CKCQUIZZ.Server.Viewmodels;
using Microsoft.Extensions.Options;

namespace CKCQUIZZ.Server.Services
{
    public class EmailSenderService : IEmailSender
    {
        private readonly smtpSettings _smtpSettings;
        public EmailSenderService(IOptions<smtpSettings> smtpSettings)
        {
            _smtpSettings = smtpSettings.Value;
        }

        public async Task SendEmailAsync(string email, string subject, string message)
        {
            var emailMessage = new MimeMessage();

            emailMessage.From.Add(new MailboxAddress(_smtpSettings.FromName, _smtpSettings.FromEmail));

            var emailList = email.Split(",");
            foreach (var e in emailList)
            {
                emailMessage.To.Add(new MailboxAddress("", e));
            }
            emailMessage.Subject = subject;
            emailMessage.Body = new TextPart(MimeKit.Text.TextFormat.Html) { Text = message };

            using (var client = new SmtpClient())
            {
                await client.ConnectAsync("smtp.gmail.com", 587, false);
                await client.AuthenticateAsync(_smtpSettings.FromEmail, _smtpSettings.Password);
                await client.SendAsync(emailMessage);

                await client.DisconnectAsync(true);

            }
        }
    }
}