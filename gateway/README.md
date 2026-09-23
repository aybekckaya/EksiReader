# EksiReader Fetch Gateway

EksiReader Worker'ın doğrudan erişemediği public Ekşi HTML endpoint'lerini sabit bir allowlist üzerinden alan küçük Node.js servisidir. Parser, cache ve D1 mantığı gateway'e taşınmaz; gateway yalnızca kontrollü source transport görevi görür.

## Güvenlik

- `/health` dışındaki bütün endpointler Bearer token ister.
- Serbest `url` parametresi veya açık proxy yoktur.
- Yalnızca tanımlı Ekşi endpointleri çağrılabilir.
- Input doğrulaması, 10 saniye timeout ve 2 MiB response limiti vardır.
- Upstream cookie'leri istemciye aktarılmaz.
- Cloudflare challenge yanıtı değiştirilmeden iletilir; bypass edilmez.

## Lokal çalıştırma

```bash
cd gateway
npm install
cp .env.example .env
```

En az 32 karakterlik bir token oluşturun:

```bash
openssl rand -hex 32
```

```bash
GATEWAY_TOKEN="üretilen-token" npm run dev
```

```bash
curl "http://localhost:10000/health"
```

```bash
curl -H "Authorization: Bearer üretilen-token" \
  "http://localhost:10000/source/trending?page=1"
```

## Render ayarları

- Branch: `main`
- Root Directory: `gateway`
- Runtime: `Node`
- Build Command: `npm ci && npm run build`
- Start Command: `npm start`
- Health Check Path: `/health`
- Environment secret: `GATEWAY_TOKEN`

Render deploy tamamlandıktan sonra önce gateway'in Ekşi erişimi ayrıca doğrulanmalıdır. Upstream `403` veya challenge dönerse bypass denenmemeli ve Worker entegrasyonuna geçilmemelidir.
