using SdkLib;
using TUnit.Mocks;

namespace Tests;

public class QuotaTests
{
    [Test]
    public async Task Internal_policy_is_mockable()
    {
        var policy = IQuotaPolicy.Mock();
        policy.Allow(Any()).Returns(false);

        await Assert.That(policy.Object.Allow("acme")).IsFalse();
    }
}
