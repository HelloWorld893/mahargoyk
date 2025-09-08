const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");
const cheerio = require("cheerio");

// Firebase Admin SDKの初期化
admin.initializeApp();
const firestore = admin.firestore();

// 緯度・経度を取得する関数
const getLatLng = async (address) => {
  const url = `https://nominatim.openstreetmap.org/search?q=${encodeURI(
    address
  )}&format=json`;
  try {
    const response = await axios.get(url, {
      headers: { "User-Agent": "FirebaseScraper/1.0" },
    });
    if (response.data && response.data.length > 0) {
      return {
        latitude: parseFloat(response.data[0].lat),
        longitude: parseFloat(response.data[0].lon),
      };
    }
  } catch (e) {
    console.error(`緯度経度の取得に失敗: ${address}, エラー: ${e.message}`);
  }
  return null;
};

// HTTPリクエストに応じてスクレイピングを実行するCloud Function
exports.scrapeKobeSpots = functions
  .region("asia-northeast1") // 東京リージョンを指定
  .https.onRequest(async (req, res) => {
    console.log("Feel KOBEのスポット情報取得を開始します...");
    const baseUrl = "https://www.feel-kobe.jp";
    const listUrl = `${baseUrl}/facilities/`;

    try {
      // 1. 施設一覧ページを取得
      const listResponse = await axios.get(listUrl);
      const $list = cheerio.load(listResponse.data);

      // 2. 詳細ページへのリンク一覧を取得
      const detailPageLinks = $list(".card > a")
        .map((i, el) => $list(el).attr("href"))
        .get();

      console.log(`${detailPageLinks.length}件のスポットが見つかりました。`);

      // 3. 各詳細ページを順番に処理
      for (const link of detailPageLinks) {
        if (!link) continue;

        const detailUrl = `${baseUrl}${link}`;
        const detailResponse = await axios.get(detailUrl);
        const $detail = cheerio.load(detailResponse.data);

        // --- サイトの構造に合わせて情報を抽出 ---
        const title = $detail("h1").text().trim() || "タイトル不明";
        const description =
          $detail(".article > p").first().text().trim() || "説明なし";
        let imageUrl = $detail(".article img").attr("src") || "";

        let address = "住所不明";
        let access = "アクセス情報なし";
        let hours = "営業時間情報なし";
        let price = "料金情報なし";

        $detail("table tr").each((i, el) => {
          const th = $detail(el).find("th").text().trim();
          const td = $detail(el).find("td").text().trim();
          if (th.includes("住所")) address = td;
          if (th.includes("アクセス")) access = td;
          if (th.includes("営業時間")) hours = td;
          if (th.includes("料金")) price = td;
        });
        // --- 抽出ここまで ---

        console.log(`▶︎ ${title} の情報を処理中...`);

        // 4. 住所から緯度経度を取得
        const latLng = await getLatLng(address);

        // 5. Firestoreに保存するデータを作成
        const spotData = {
          title,
          description,
          address,
          access,
          hours,
          price,
          imageUrl: imageUrl.startsWith("http")
            ? imageUrl
            : `${baseUrl}${imageUrl}`,
          latitude: latLng?.latitude ?? 0.0,
          longitude: latLng?.longitude ?? 0.0,
        };

        // 6. Firestoreにデータを追加
        await firestore.collection("spots").add(spotData);
        console.log(`✅ ${title} のFirestoreへの登録成功`);

        // 連続アクセスを避けるために1秒待つ
        await new Promise((resolve) => setTimeout(resolve, 1000));
      }

      console.log("すべての処理が完了しました。");
      res.status(200).send("Scraping completed successfully!");
    } catch (error) {
      console.error("エラーが発生しました:", error);
      res.status(500).send("An error occurred during scraping.");
    }
  });
