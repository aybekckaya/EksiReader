# EksiReader Backend

EksiReader Backend, Ekşi Sözlük'ün herkese açık gündem ve topic HTML'lerini okuyup istemcilerin tüketebileceği normalize JSON sunan, public ve read-only bir Cloudflare Worker'dır. Kimlik doğrulama ve kullanıcı işlemleri içermez.

## Teknoloji ve mimari

- Cloudflare Workers ve TypeScript (strict mode)
- Cloudflare `HTMLRewriter` ile streaming HTML parse
- Cloudflare D1 ile 60 saniyelik response cache ve topic metadata
- Vitest + Cloudflare Workers test pool

İstek akışı şöyledir:

```text
HTTP route
  -> TrendingService / TopicService
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

Node.js 20.9 veya üzeri gerekir.

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

Migration'lar `topics` ve `response_cache` tablolarını, entry-count bilgi durumunu ve D1 arama indexi için `search_title` kolonunu oluşturur.

Migration öncesinden kalan topic kayıtlarının normalize arama alanını doldurmak için:

```bash
npm run backfill-search-titles
```

Uzak D1 backfill işlemi production verisini değiştirir ve yalnızca bilinçli olarak çalıştırılmalıdır:

```bash
npm run backfill-search-titles -- --remote
```

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
curl "http://localhost:8787/v1/topics/8136443?page=1&sort=popular"
curl "http://localhost:8787/v1/search/suggestions?q=ins"
curl --get "http://localhost:8787/v1/search/resolve" \
  --data-urlencode "q=instagramdaki 80's akımı"
```

Trending için geçerli `page` aralığı 1–20, topic detail için 1–1000'dir. Parametre verilmezse `page=1` ve `sort=popular` kullanılır.

## Endpoint'ler

### `GET /health`

Ekşi'ye veya D1'e erişmeyen basit health check:

```json
{"status":"ok","service":"eksi-reader-api"}
```

### `GET /v1/trending?page=1`

Topic alanlarını `id`, `title`, `slug` ve `entryCount` olarak normalize eder. Pagination bilgisi HTML'deki `#quick-index-continue-link` üzerinden çıkarılır.

### `GET /v1/topics/:topicId?page=1&sort=popular`

Topic metadata, entry listesi ve pagination bilgisini tek bir Ekşi HTML isteğinden çıkarır. Şimdilik yalnızca `popular` sıralaması desteklenir.

```bash
curl "http://localhost:8787/v1/trending?page=1"
curl "http://localhost:8787/v1/topics/8136443?page=1&sort=popular"
```

Topic endpoint'inden önce trending çağrısı yapılmalıdır. Backend, istemcinin gönderdiği `topicId` ile D1 `topics` tablosundan `slug` değerini bulur. Topic D1'de yoksa slug tahmin etmez ve `404 TOPIC_NOT_FOUND` döner. Bulunan slug ile şu biçimde tek upstream istek oluşturulur:

```text
https://eksisozluk.com/{slug}--{topicId}?a=popular
https://eksisozluk.com/{slug}--{topicId}?a=popular&p=2
```

Bu tek HTML belgesinden `h1#title`, `.pager` ve `#entry-item-list > li#entry-item` parse edilir. Her entry için ayrı `/entry/:id` isteği yapılmaz. Entry içeriğinin düz metin sürümü HTML entity ve whitespace normalize edilerek `contentText` alanına yazılır. `contentHtml` linkleri korur; `script`, `style`, event handler ve JavaScript URL'leri temizlenir. Relative permalink ve protocol-relative avatar URL'leri absolute HTTPS URL'lerine çevrilir.

Örnek kısaltılmış response:

```json
{
  "success": true,
  "data": {
    "topic": {
      "id": 8136443,
      "title": "8 eylül 2026 real madrid inter maçı",
      "slug": "8-eylul-2026-real-madrid-inter-maci",
      "entryCount": 229
    },
    "entries": [
      {
        "id": 186257381,
        "contentText": "örnek entry metni",
        "contentHtml": "örnek entry metni",
        "author": {
          "id": 1200425,
          "username": "örnek yazar",
          "slug": "ornek-yazar",
          "avatarUrl": "https://img.ekstat.com/profiles/ornek.jpg"
        },
        "dateText": "08.09.2026 19:50",
        "favoriteCount": 0,
        "commentCount": 0,
        "likeCount": 0,
        "permalink": "https://eksisozluk.com/entry/186257381"
      }
    ],
    "pagination": {
      "currentPage": 1,
      "pageCount": 23,
      "hasPreviousPage": false,
      "previousPage": null,
      "hasNextPage": true,
      "nextPage": 2
    },
    "sort": "popular",
    "cache": {
      "cached": false,
      "stale": false,
      "fetchedAt": "2026-09-09T00:30:00.000Z"
    }
  }
}
```

