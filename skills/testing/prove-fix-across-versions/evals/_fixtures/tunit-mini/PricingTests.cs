using TUnit.Mocks;

namespace Shop.Tests;

public interface IPriceSource
{
    decimal PriceOf(string sku);
}

public class PricingTests
{
    [Test]
    public async Task Configured_price_is_returned()
    {
        var prices = IPriceSource.Mock();
        prices.PriceOf("apple").Returns(1.25m);

        await Assert.That(prices.Object.PriceOf("apple")).IsEqualTo(1.25m);
    }
}
