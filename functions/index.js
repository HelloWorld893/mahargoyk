// functions/index.js

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();
const db = admin.firestore();

// Gmailの認証情報（環境変数に設定することを強く推奨します）
// 例: firebase functions:config:set gmail.email="myemail@gmail.com" gmail.password="app-password"
const gmailEmail = functions.config().gmail.email;
const gmailPassword = functions.config().gmail.password;

// Nodemailerのトランスポーターを設定
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: gmailEmail,
    pass: gmailPassword,
  },
});

/**
 * 認証コードを生成し、メールで送信する関数
 */
exports.sendVerificationCode = functions.https.onCall(async (data, context) => {
  const email = data.email;
  if (!email) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "メールアドレスは必須です。"
    );
  }

  // 6桁のランダムな認証コードを生成
  const code = Math.floor(100000 + Math.random() * 900000).toString();
  const expiresAt = admin.firestore.Timestamp.fromMillis(
    Date.now() + 10 * 60 * 1000 // 10分後に失効
  );

  // コードをFirestoreに保存
  await db.collection("verificationCodes").doc(email).set({
    code: code,
    expiresAt: expiresAt,
  });

  // メールを送信
  const mailOptions = {
    from: `"Mahargoyk 運営" <${gmailEmail}>`,
    to: email,
    subject: "認証コード",
    text: `あなたの認証コードは ${code} です。このコードは10分間有効です。`,
  };

  try {
    await transporter.sendMail(mailOptions);
    return { success: true };
  } catch (error) {
    console.error("メール送信エラー:", error);
    throw new functions.https.HttpsError(
      "internal",
      "メールの送信に失敗しました。"
    );
  }
});

/**
 * コードを検証し、ユーザーを新規登録する関数
 */
exports.verifyCodeAndRegister = functions.https.onCall(
  async (data, context) => {
    const email = data.email;
    const code = data.code;
    const password = data.password;

    if (!email || !code || !password) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "メールアドレス、コード、パスワードは必須です。"
      );
    }

    const docRef = db.collection("verificationCodes").doc(email);
    const doc = await docRef.get();

    if (!doc.exists) {
      throw new functions.https.HttpsError(
        "not-found",
        "認証コードが見つかりません。"
      );
    }

    const { code: savedCode, expiresAt } = doc.data();

    if (expiresAt.toMillis() < Date.now()) {
      throw new functions.https.HttpsError(
        "deadline-exceeded",
        "認証コードの有効期限が切れています。"
      );
    }

    if (savedCode !== code) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "認証コードが正しくありません。"
      );
    }

    try {
      // Firebase Authenticationにユーザーを作成
      const userRecord = await admin.auth().createUser({
        email: email,
        password: password,
      });

      // Firestoreにユーザー情報を保存
      await db.collection("users").doc(userRecord.uid).set({
        email: userRecord.email,
        created_at: admin.firestore.FieldValue.serverTimestamp(),
      });

      // 使用済みの認証コードを削除
      await docRef.delete();

      return { success: true, uid: userRecord.uid };
    } catch (error) {
      console.error("ユーザー作成エラー:", error);
      if (error.code === "auth/email-already-exists") {
        throw new functions.https.HttpsError(
          "already-exists",
          "このメールアドレスは既に使用されています。"
        );
      }
      throw new functions.https.HttpsError(
        "internal",
        "ユーザー登録に失敗しました。"
      );
    }
  }
);
