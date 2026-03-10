FROM python:3.12-slim

RUN apt-get update \
  && apt-get install -y --no-install-recommends gcc g++ git \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .
RUN pip install --no-cache-dir -e ".[mcp]"
RUN python -c "import hyperliquid.info, inspect, pathlib; p=pathlib.Path(inspect.getfile(hyperliquid.info)); t=p.read_text(); t=t.replace('base_info = spot_meta[\"tokens\"][base]', 'base_info = spot_meta[\"tokens\"][base] if base < len(spot_meta.get(\"tokens\",[])) else {\"szDecimals\":0,\"name\":\"UNK\",\"weiDecimals\":8}'); t=t.replace('quote_info = spot_meta[\"tokens\"][quote]', 'quote_info = spot_meta[\"tokens\"][quote] if quote < len(spot_meta.get(\"tokens\",[])) else {\"szDecimals\":2,\"name\":\"UNK\",\"weiDecimals\":8}'); p.write_text(t)"
# Persistent state volume (Railway mounts here)
RUN mkdir -p /data

ENV PORT=8080
EXPOSE 8080

CMD ["python", "scripts/entrypoint.py"]
