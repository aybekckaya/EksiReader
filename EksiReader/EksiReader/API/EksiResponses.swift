//
//  EksiResponses.swift
//  EksiReader
//
//  Created by aybek can kaya on 10.04.2022.
//

import Foundation


// MARK: - AuthTokenResponse
struct AuthTokenResponse: ERBaseResponse {
    var success: Bool?
    var message: String?
    let accessToken: String?
    let expiresIn: String?

    enum CodingKeys: String, CodingKey {
        case success = "Success"
        case message = "Message"
        case accessToken = "access_token"
        case data = "Data"
        case expiresIn = "expires_in"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.success = try container.decodeIfPresent(Bool.self, forKey: .success)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
        let dataContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        self.accessToken = try dataContainer.decodeIfPresent(String.self, forKey: .accessToken)
        self.expiresIn = try dataContainer.decodeIfPresent(String.self, forKey: .expiresIn) ?? "0"
    }
}

// MARK: - Todays Response
struct TodaysEntry: Decodable {
    let fullCount: Int
    let title: String
    let id: Int
    let day: String
    let matchedCount: Int

    enum CodingKeys: String, CodingKey {
        case fullCount = "FullCount"
        case title = "Title"
        case id = "TopicId"
        case day = "Day"
        case matchedCount = "MatchedCount"
    }
}

struct TodaysResponse: ERBaseResponse, ERPagable {
    typealias T = TodaysEntry
    var success: Bool?
    var message: String?
    var entries: [T]
    var pageCount: Int
    var pageIndex: Int

    enum CodingKeys: String, CodingKey {
        case message = "Message"
        case entries = "Topics"
        case data = "Data"
        case pageCount = "PageCount"
        case pageIndex = "PageIndex"
        case success = "Success"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.success = try container.decodeIfPresent(Bool.self, forKey: .success)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
        let dataContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        self.pageCount = try dataContainer.decodeIfPresent(Int.self, forKey: .pageCount) ?? 0
        self.pageIndex = try dataContainer.decodeIfPresent(Int.self, forKey: .pageIndex) ?? 0
        self.entries = try dataContainer.decode([TodaysEntry].self, forKey: .entries)
       // let entriesContainer = try dataContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .entries)
    }
}

// MARK: - Today Topic Response
struct TodayTopicEntry: Decodable {
    let author: EksiAuthor?
    let id: Int
    let content: String
    let favoriteCount: Int
    let created: String
    let lastUpdated: String?
    let commentCount: Int
    let avatarUrl: String?
    let isSponsored: Bool
    let isVerifiedAccount: Bool

    enum CodingKeys: String, CodingKey {
        case author = "Author"
        case id = "Id"
        case content = "Content"
        case favoriteCount = "FavoriteCount"
        case created = "Created"
        case lastUpdated = "LastUpdated"
        case commentCount = "CommentCount"
        case avatarUrl = "AvatarUrl"
        case isSponsored = "IsSponsored"
        case isVerifiedAccount = "IsVerifiedAccount"
    }
}

struct EksiAuthor: Decodable {
    let nick: String
    let id: Int

    enum CodingKeys: String, CodingKey {
        case nick = "Nick"
        case id = "Id"
    }
}

struct TodayTopicResponse: ERBaseResponse, ERPagable, ERResponseTitle {
    typealias T = TodayTopicEntry
    var success: Bool?
    var message: String?
    var entries: [TodayTopicEntry]
    var pageCount: Int
    var pageIndex: Int
    var title: String?

    enum CodingKeys: String, CodingKey {
        case message = "Message"
        case success = "Success"
        case entries = "Entries"
        case pageCount = "PageCount"
        case pageIndex = "PageIndex"
        case data = "Data"
        case title = "Title"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.success = try container.decodeIfPresent(Bool.self, forKey: .success)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
        let dataContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        self.pageCount = try dataContainer.decodeIfPresent(Int.self, forKey: .pageCount) ?? 0
        self.pageIndex = try dataContainer.decodeIfPresent(Int.self, forKey: .pageIndex) ?? 0
        self.title = try dataContainer.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.entries = try dataContainer.decode([TodayTopicEntry].self, forKey: .entries)
       // let entriesContainer = try dataContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .entries)
    }
}


