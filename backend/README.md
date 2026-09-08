# EksiReader Backend

EksiReader Backend, Ekşi Sözlük'ün herkese açık gündem HTML'ini okuyup iOS veya başka istemcilerin tüketebileceği normalize JSON sunan, public ve read-only bir Cloudflare Worker'dır. Kimlik doğrulama ve kullanıcı işlemleri içermez.

## Teknoloji ve mimari

- Cloudflare Workers ve TypeScript (strict mode)
- Cloudflare `HTMLRewriter` ile streaming HTML parse
- Cloudflare D1 ile 60 saniyelik response cache ve topic metadata
- Vitest + Cloudflare Workers test pool

İstek akışı şöyledir:

```text
HTTP route
  -> TrendingService
     -> D1 cache repository
     -> Ekşi HTTP client
     -> HTML parser
     -> topic/cache repositories
```

Route HTML parse etmez; parser network isteği yapmaz; repository yalnızca D1 ile konuşur. Ekşi her zaman asıl veri kaynağıdır ve D1 kalıcı bir mirror değildir.

## Klasör yapısı

```text
backend/
├── migrations/               D1 şeması
├── src/
│   ├── clients/              Ekşi HTTP client
│   ├── errors/               Public hata tipleri
│   ├── models/               API ve domain modelleri
│   ├── parsers/              HTMLRewriter parser
│   ├── repositories/         D1 erişimi
│   ├── routes/               HTTP route'ları
│   ├── services/             Cache/fetch/parse orkestrasyonu
│   ├── utils/                JSON ve CORS response yardımcıları
│   └── index.ts              Worker giriş noktası
└── test/
    ├── fixtures/             Network bağımsız örnek HTML
    ├── clients/
    ├── parsers/
    └── services/
```

## Kurulum

Node.js 20 veya üzeri gerekir.

```bash
cd ~/Documents/EksiReader/backend
npm install
npx wrangler whoami
```

Oturum açık değilse:

```bash
npx wrangler login
```

## D1 kurulumu ve migration

`wrangler.jsonc`, `DB` binding'i üzerinden `eksi-reader-db` veritabanına bağlıdır. Yeni bir Cloudflare hesabında veritabanını oluşturup komutun verdiği `database_id` değerini config'e yazın:

```bash
npx wrangler d1 create eksi-reader-db
```

Yerel migration:

```bash
npx wrangler d1 migrations apply eksi-reader-db --local
```

Uzak migration (production veritabanını değiştirir):

```bash
npx wrangler d1 migrations apply eksi-reader-db --remote
```

Migration, `topics` ve `response_cache` tablolarını gerekli indexlerle oluşturur.

## Geliştirme ve doğrulama

```bash
npm test
npm run typecheck
npx wrangler dev
```

Başka bir terminalde:

```bash
curl http://localhost:8787/health
curl "http://localhost:8787/v1/trending?page=1"
curl "http://localhost:8787/v1/trending?page=2"
```

Geçerli `page` aralığı 1–20'dir ve parametre verilmezse 1 kullanılır.

## Endpoint'ler

### `GET /health`

Ekşi'ye veya D1'e erişmeyen basit health check:

```json
{"status":"ok","service":"eksi-reader-api"}
```

### `GET /v1/trending?page=1`

Topic alanlarını `id`, `title`, `slug` ve `entryCount` olarak normalize eder. Pagination bilgisi HTML'deki `#quick-index-continue-link` üzerinden çıkarılır.

## Cache ve hata davranışı

- Cache key biçimi `trending:{page}`, TTL 60 saniyedir.
- Geçerli cache varsa Ekşi'ye yeni istek yapılmaz ve `cached: true` döner.
- Cache yoksa HTML alınır, parse edilir; topic'ler D1 batch ile upsert edilir ve response cache'e yazılır.
- Cache süresi dolmuşken Ekşi 403, 429, 5xx, timeout veya network hatası verirse eski kayıt `cached: true, stale: true` ile döner.
- Kullanılabilir cache yoksa fetch hatası `502 TRENDING_FETCH_FAILED` olur.
- `.topic-list` kaybolursa veya geçerli topic çıkmazsa parser sessizce boş liste döndürmez; `502 TRENDING_PARSE_FAILED` üretir.
- Production hata yanıtları stack trace, upstream HTML veya Cloudflare iç detayları içermez.

Parser topic href'inin query string'ini yok sayar, `/{slug}--{id}` pathname'inden kimlikleri çıkarır, whitespace ve HTML entity'lerini normalize eder. `entryCount`, bağlantı içindeki `<small>` metninden sayıya çevrilir.

## Deploy

Önce uzak migration'ı uygulayın, ardından:

```bash
npm run deploy
```

Deploy komutu Cloudflare üzerinde değişiklik yapar; çalıştırmadan önce hesap ve environment seçimini doğrulayın.
