# Runtime and change verification

Use the same ownership model and date as the static run. Inspect `artifacts/spans/spans.json` for trace/span counts, resolved boundaries, `unknownServices`, calls, and findings. RT1 detects cycles, RT2 disallowed or expired calls, and RT3 shared database use; inspect `Spans.cs` for their exact matching rules. Unmapped services have unchecked calls, and missing instrumentation limits conclusions. A zero exit status means the checks ran, not that no violation exists. Trace results establish only behavior observed in the supplied workload.

After changing semantics, rebuild through Fallout and exercise the declared sample. Add focused fixtures when the affected rule or error path is not covered there. Verify the diagnostic location/message, configuration or date behavior, aggregation, and exit/report status relevant to the change. The sample alone does not validate every static rule, runtime rule, or corpus input.
