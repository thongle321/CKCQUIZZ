namespace CKCQUIZZ.Server.Viewmodels.Token;

public class RefreshTokenRequest
{
    public string Id {get; set;} = default!;

    public required string RefreshToken {get; set;}
}
