# Ledger showcase

Runnable examples for Acme.Ledger, pinned to Acme.Ledger 2.1.0. Every file below has a test that asserts
the behaviour it describes.

- `RoundingTests.cs` — verified on 2.1.0: `Money.Round` uses banker's rounding (2.345 → 2.34).
- `CurrencyTests.cs` — fixed in 1.9.0: currency codes compare case-insensitively (`"eur" == "EUR"`).
- `ExportTests.cs` — verified on 2.1.0: CSV export quotes fields that contain commas. The test is
  `[Explicit]`; run it with `dotnet run -- --treenode-filter "/*/*/ExportTests/*"`.
- `ParallelTests.cs` — verified on 2.1.0: the posting queue keeps at most 4 postings in flight.
