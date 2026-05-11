# Logs Monitoring (Real Time)

## 1. Contact Point (Template do Google Chat)
- **Name:** Google Chat Netbox
- **Message:**
  ```handlebars
  {{ range .Alerts.Firing }}
  🚨 *ALERTA DE MONITORAMENTO*
  *Host:* {{ .Labels.host }}
  *Detalhe:* {{ .Annotations.description }}
  {{ end }}
  ```
  
  
## 2. Notification Policy (Tempos)
- **Group wait: 1s**

- **Group interval: 1s**

-**Repeat interval: 4h (ou 1m para testes)**

## 3. Alert Rule (A Regra Mágica)
- **Evaluation Group: 10s**

- **For (Pending period): 0s**

- **Keep firing for: 10s**

### Query (LogQL):
```
    Snippet de código
    sum by (host, erro) (
    count_over_time({job="netbox-monitor"} |= "ERROR" | regexp "(?P<erro>.*)" [10s])
    )
```