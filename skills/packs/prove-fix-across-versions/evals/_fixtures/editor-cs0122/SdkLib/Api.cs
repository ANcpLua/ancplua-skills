namespace SdkLib;

internal interface IQuotaPolicy
{
    bool Allow(string clientId);
}
