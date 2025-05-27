namespace CKCQUIZZ.Server.Viewmodels.Token;

public class TokenResponse
{
    public required string AccessToken {get; set;}

    public required string RefreshToken {get; set;}

    public string Email {get; set;} = default!;

    public string Roles {get; set;} = default!;
}