### `GET /v1/search/suggestions?q=ins`

Suggestions tamamen yerel D1 `topics` tablosundan gelir; hiçbir external network isteği yapmaz ve `response_cache` kullanmaz. Trending, topic detail ve resolve upsert yolları her topic için Türkçe-toleranslı `search_title` alanını güncel tutar.

```bash
curl "http://localhost:8787/v1/search/suggestions?q=ins"
```

```json
{
  "success": true,
  "data": {
    "query": "ins",
    "topics": [
      {
        "id": 8136213,
        "title": "instagramdaki 80's akımı",
        "slug": "instagramdaki-80s-akimi",
        "entryCount": 840
      }
    ]
  }
}
```

Arama; trim, whitespace collapse, `tr-TR` lowercase ve Türkçe karakter/aksan normalizasyonu uygular. Exact eşleşme önce, ardından prefix eşleşmeler son görülme zamanına göre gelir. Prefix sonucu yoksa contains fallback çalışır. En fazla 10 topic döner. Resolve ile eklenen fakat gerçek entry sayısı henüz bilinmeyen topic'lerde `entryCount: null` kullanılır.

Ekşi'nin `/autocomplete/query` endpoint'i server-side isteklerde Cloudflare Managed Challenge döndürdüğü için backend tarafından hiç kullanılmaz. Author suggestions ve author resolve desteklenmez. Client, kullanıcı yazarken yaklaşık 300 ms debounce uygulamalıdır.

### `GET /v1/search/resolve?q=...`

D1 suggestions içinde bulunmayan exact topic başlıkları için opsiyonel manuel fallback'tir:

```bash
curl --get "http://localhost:8787/v1/search/resolve" \
  --data-urlencode "q=instagramdaki 80's akımı"
```

Backend `https://eksisozluk.com/?q=...` isteğini `redirect: manual` ile yapar; redirect'i takip edip büyük topic HTML'ini indirmez. `3xx Location` içinden topic id ve slug çıkarılır, `search_title` ile D1'e upsert edilir. Client daha sonra dönen id'yi mevcut topic endpoint'ine verir:

```bash
curl "http://localhost:8787/v1/topics/8136213?page=1&sort=popular"
```

Resolve isteği Managed Challenge alırsa bypass denenmez; API `503 SEARCH_RESOLVE_UNAVAILABLE` döndürür. `@author` sorguları `400 AUTHOR_RESOLVE_NOT_SUPPORTED` ile reddedilir.

## Cache ve hata davranışı

- Cache key biçimi `trending:{page}`, TTL 60 saniyedir.
- Topic cache key biçimi `topic:{topicId}:{sort}:{page}`, TTL 60 saniyedir.
- Search suggestions doğrudan D1 index sorgusudur; response cache'e yazılmaz.
- Geçerli cache varsa Ekşi'ye yeni istek yapılmaz ve `cached: true` döner.
- Cache yoksa HTML alınır, parse edilir; topic'ler D1 batch ile upsert edilir ve response cache'e yazılır.
- Cache süresi dolmuşken Ekşi 403, 429, 5xx, timeout veya network hatası verirse eski kayıt `cached: true, stale: true` ile döner.
- Kullanılabilir cache yoksa fetch hatası `502 TRENDING_FETCH_FAILED` olur.
- Topic fetch veya parse yenilemesi başarısız olduğunda expired topic cache varsa `cached: true, stale: true` ile kullanılır. Cache yoksa kontrollü `TOPIC_FETCH_FAILED` veya `TOPIC_PARSE_FAILED` yanıtı döner.
- `.topic-list` kaybolursa veya geçerli topic çıkmazsa parser sessizce boş liste döndürmez; `502 TRENDING_PARSE_FAILED` üretir.
- Production hata yanıtları stack trace, upstream HTML veya Cloudflare iç detayları içermez.

Parser topic href'inin query string'ini yok sayar, `/{slug}--{id}` pathname'inden kimlikleri çıkarır, whitespace ve HTML entity'lerini normalize eder. `entryCount`, bağlantı içindeki `<small>` metninden sayıya çevrilir.

## Deploy

Önce uzak migration'ı uygulayın, ardından:

```bash
npm run deploy
```

Deploy komutu Cloudflare üzerinde değişiklik yapar; çalıştırmadan önce hesap ve environment seçimini doğrulayın.
