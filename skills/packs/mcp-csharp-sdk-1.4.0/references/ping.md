# Ping

Bidirectional connection-health check. Either side can ping the other.

## Sending

```csharp
await client.PingAsync(cancellationToken: ct);
```

Servers can ping clients in the same way (stateful only — see Stateless reference for restrictions on server-to-client requests).

## Receiving

Automatic — incoming ping requests are answered by the SDK without any handler registration.

## When to use

- Pre-flight: confirm the server is alive before issuing a real call
- Keep-alive: periodic ping to prevent idle-timeout closure
- Connection-health monitor in long-lived stateful sessions

## When NOT to use

- Stateless HTTP: server-to-client ping not available (no GET channel). Client→server still works.
- Replacement for transport-level health checks — `/health` ASP.NET Core endpoints are cheaper

## Spec

https://modelcontextprotocol.io/specification/2025-11-25/basic/utilities/ping
