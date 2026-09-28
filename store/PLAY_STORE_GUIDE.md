# Flowsy: Google Play release guide

## What is ready

| Item | Location |
|---|---|
| Signed release bundle | `build/app/outputs/bundle/release/app-release.aab` |
| Upload keystore | `~/keystores/flowsy-upload-keystore.jks` |
| Keystore passwords | `android/key.properties` (git-ignored) |
| App icon 512x512 | `store/graphics/play-icon-512.png` |
| Feature graphic 1024x500 | `store/graphics/feature-graphic.png` |
| Privacy policy page | `hosting/privacy/index.html` |
| Account deletion page | `hosting/delete-account/index.html` |

Package name: `com.salmaelmaghawry.flowsy`. It is permanent after the first upload.

## 1. Back up the keystore now

Copy `~/keystores/flowsy-upload-keystore.jks` and `android/key.properties` to a password manager or private cloud drive.
With Play App Signing you can reset a lost upload key through Play support, but it takes days.

## 2. Publish the privacy and deletion pages

```bash
firebase deploy --only hosting --project push-notification-1cf6d
```

The URLs will be:

- Privacy policy: https://push-notification-1cf6d.web.app/privacy
- Account deletion: https://push-notification-1cf6d.web.app/delete-account

Also make sure the Firestore rules are live:

```bash
firebase deploy --only firestore:rules --project push-notification-1cf6d
```

## 3. Build a new release

Bump `version:` in `pubspec.yaml` for every upload (for example `1.0.1+2`). The number after `+` must always increase.

```bash
flutter build appbundle --release
```

## 4. Play Console setup

1. Create the app at https://play.google.com/console. App name **Flowsy**, default language English (United States), type App, Free.
2. Keep **Play App Signing** enabled (default) and upload the `.aab`.
3. New personal developer accounts must run a **closed test with at least 12 testers for 14 days** before production access. Start with Testing › Closed testing.

## 5. Store listing

> **Use the newer listing in `store/listing/`.** It has the final English and Arabic title, short and full descriptions, all within Play's limits. The new feature graphics are `store/graphics/feature-graphic.png` and `feature-graphic-ar.png`. Framed screenshots are made by `python3 store/tools/make_store_graphics.py` from raw captures in `store/screenshots/raw/en` and `raw/ar`. The text below is the older first draft.

**App name** (max 30)
```
Flowsy - Wallet Split
```

**Short description** (max 80)
```
Split your money into wallets, plan your spending, and track every pound.
```

**Full description**
```
Flowsy helps you know exactly where your money is and where it is going.

Add each place you keep money, like InstaPay, Vodafone Cash, your bank account, or cash at home, as its own wallet. Then plan what you will spend from each one, and Flowsy shows you what is really left.

WHAT YOU CAN DO
• Create wallets with custom names and colors
• See your total balance across all wallets at a glance
• Plan spending per wallet: rent, internet, groceries, anything
• Instantly see "In account", "I will spend", and "So I have"
• Record deposits and expenses with a full transaction history
• Lock the app with your fingerprint or face
• Arabic and English, with full right-to-left support
• Light and dark themes

PRIVATE BY DESIGN
• No ads and no tracking
• Your data is only visible to your account
• Delete your account and all data anytime from Settings
```

**Arabic listing (ar)**

App name:
```
فلوسي - تقسيم المحافظ
```
Short description:
```
قسّم فلوسك على محافظ، خطط لمصاريفك، وتابع كل جنيه.
```
Full description:
```
فلوسي بيساعدك تعرف فلوسك فين بالظبط ورايحة فين.

ضيف كل مكان بتحط فيه فلوس كمحفظة لوحدها، زي إنستاباي أو فودافون كاش أو حسابك في البنك أو الكاش اللي في البيت. وبعدين خطط هتصرف إيه من كل محفظة، وفلوسي هيوريك فاضل معاك كام فعلاً.

المميزات
• محافظ بأسماء وألوان تختارها
• رصيدك الكلي في كل المحافظ مرة واحدة
• خطط مصاريف كل محفظة: إيجار، نت، بقالة، أي حاجة
• شوف "في الحساب" و"هصرف" و"فاضل معايا" فوراً
• سجل الإيداعات والمصروفات مع سجل كامل للمعاملات
• اقفل التطبيق بالبصمة
• عربي وإنجليزي
• وضع فاتح وداكن

خصوصيتك أولاً
• بدون إعلانات أو تتبع
• بياناتك تظهر لحسابك فقط
• احذف حسابك وكل بياناتك في أي وقت من الإعدادات
```

**Graphics**
- App icon: `store/graphics/play-icon-512.png`
- Feature graphic: `store/graphics/feature-graphic.png`
- Phone screenshots: 2 to 8 images, taken on a phone or emulator. Suggested screens: home with wallets, wallet details with planned spending, add transaction, settings with app lock, and one in Arabic.

**Category:** Finance. **Contact email:** your developer email. **Privacy policy:** the privacy URL above.

## 6. App content forms

**Privacy policy:** https://push-notification-1cf6d.web.app/privacy

**Ads:** No, the app does not contain ads.

**App access:** All functionality requires sign-in. Create a test account in the app and give reviewers its email and password here.

**Content rating questionnaire:** Category "Utility, Productivity, Communication, or Other". Answer No to violence, sexual content, language, drugs, gambling, and user interaction/sharing. Expected rating: Everyone / PEGI 3.

**Target audience:** 18 and over. The app is not designed for children.

**News app:** No. **Government app:** No. **Health apps:** None.

**Financial features declaration:** The app does not move real money, give loans, or connect to banks. It is a personal budgeting tracker, so pick the budgeting or "none of these" option that the form offers.

**Data safety**

| Question | Answer |
|---|---|
| Does the app collect or share user data? | Yes, collects. No sharing. |
| Encrypted in transit? | Yes |
| Can users request deletion? | Yes |
| Delete account URL | https://push-notification-1cf6d.web.app/delete-account |

Data types to declare:

| Data type | Collected | Shared | Optional | Purpose |
|---|---|---|---|---|
| Personal info › Email address | Yes | No | Required | Account management, App functionality |
| Financial info › Other financial info (wallets, balances, transactions) | Yes | No | Required | App functionality |

Do not declare biometrics. Android performs the check on the device and the app never receives the data.

## 7. Release

1. Closed testing › Create release › upload the `.aab` › add release notes.
2. Add at least 12 testers by email list, share the opt-in link, and keep them opted in for 14 days.
3. Apply for production access from the Dashboard, then promote the release to Production.