/***

 {
     "Success": true,
     "Message": null,
     "Data": {
         "Id": 7006370,
         "Title": "doğal afet yardımlaşma ağı",
         "Entries": [
             {
                 "Id": 126528665,
                 "Content": "türkiye’nin çeşitli bölgelerinde meydana gelen yangın, sel vb. doğal afetler için açtığımız ve sol frame’e sabitlediğimiz bu başlıkta; afetlerde maddi manevi zarar gören ve yardıma ihtiyacı olan afetzedelerle, afetzedelere destekte bulunmak isteyenleri bir araya getirmek istiyoruz.\r\n\r\nbu başlık altında; doğal afetlerde evlerini kaybedenlerin kalacak yer, yeme içme, giyecek vb. taleplerini karşılayabilir ve afet bölgelerine yardıma giden gönüllü ekiplere destek olabilirsiniz.\r\n\r\nhepimize geçmiş olsun diyoruz.",
                 "Author": {
                     "Nick": "dogal afet yardimlasma agi",
                     "Id": 3065638
                 },
                 "Created": "2021-08-04T21:27:41.983",
                 "LastUpdated": "2021-08-13T14:18:00",
                 "IsFavorite": false,
                 "FavoriteCount": 845,
                 "Hidden": false,
                 "Active": true,
                 "CommentCount": 3,
                 "CommentSummary": null,
                 "AvatarUrl": null,
                 "Media": null,
                 "IsSponsored": false,
                 "IsPinned": false,
                 "IsPinnedOnProfile": false,
                 "IsVerifiedAccount": false
             },
             {
                 "Id": 126528711,
                 "Content": "https://twitter.com/ahbapplatformu/status/1422843219101077504 (bkz: ahbap)\r\n\r\n[https://cdn.eksisozluk.com/2021/8/4/3/34a3jikm.jpg?key=34a3jikm görsel] nilüfer firmasının birlik için başlattığı hareket.\r\n\r\n[https://cdn.eksisozluk.com/2021/8/4/9/9m31v1b0.jpg?key=9m31v1b0 görsel] bodrum belediyesine iban yoluyla 'şartsız bağış' yazılarak destek olunabilecek iban bilgileri.\r\n\r\nhttps://twitter.com/ALANYABLD/status/1422517468011061248 alanya belediyesi'nin çağrısı\r\n\r\nmuğla ören'de tahliye edilecek 13 bin kişi olduğu fakat şu an araçlar ve diğer imkanlar ile sadece 1000 kişi tahliye edilebildiği bilgisi var. teknesi olan tüm kaptanlar ve tekne sahipleri tahliye için marinaya davet ediliyorlar. / ören tahliyesindeki tekneler sağlanmış.\r\n\r\nalemler köyü, karacasu, aydın'dan yangın bilgisi mevcut. gece olması sebebiyle hava desteği verilemiyor. https://cdn.eksisozluk.com/2021/8/4/f/fofojxcr.jpg?key=fofojxcr \r\nihtiyaç: tepe lambası, göz damlası, leğen, bol miktarda buz, maden suyu, meyve suyu, içme suyu, ayran, mümkünse kazma kürek vb. araçlar\r\n[https://www.google.com/maps/place/Alemler,+09370+Karacasu%2FAyd%C4%B1n/data=!4m2!3m1!1s0x14b8af243b17bf7b:0x49637e2e48983ffa?sa=X&ved=2ahUKEwjFs-ycm5jyAhUVA3IKHcIYC0EQ8gEwFnoECDMQAQ konum]\r\n\r\nhttps://www.aa.com.tr/tr/sirkethaberleri/sirketler/yurtici-kargo-yangin-bolgelerine-gonderilecek-yardimlari-ucretsiz-tasiyacak/666516 yangın bölgesine yurtiçi kargo yardımları ücretsiz taşıyacak detay haberi.",
                 "Author": {
                     "Nick": "alkolik imam",
                     "Id": 420402
                 },
                 "Created": "2021-08-04T21:28:33.373",
                 "LastUpdated": "2021-08-06T15:11:00",
                 "IsFavorite": false,
                 "FavoriteCount": 69,
                 "Hidden": false,
                 "Active": true,
                 "CommentCount": 0,
                 "CommentSummary": null,
                 "AvatarUrl": null,
                 "Media": [
                     "https://cdn.eksisozluk.com/2021/8/4/3/34a3jikm.jpg?key=34a3jikm",
                     "https://cdn.eksisozluk.com/2021/8/4/9/9m31v1b0.jpg?key=9m31v1b0",
                     "https://cdn.eksisozluk.com/2021/8/4/f/fofojxcr.jpg?key=fofojxcr"
                 ],
                 "IsSponsored": false,
                 "IsPinned": false,
                 "IsPinnedOnProfile": false,
                 "IsVerifiedAccount": false
             },
             {
                 "Id": 126528803,
                 "Content": "köyceğiz beyobasi ihtiyaç listesi bugün için [https://cdn.eksisozluk.com/2021/8/4/v/vfxdzz52.jpg?key=vfxdzz52 görsel]",
                 "Author": {
                     "Nick": "dilsizmeddah",
                     "Id": 529590
                 },
                 "Created": "2021-08-04T21:30:46.763",
                 "LastUpdated": null,
                 "IsFavorite": false,
                 "FavoriteCount": 25,
                 "Hidden": false,
                 "Active": true,
                 "CommentCount": 5,
                 "CommentSummary": null,
                 "AvatarUrl": null,
                 "Media": [
                     "https://cdn.eksisozluk.com/2021/8/4/v/vfxdzz52.jpg?key=vfxdzz52"
                 ],
                 "IsSponsored": false,
                 "IsPinned": false,
                 "IsPinnedOnProfile": false,
                 "IsVerifiedAccount": false
             },
             {
                 "Id": 126528873,
                 "Content": "`önemli edit`: bozdoğan-altıntaş köyüne acil su, tanker ve eldiven lazım. [https://www.google.com/maps/place/Alt%C4%B1nta%C5%9F,+09760+Bozdo%C4%9Fan%2FAyd%C4%B1n/@37.6111532,28.3221373,17z/data=!3m1!4b1!4m5!3m4!1s0x14bf49f85f2d66cf:0xd6494ca93ef6bf08!8m2!3d37.611102!4d28.321634 konum]\r\n\r\n[https://streamable.com/h9550r anlık video]\r\n\r\n---\r\n\r\nüst edit: aydın-karacasu-alemler köyü acil su takviyesine ihtiyaç var. lütfen arkadaşlar, acil. `3 ağustos 2021 bozdoğan yangını` başlığını gündeme taşımamıza yardımcı olursanız daha çok kişiye ulaşabiliriz.\r\n\r\n[https://cdn.eksisozluk.com/2021/8/5/l/l7mx9yfv.jpg?key=l7mx9yfv görsel]\r\n\r\ndesteklerinizi bekliyoruz sevgili arkadaşlar, detaylar başlıkta. (bkz: 3 ağustos 2021 bozdoğan yangını)\r\n\r\nihtiyaçlar: el feneri, tepe lambası, göz damlası, leğen, bol miktarda buz, maden suyu, meyve suyu, içme suyu, kuru gıda , kürek, eldiven, tırmık\r\n\r\nbölgeye yakın olanları alemler köyü meydana bekliyoruz. eğer uzaktan destekte bulunmak istiyorsanız, \"esençay köyü kuyucak-tavas yolu üzeri no:180 karacasu-aydın\" adresine gönderebilirsiniz. bu adrese ulaşan yardımları bir arkadaşımız bizzat alemler köyüne ulaştıracak.\r\n\r\n[https://cdn.eksisozluk.com/2021/8/4/f/fofojxcr.jpg?key=fofojxcr son durum resim]\r\n\r\n[https://streamable.com/oysli2 örneğin 21:30 itibariyle köylerden birinden yangının durumu, video]\r\n\r\nedit: [https://cdn.eksisozluk.com/2021/8/4/u/ufdrm5na.png?key=ufdrm5na görsel]\r\n\r\nsabah saat 5'te ağaç motoru olan herkesi karacasu, alemler köyüne çağırıyorlar arkadaşlar. 15 kişiye ihtiyaç var en az.",
                 "Author": {
                     "Nick": "traktortekerininicindekihava",
                     "Id": 2233783
                 },
                 "Created": "2021-08-04T21:32:20.667",
                 "LastUpdated": "2021-08-06T17:14:00",
                 "IsFavorite": false,
                 "FavoriteCount": 11,
                 "Hidden": false,
                 "Active": true,
                 "CommentCount": 0,
                 "CommentSummary": null,
                 "AvatarUrl": "https://img.ekstat.com/profiles/traktortekerininicindekihava-637489438398245863.jpg",
                 "Media": [
                     "https://cdn.eksisozluk.com/2021/8/5/l/l7mx9yfv.jpg?key=l7mx9yfv",
                     "https://cdn.eksisozluk.com/2021/8/4/f/fofojxcr.jpg?key=fofojxcr",
                     "https://cdn.eksisozluk.com/2021/8/4/u/ufdrm5na.png?key=ufdrm5na"
                 ],
                 "IsSponsored": false,
                 "IsPinned": false,
                 "IsPinnedOnProfile": false,
                 "IsVerifiedAccount": false
             },
             {
                 "Id": 126528917,
                 "Content": "dogada arama kurtarma egitimi almamis, ancak gonullu olarak soz konusu bolgelere intikal etmek isteyen ve afet bolgesinde nasil hareket etmesi gerektigini bilmeyen bireyler cekinmeden yesillendirebilirler.\r\n\r\nis bu entry, potansiyel gonullu arkadaslarin bu surec icerisinde kendilerine ve cevrelerine verebilecekleri fiziksel zararlari minimize etmelerini saglamak icin yazilmistir.\r\n\r\n\redit: dostlar, gelen mesajlara sirasiyla donuyorum. ancak saniyorum tek tek mesaj atmak yerine standartlari bu entry altinda toplamak daha mantikli olacak.\r\n\r\n--- `spoiler` ---\r\n\r\n1. yanmaz/tutusmaz kiyafetlere ve ekipmanlara erisiminiz yok ancak yine de arazide calisacaksaniz, sicak bolgelere girmemeye ozen gosteriniz. mutlaka ama mutlaka celik burunlu bir bot giyiniz. spor ayakkabiyla, terlikle ya da kislik bot ile araziye girmeyiniz. celik burunlu bot sizin arazi kosullarinda yasamaniz olasi olan ayak yaralanmalarinin onune gecmenizi saglayacaktir. benim arama kurtarma faaliyetlerinde kullandigim bot yds marka ve fiyati 180 lira civarinda. eger alevlerin icerisine dalmayacaksaniz, arazi kosullarinda deri bir is eldiveni ellerinizi hafif yaralanmalara karsi korumak icin yeterli olacaktir. \r\n\r\n2. yuksek gerilim hatlari altinda calismayacaksaniz dahi, imkaniniz varsa gonulluluk faaliyetlerini class g (class e olursa iyi olur) bir sert kabuklu baret ile yurutunuz. class g baretler 2,200 volt'a kadar, class e baretler ise 20,000 volt'a kadar elektrigi yalitmak suretiyle kafanizi koruyacaktir. bu baretler kafanizi darbelerden koruyacak olsa da, vucudunuzun diger bolumlerini darbelerden ve elektrikten korumayacagini aklinizdan cikartmayiniz.\r\n\r\n3. arazi kosullarinda comelmeniz, dizlerinizin ustunde durmaniz gerekebilir. bu sebeple sert kabuklu dizlikler kullanmak dizlerinizin ustune rahatca cokebilmenizi saglayacak ve dizlerinizi darbelere karsi da koruyacaktir.\r\n\r\n4. gunduz ya da gece fark etmeksizin reflektif bir yelek giymeye ozen gosterin. eger yelek bulamadiysaniz mutlak suretle reflektif bant edinip kollarinizi, bacaklarinizi ve gogusunuzu tamamen saracak sekilde yapistiriniz. sayet varsa, kaskinizin da on, arka, sag ve sol taraflariniza bu bantlari yapistiriniz. bu sizlerin diger bireyler tarafindan daha kolay gorulmenizi/fark edilmenizi saglayacaktir. \r\n\r\n5. cantanizda ya da uzerinizde kesici/delici/sert bir alet (bicak, caki, el tirmigi, el kuregi vb.) tasimayin. tasimanizi icab eden bir durum varsa, beklenmedik bir sekilde acilmasini engellemek adina mutlaka bir kini icerisinde bulundugundan ve sabitlenmis oldugundan emin olun. boylece ufak bir dususte kendinize saplanmasinin veya zarar vermesinin onune gecmis olacaksiniz. \r\n\r\n6. bir faaliyette bulunurken asla acele etmeyin, kosmayin. kucuk ancak emin adimlarla arazi uzerinde hareket edin, bu sizin hem gereksiz efor sarf etmenizi engelleyecek, hem de arazi kosullarinda yasayabileceginiz sorunlari minimize edecektir. asla ama asla panikle ya da heyecanla hareket etmeyin.\r\n\r\n7. tanimadiginiz/bilmediginiz bir arazide iseniz tek basiniza hareket etmekten kacinin. uzerinizde akilli telefon ve telefonunuzu sarj edebileceginiz ekipman olsa dahi hattiniz cekmeyebilir, bu da sizin yonunuzu harita uzerinde bulmanizi ya da bir yardim cagrisi olusturmanizi zorlastiracaktir. bu sebeple portatif (el tipi) bir gps cihazini elinizde bulundurmak faydali olabilir (garmin marka olanlar iyidir). unutmayin, araziyi cok iyi biliyor olsaniz dahi, hava kosullari ve diger olumsuzluklar yonunuzu kaybetmenize, ulasmak istediginiz noktadan daha da uzaklasmaniza neden olabilir. \r\n\r\n8. kaskiniza takabileceginiz bir kafa lambasini bulundurmak, ellerinizi bosa cikartmaniza cokca faydali olacaksa da, sisli ya da dumanli ortamlarda lumeninin kisitli olmasi sebebiyle pek faydali olmayacaktir. bu sebeple yaninizda sari isik da verebilen, minimum 1000 lumen bir el feneri olmali. \r\n\r\n9. aksiyonlariniz sirasinda profesyonel arama kurtarma/yangin sondurme ekiplerinin islerine mani olmamaya azami ozen gosteriniz. ozellikle bir anons ile talep edilmedikce, bu birimlere yaklasip \"abi, abla yardim lazim mi\" gibi sorular sormayiniz. evet biliyoruz yardimci olabilecek yetkinlikte, fiziksel guctesiniz. ancak bu ekipler bir ekip lideri tarafindan yonetilmekte ve bir aksiyon semasina bagli olarak hareket etmekteler.\r\n\r\n10. operasyon bolgelerinde calisan ekipmanlara dokunmayiniz, mudahale etmeyiniz. operasyon bolgesinde jenaratorlere ya da diger elektrik kaynaklarina bagli cihazlarin/ekipmanlarin kablolarina basmayiniz. kablolarin ya da ekipmanlarin yerlerini degistirmeyiniz.\r\n\r\n11. fiziksel ya da mental olarak yoruldugunuzu hissettiginiz anda operasyondan cekilip dinlenmek sizi beceriksiz, yetersiz ya da basarisiz yapmaz. mutlaka (bir ekip dahilinde calisiyorsaniz) etrafinizdakilere dinlenmeniz gerektigini iletin. kimse sizi ayiplamayacaktir.\r\n\r\n12. yanmaz ekipmaniniz yoksa mumkun oldugunca sicak bolgelere girmemeye calisin. dumana maruz kaldiginizda, agzinizi ve burnunuzu islak bir bez parcasiyla kapatin. (bu durumlara karsin boynunuzda bir buff olmasi faydali olabilir). mumkun oldugunca yere yakin olun ve boyle hareket edin (comelerek ya da emekleyerek ilerleyin).\r\n\r\n13. kendi can guvenliginizi saglayamadiginiz noktada bir baskasina da faydali olamayacaginizi unutmayin, kendinizi her kosulda, her an koruyun. \r\n\r\n14. itfaiye ekipleri sizden bir yangin hortumunu tasimaniz konusunda destek talep ettiginde; hortumu yerde surumemeye azami dikkat gosterin. mumkunse boynunuzun etrafina sarip iki elinizle hortumu havaya kaldirarak tasiyin. boylece arazi kosullarinda hortum delinmelerinin ve patlamalarin onune gececeksiniz.\r\n\r\n15. agaclarin devrildiklerine sahit olabilirsiniz. devrilen agaci ellerinizle ya da vucudunuzla tutmaya calismayin, dusus alaninin aksi yonunde kacarak kendinizi guvene alin. agacin dustugu yonde saga ya da sola kacmak dusen dallarin sizi yaralamasina sebep verebilir. bu sirada etrafinizda baskalari da varsa muhakkak bagirarak kendilerini uyarin.\r\n\r\n16. yetkili birimler tarafindan bir alana girmemeniz soyleniyorsa, bu alanlara girmek icin lutfen israrci olmayiniz. bu kisitlamalarin sizlerin, birimlerin ve alanda bulunan tum canlilarin can guvenligini saglamak icin konuldugunu unutmayin. \r\n\r\nornek: https://twitter.com/AdemMetan/status/1423216020781768705\r\n\r\n17. yanginin surdugu bolgelerdeki kara yollarinin ne kadar dar olabilecegini goz onunde bulundurarak aracinizla ilgi bolgelere intikal edin. bir gurup halinde ilerliyorsaniz mumkun oldugunca az aracla ulasim saglayin. unutmayin, herkesin bu bolgelere sahsi araciyla gitmesi, operasyonda kullanilmasi elzem olan araclarin bolgeye ulasamamasina ya da bolgeden cikis yapamamasina sebep olabilir.\r\n\r\n18. yetkili ekipler tarafindan iletilmemis, sagdan soldan duydugunuz bilgileri dogrulamadan yetkili birimlere ya da cevrede bulunan bireylere aktarmayin. dezenformasyon yaratmaktan kacinin. (bkz: surdaki evin icinde 3 kisi mahsur kalmis) bu tarz yaklasimlar cevredeki bireylerin panik yapmasina, gercekten ihtiyac olan yerlere yardimin ulasamamasina, ya da panigin yol actigi telafisi zor hatalarin ortaya cikmasina sebep olabilir. \r\n\r\n19. yetkili ekipler tarafindan yapilan duyulara kulak verin. afet bolgelerinin cesitli lokasyonlarinda konuslanmis bu ekipler aralarinda surekli olarak uydu telefonlari, uzak mesafe telsizler ve roleler araciligiyla iletisime gecip bilgi paylasimi yapmaktalar. \r\n\r\n--- `spoiler` ---",
                 "Author": {
                     "Nick": "soppy cunt",
                     "Id": 1590287
                 },
                 "Created": "2021-08-04T21:33:29.123",
                 "LastUpdated": "2021-08-05T16:49:00",
                 "IsFavorite": false,
                 "FavoriteCount": 89,
                 "Hidden": false,
                 "Active": true,
                 "CommentCount": 0,
                 "CommentSummary": null,
                 "AvatarUrl": null,
                 "Media": null,
                 "IsSponsored": false,
                 "IsPinned": false,
                 "IsPinnedOnProfile": false,
                 "IsVerifiedAccount": false
             },
             {
                 "Id": 126528982,
                 "Content": "cuma günü istanbul’dan marmaris’e doğru yola çıkacağız. yanımızda temin edebildiğimiz kadar powerbank, kedi köpek maması, kafa lambası, yanık kremi, benzinli testere, yanmaz eldiven var. bölgede olup bu liste veya dışında bir ihtiyacı olan yeşillendirebilir.\r\n\r\nedit: gelen mesajlar bölgelerde kulaklıklı telsiz, astım spreyi, göz damlası ve pilin de ihtiyacının bolca hissedildiği yönünde.\r\n\r\nedit2: marmaris’ten gelen bilgiye göre gelen yardım malzemeleriyle ihtiyaçların giderildiği, yeni destekte bulunmak isteyen kişilerin yardımlarını kime ne ulaştıracağını çok iyi tayin etmeleri yönünde. zira bu durumu kötüye kullanan insanlar da maalesef mevcut.",
                 "Author": {
                     "Nick": "purjen sahap",
                     "Id": 1139269
                 },
                 "Created": "2021-08-04T21:34:43.547",
                 "LastUpdated": "2021-08-05T12:53:00",
                 "IsFavorite": false,
                 "FavoriteCount": 26,
                 "Hidden": false,
                 "Active": true,
                 "CommentCount": 1,
                 "CommentSummary": null,
                 "AvatarUrl": "https://img.ekstat.com/profiles/purjen-sahap-637769109517522952.jpg",
                 "Media": null,
                 "IsSponsored": false,
                 "IsPinned": false,
                 "IsPinnedOnProfile": false,
                 "IsVerifiedAccount": false
             },
             {
                 "Id": 126529221,
                 "Content": "[https://twitter.com/savemovturkey/status/1422984805575168001?s=20 linkteki konuma hayvanların nakli için yardım gerekli]\r\natlar, eşekler ve büyükbaş hayvanlar için acil yardım gerekliymiş.\r\n\r\n[https://twitter.com/haysevder/status/1423027489555820547?s=20 bu da acil başka bir çağrı, lütfen zavallıları kurtaralım]\r\n\r\n[https://twitter.com/haysevder/status/1423032306143580170?s=20 turunç, kumlunun yol ayrımı acil nakliye]",
                 "Author": {
                     "Nick": "huniye hunharoglu",
                     "Id": 1815320
                 },
                 "Created": "2021-08-04T21:40:25.793",
                 "LastUpdated": "2021-08-05T00:31:00",
                 "IsFavorite": false,
                 "FavoriteCount": 9,
                 "Hidden": false,
                 "Active": true,
                 "CommentCount": 0,
                 "CommentSummary": null,
                 "AvatarUrl": "https://img.ekstat.com/profiles/huniye-hunharoglu-637847388305319766.jpg",
                 "Media": null,
                 "IsSponsored": false,
                 "IsPinned": false,
                 "IsPinnedOnProfile": false,
                 "IsVerifiedAccount": false
             },
             {
                 "Id": 126529370,
                 "Content": "marmaris merkezdeyim. yarın sabahtan itibaren var olan 2000 lira param ve tüm gücüm ile yardıma hazırım.\r\nedit : en azından marmaris içim en sağlıklısı belediye koordine merkezine başvurmak olacak. yarın bende bu yolu izleyeceğim. marmarise yardın etmek için gelmek isteyen olur ise seve seve yardımcı olmak isterim.",
                 "Author": {
                     "Nick": "retroow",
                     "Id": 619114
                 },
                 "Created": "2021-08-04T21:43:29.923",
                 "LastUpdated": "2021-08-04T22:05:00",
                 "IsFavorite": false,
                 "FavoriteCount": 10,
                 "Hidden": false,
                 "Active": true,
                 "CommentCount": 0,
                 "CommentSummary": null,
                 "AvatarUrl": null,
                 "Media": null,
                 "IsSponsored": false,
                 "IsPinned": false,
                 "IsPinnedOnProfile": false,
                 "IsVerifiedAccount": false
             },
             {
                 "Id": 126529409,
                 "Content": "oyuncu metin akdülger'in bir kaç saat evvel hikâyesinde paylaştığına göre londra'da bir yangın uçağı firmasıyla yazışma halindelermis, kendisi ve ablası...\r\n\r\nfiyat istenmiş, bazı bürokratik engellere takılmışlar elbette. sosyal medyada duyurulması faydalı olabilir diyorlar...\r\n\r\npaylaşırsak belki bir sonuç çıkar diye umuyorum..",
                 "Author": {
                     "Nick": "silinmiş entry",
                     "Id": 2236448
                 },
                 "Created": "2021-08-04T21:44:09.607",
                 "LastUpdated": null,
                 "IsFavorite": false,
                 "FavoriteCount": 24,
                 "Hidden": false,
                 "Active": true,
                 "CommentCount": 2,
                 "CommentSummary": null,
                 "AvatarUrl": null,
                 "Media": null,
                 "IsSponsored": false,
                 "IsPinned": false,
                 "IsPinnedOnProfile": false,
                 "IsVerifiedAccount": false
             },
             {
                 "Id": 126529456,
                 "Content": "tüm bölgelerde genel ihtiyaçlar:\r\n\r\nyanmaz eldiven, yanmaz ayakkabı (bağcıksız), yanmaz tulum\r\nkoruyucu gözlük\r\nkalın, uzun çorap\r\nkafa feneri (gece soğutma çalışmalarında çok elzem)\r\nel feneri (ve fenerler için ince kalem pil)\r\nilaçlama pompası, sulama hortumu (hortumlardaki deliklere karşı bant)\r\ndalgıç pompası hortumu\r\nfireball\r\ngaz maskesi\r\nerkek alt-üst iç çamaşırı (l beden ve üzeri)\r\nbuzlu su\r\niçme suyu\r\nağrı kesici (dolorex ve arveles. parol hafif kalıyor)\r\nsuni gözyaşı\r\nboğaz spreyi, pastil\r\nventolin krem\r\nyara antiseptiği (toz ve pomad)\r\nsoğuk kompres hızlı kiti\r\nsargı bezi, pflaster\r\npowerbank\r\nsentetik köpük\r\nköpüklü yangın söndürme tüpü\r\n\r\nhayvanlar için `haytap` ve `paw guards`\r\nbarınma için `ahbap`\r\nkaplumbağa, tavşan, tilki, küçük ırkları barındırmak ve tedavi etmek için hekim: 532 179 0707\r\nkaplumbağaların güvenli bir yere geçirilmesi için: +90 532 172 9517 @kaplumbagakurtarmatimi\r\nhaytap sahra hastanesi havalimanı - bodrum arasında kemikler mevkiinde\r\n\r\nyangın bölgelerinde hayvan koordinasyon ve iletişim ağı 0542 824 7008 - 0542 728 2963 - 0553 062 4221 - 0546481 1299 \r\ninstagram: @bur_hak\r\n\r\nyangın bölgelerine özel araçla yardım götürmek yerine belediyelerin koordinasyon birimlerine başvurunuz. yolların kalabalık olması işleri çok zorlaştırıyor.\r\n\r\nyangın bölgelerine kumanya gönderen olursa yiyeceklerin gazete ya da peçeteye sarılması isteniyor. domates çabuk bozulduğu için sandviçlerin domatessiz olması rica ediliyor. içeceklerin de kutu içecek olması (kola, soğuk kahve, enerji içeceği) meşrubatların ekiplere hızlı ulaştırılmasına ve hijyenik olmasına kısmen yardımcı oluyor.\r\n\r\nmaddi yardım yapmak isteyenler milas belediyesinin sosyal medya hesaplarından iban'a ulaşabilir.\r\n\r\naşırı sıcaktan kaynaklanan trafo yangınlarından dolayı yangın bölgeleri başta olmak üzere sıcak yerlerde 12.00-20.00 arasında çamaşır makinesi, bulaşık makinesi, fırın ve klima gibi cihazların olabildiğince az kullanılması tavsiye ediliyor.\r\n\r\ngönüllü ekiplerde soğutma yapan arkadaşlara duyuru: \r\nkaplumbağalar kaçamadıkları için bulundukları yeri 5-10 cm. kadar kazıp saklanıyorlarmış. kurtulan çok sayıda kaplumbağa varmış, kazara ezmemeye özen göstermeniz rica ediliyor.\r\n\r\n**********\r\nyangın bölgesinde bir hayvan bulunca ne yapabilirsiniz?\r\n- duman ve yangından uzaklaştırın\r\n- elle temas etmeyin. kıyafet, havlu, kumaşla sarın\r\n- ılık tutun, ılık ortama alın (vücut ısısının düşmemesi için)\r\n- yanıkları ılık suyla yıkayın (15 c civarı ılık su), hayvanı tamamen yıkamayın\r\n- yanığı steril bezle sarın\r\n- hayvanı kilitli box'a/kafese alın (hareket alanını daraltın)\r\n- hekime ulaştırın (hekimler sahada da kliniklerde de çalışıyorlar şu anda. büyük- ve küçükbaş hayvanları, yaban hayvanlarını da götürebilirsiniz)\r\n- muğla veteriner hekimleri odası il genelinde tüm hayvan hastane ve kliniklerinin yangından etkilenen her cins hayvana `ücretsiz` hizmet verdiğini duyurdu. bağış ya da ücret talep edilmiyor.\r\n**********\r\n\r\n----- muğla bölgesi -----\r\n(muğla'da minibüs, dolmuş, belediye otobüsleri yardımları garajlar arasında ücretsiz taşıyor. belediyeler de garajlardan alıyor. şehrin her yerinden yardım gönderebilirsiniz)\r\n\r\nyardım toplayan belediyelerin koordinasyon masalarının telefon numaraları ve adresleri (yardım göndermeden önce telefonla durumu sormanız çok iyi olur. nerede ne ihtiyacı olduğunu öğrenip ona gönderirsiniz).\n\n* menteşe (muğla merkez) eski garaj, atatürk bulvarı\r\n- belediye ana hattı: 0535 106 8454\r\n- belediye yetkilisi: 0536 862 6594\r\n\r\n- ortaca sosyal hizmetler birimi: 0536 862 6556\r\nbeşköprü mah. atatürk bulvarı no: 100, 48600 ortaca/muğla\r\n\r\n- milas bld. 0553 870 4050 & 0542 565 2753\n\r\n* bodrum 0532 418 4950\r(önce telefonla durumu sorunuz. bodrum'da muhtemelen artık ihtiyaç yok)\r\n- herodot kültür merkezi, konacık mah. mimar sinan cad. no: 47 bodrum/muğla (gönüllüler için kayıt masası aynı zamanda, ama gönüllü sayısı yeterli olabilir. gönüllü olma niyetiniz varsa önceden arayıp danışın. aksi halde hem trafikte hem de alanda gereksiz kalabalık yaratabilirsiniz)\r\n- mbb bodrum konacık hizmet binası: 0536 862 6615 (konacık mah. atatürk bulvarı no: 144)\nnot: mumcular sitare özkan çok programlı anadolu lisesi'ndeki ana koordinasyon noktası kapanıyor.\r\n\r\n- fethiye 0530 149 1069\r\nakarca mah. mustafa kemal bulvarı no: 196/a, 48300 fethiye/muğla\r\n(fethiye sosyal hizmet birimi: 0535 106 8426)\r\n\r\n- marmaris 0850 888 4848\r\namiral orhan aydın kapalı spor salonu, sarıana mah. 18. sk. no: 32, 48700 marmaris/muğla (bu adres bugünden itibaren evlerini kaybedenlere mobilya, beyaz eşya gibi gönderileri de topluyor).\r\r\n\r\n(bkz: 2021 yangınları yardım ve dayanışma platformu)",
                 "Author": {
                     "Nick": "metonymics",
                     "Id": 1988585
                 },
                 "Created": "2021-08-04T21:45:04.757",
                 "LastUpdated": "2021-08-07T13:16:00",
                 "IsFavorite": false,
                 "FavoriteCount": 70,
                 "Hidden": false,
                 "Active": true,
                 "CommentCount": 0,
                 "CommentSummary": null,
                 "AvatarUrl": "https://img.ekstat.com/profiles/metonymics-637206637182353675.jpg",
                 "Media": null,
                 "IsSponsored": false,
                 "IsPinned": false,
                 "IsPinnedOnProfile": false,
                 "IsVerifiedAccount": false
             }
         ],
         "PageCount": 34,
         "PageSize": 10,
         "PageIndex": 1,
         "PinnedEntry": null,
         "EntryCounts": {
             "BeforeFirstEntry": 0,
             "AfterLastEntry": 324,
             "Buddy": 0,
             "Total": 334
         },
         "DraftEntry": null,
         "IsTracked": false,
         "IsTrackable": false,
         "Slug": "dogal-afet-yardimlasma-agi",
         "Video": {
             "DisplayInfo": null,
             "InTopicVideo": false
         },
         "Disambiguations": [],
         "IsAmaTopic": true,
         "MatterCount": 0
     }
 }




 */
