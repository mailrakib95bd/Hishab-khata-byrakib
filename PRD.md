# Hishab Khata BD
## Product Requirements Document (Flutter / Dart Native)

| | |
|---|---|
| **Document status** | Draft v1.0 — Migration PRD |
| **Source of truth** | Existing Hishab Khata BD JavaScript/PWA codebase (snapshot `Hishab-Khata-Refactored-2026-10-07`) |
| **Target** | Flutter (Dart) native app — Android first, iOS-ready architecture |
| **Language of product** | Bangla-first (Bengali UI, Bengali numerals), English fallback |
| **Audience** | Flutter/Dart AI coding agents and engineers |

> **নিয়ম (Reading rule):** এই PRD-তে `[SRC]` চিহ্ন মানে আচরণটি সরাসরি বিদ্যমান কোড/টেস্ট থেকে নেওয়া। `[NOTE]` মানে কোডে পাওয়া অসঙ্গতি/সীমাবদ্ধতা, যা **বদল না করে** হুবহু রাখতে হবে। `[OPEN]` মানে মালিকের সিদ্ধান্ত দরকার — agent নিজে সিদ্ধান্ত নেবে না। কোনো ফিচার এখানে না থাকলে সেটি বর্তমান অ্যাপেও নেই।

---

## 1. Executive Summary

Hishab Khata BD ("হিসাব-খাতা") একটি বাংলা-ভাষী ব্যক্তিগত ও পারিবারিক আর্থিক ব্যবস্থাপনা অ্যাপ। বর্তমানে এটি React (UMD) + plain JavaScript PWA, Capacitor দিয়ে Android WebView-এ প্যাকেজ করা। এই PRD সেই অ্যাপটিকে **WebView ছাড়া পূর্ণ Flutter native** অ্যাপে পুনর্নির্মাণের স্পেসিফিকেশন।

অ্যাপের মূল মডিউল: ব্যক্তিগত আয়-ব্যয় খাতা (ক্যাশ লেজার, মাধ্যম/অ্যাকাউন্ট, ট্রান্সফার), বাজেট, দেনা-পাওনা, রিপোর্ট, সার্চ, ক্যালেন্ডার (ইংরেজি + বাংলা + উম্মুল কুরা হিজরি), বিশেষ দিবস, টাস্ক, ট্যাক্স, খসড়া খাতা (Khasra Khata), Family Bazar (বহু-অ্যাকাউন্ট পারিবারিক বাজার), Family Planning (লক্ষ্যভিত্তিক পারিবারিক সঞ্চয় ও Owner-অনুমোদন), অ্যাডমিন কনটেন্ট (নোটিশ, দৈনিক বার্তা, FAQ, অ্যাডমিন টাস্ক, অ্যাডমিন বিশেষ দিবস), Firebase Auth + Firestore ক্লাউড ব্যাকআপ/সিঙ্ক।

## 2. Product Vision

"জীবনের হিসাব থেকে আখিরাতের হিসাব" (অ্যাপের বিদ্যমান tagline `APP_TAGLINE`)। একটি অফলাইন-প্রথম, বাংলা-প্রথম, পরিবারকেন্দ্রিক হিসাব-খাতা যেখানে ব্যক্তিগত হিসাব ডিভাইসে নিরাপদ থাকে এবং পরিবারের সাথে শেয়ার করা অংশ কঠোর role/permission দিয়ে সুরক্ষিত।

## 3. Product Goals

1. বর্তমান সব ফিচার ও business rule Flutter native-এ **১০০% সংরক্ষণ**।
2. Offline-first: মূল হিসাব ইন্টারনেট ছাড়া কাজ করবে; সংযোগ ফিরলে স্বয়ংক্রিয় sync।
3. WebView-মুক্ত native UI, সঠিক Android back-stack আচরণ।
4. মডুলার, টেস্টযোগ্য কোডবেস (একটি Dart ফাইলে শত-শত লাইন নয়)।
5. JS test suite-এর business rule Dart test হিসেবে পুনরুৎপাদন।

## 4. Non-Goals

- নতুন ফিচার উদ্ভাবন (যেমন আলাদা Notifications feed, রসিদ আপলোড, Finance Ledger-এ Family Planning মিরর, Plan Settings স্ক্রিন — README অনুযায়ী এগুলো সচেতনভাবে বাদ)।
- Task-এ amount/টাকা ফিল্ড পুনঃযোগ (সরানো হয়েছে; `tests/task-amount.test.js`)।
- বিদ্যমান role/permission ছাড়া নতুন permission সিস্টেম।
- Cloud Functions/push server (বর্তমানে নেই)।
- WebView-ভিত্তিক রেন্ডারিং।

## 5. Target Users

| ব্যবহারকারী | বিবরণ |
|---|---|
| Guest/Local ব্যবহারকারী | লগইন ছাড়া শুধু ডিভাইসে হিসাব রাখে |
| Signed-in ব্যবহারকারী | Google বা Email/Password; ক্লাউড ব্যাকআপ/সিঙ্ক |
| Family Owner / Admin / Member / Viewer | Family Bazar ও Family Planning-এর role |
| Primary App Admin | একটি নির্দিষ্ট UID/Email (কনফিগারেশন); গ্লোবাল কনটেন্ট পরিচালনা |

## 6. Core Principles

1. **Source of truth = বর্তমান আচরণ।** বাদ/পরিবর্তন/যোগ নয়।
2. **Local-first:** প্রতিটি মিউটেশন আগে লোকালে, পরে ক্লাউডে।
3. **Server-enforced security:** UI লুকানো নিরাপত্তা নয়; Firestore Rules আসল সীমা।
4. **Official money rule:** Owner/Admin verify না করা contribution official collected-এ গণনা হয় না (§24)।
5. **Bangla-first:** বাংলা অঙ্ক, `৳` প্রতীক, দক্ষিণ-এশীয় গ্রুপিং (`১,২৩,৪৫৬`)।
6. **Back = এক ধাপ পেছনে**, কখনো সরাসরি Dashboard নয়।

---

## 7. Existing Application Audit

### 7.1 কোড-মডিউল ম্যাপ

| JS ফাইল | দায়িত্ব | Flutter-এ গন্তব্য |
|---|---|---|
| `app/01-foundation.js` | ধ্রুবক, ফরম্যাটার, ব্যালেন্স ইঞ্জিন, বাংলা তারিখ, reminder preset, `useBackOverlay` | `core/`, `features/ledger/domain` |
| `app/02-main-app.js` | `App()` — সব state, persist, auth settle, sync, reminder loop, Family Bazar→ledger sync | repositories + Riverpod notifiers |
| `app/03-auth-header.js` | Login, PIN lock, Header, Quick task, TaskForm | `features/auth`, `features/tasks` |
| `app/04-dashboard-reports.js` | Dashboard, Timeline, Reports, Monthly review | `features/dashboard|timeline|reports` |
| `app/05-search-charts.js` | Search, TxRow, charts, BottomNav | `features/search`, `widgets/charts` |
| `app/06-family-admin.js` | Legacy FamilyView, AdminPanel, SpecialDay forms, Bulk import | `features/family_legacy`, `features/admin` |
| `app/07-notifications-tax.js` | NotificationCenter, Hamburger, FAQ, Tax | `features/notifications`, `features/tax` |
| `app/08-accounts-calendar.js` | Dynamic accounts, Calendar | `features/accounts`, `features/calendar` |
| `app/09-debts-transactions.js` | Debts, Transfers, TransactionForm | `features/debts|transfers|ledger` |
| `app/10-settings-modals.js` | Budget, Category manager, Settings, ModalShell | `features/budget|settings` |
| `family-bazar-core.js` | Family Bazar pure logic | `features/family_bazar/domain` |
| `family-planning-core.js` | Family Planning pure logic | `features/family_planning/domain` |
| `family-bazar.js` | Family Bazar + Planning UI (sheets) | `features/family_bazar/presentation`, `features/family_planning/presentation` |
| `khasra-khata.js` | খসড়া খাতা logic + UI + print/PDF | `features/khasra` |
| `hijri-ummalqura.js` | Umm al-Qura table + Dhaka sunset | `core/calendar/hijri_ummalqura.dart` |
| `firebase-init.js` | Firestore data layer (`window.FB`) | `data/firebase/*` |
| `firestore.rules` | সিকিউরিটি রুলস | `firebase/firestore.rules` (অপরিবর্তিত রাখা) |
| `sw.js`, `manifest.json`, `capacitor.config.json` | PWA/APK প্যাকেজিং | অপ্রযোজ্য (Flutter নেটিভ) |
| `tests/*.test.js` | Business-rule প্রমাণ | `test/` (Dart) — §40 |

### 7.2 বিদ্যমান আচরণে পাওয়া অসঙ্গতি `[NOTE]` (হুবহু রাখতে হবে)

| # | পর্যবেক্ষণ | PRD সিদ্ধান্ত |
|---|---|---|
| N1 | Calendar গ্রিডে শুধু বিশেষ দিবস (ব্যক্তিগত + অ্যাডমিন) দেখায়; Task/Reminder দেখায় না | Calendar-এ task যোগ করা যাবে না। Notification Center-এর "রিমাইন্ডার" ট্যাবে আলাদা তালিকা আছে |
| N2 | হিজরি সূর্যাস্ত-পরিবর্তন শুধু "আজকের" হিজরি তারিখে (`islamicEffectiveDate`)। ক্যালেন্ডারের ঘর সাধারণ Gregorian→Hijri রূপান্তর | হুবহু রাখা |
| N3 | Task/Tax-এর `repeat` ফিল্ড সংরক্ষিত ও দেখানো হয়, কিন্তু স্বয়ংক্রিয় পুনঃনির্ধারণ কোডে নেই | `[OPEN] D1` — মালিক সিদ্ধান্ত না দিলে repeat শুধু data field |
| N4 | Reminder লুপ ২০ সেকেন্ড; একই দিনে একবার (`remindedAt`) | নেটিভ scheduled notification একই semantic রাখবে |
| N5 | Task সীমা `MAX_TASKS = 10` (সকল টাস্ক, done সহ) | রাখতে হবে |
| N6 | Family Plan `paused`/`cancelled`, `expenseApprovalRequired`, pending expense মডেল/rules-এ আছে, UI-তে নেই | মডেলে রাখতে হবে; UI বানানো যাবে না |
| N7 | Family Bazar থেকে sync হওয়া লেনদেনে `method` নেই → ব্যালেন্স দেখানোয় "ক্যাশ" ধরা হয়, কিন্তু overdraft-চেকে ধরা হয় না | হুবহু রাখা |
| N8 | Khasra Khata শুধু লোকাল; ক্লাউড/JSON ব্যাকআপে যায় না | হুবহু রাখা |
| N9 | ব্যক্তিগত ডেটা `users/{uid}` একক ডকুমেন্ট; ১.৫s debounce push; last-write-wins | হুবহু রাখা (§31) |
| N10 | Plan মিউটেশন read-modify-write (transaction ছাড়া) | আচরণ একই; Flutter-এ Firestore transaction দিয়ে বাস্তবায়ন অনুমোদিত (race কমায়, ফলাফল-আচরণ বদলায় না) |
| N11 | Contribution verify-তে `received < claimed → partial`, নইলে `approved`; credit = `receivedAmount` (claimed-এর বেশিও হতে পারে) | হুবহু রাখা |
| N12 | README বলে "ব্যক্তিগত তালিকা" সরানো, কিন্তু ফ্যামিলি ট্যাবে `FamilyView` (সদস্য + বাজার-আইটেম) এখনো আছে | existing হিসেবে document (§25.6) |
| N13 | PIN `DEVICE_KEY`-এ plain সংরক্ষিত, শুধু ডিভাইসে, ক্লাউডে যায় না | আচরণ একই; Flutter-এ secure storage-এ রাখা বাধ্যতামূলক হার্ডেনিং (ফিচার বদল নয়) |
| N14 | Firebase API config ও Primary Admin UID/Email সোর্সে হার্ডকোড | PRD-তে মান কপি নেই; কনফিগ (`firebase_options.dart`, `AppConfig.primaryAdminUid/Email`) হিসেবে বহন |

---

## 8. Complete Feature Inventory

| ID | ফিচার | ধরন | অংশ |
|---|---|---|---|
| F01 | Dashboard (হোম) | Personal | §11 |
| F02 | আয়-ব্যয় লেজার (Transaction CRUD, undo) | Personal | §12 |
| F03 | আয়/ব্যয় ক্যাটাগরি (custom, migrate) | Personal | §12.5 |
| F04 | ব্যালেন্স (মোট, মাধ্যম, ডায়নামিক অ্যাকাউন্ট) | Personal | §12.6 |
| F05 | ট্রান্সফার ও ইতিহাস | Personal | §12.7 |
| F06 | ডায়নামিক অ্যাকাউন্ট | Personal | §12.8 |
| F07 | বাজেট (মাসিক + খাতভিত্তিক) | Personal | §13 |
| F08 | Timeline | Personal | §11.8 |
| F09 | দেনা-পাওনা (repayment, statement) | Personal | §14 |
| F10 | রিপোর্ট + মাসিক পর্যালোচনা | Personal | §15 |
| F11 | Search (লেনদেন + repayment) | Personal | §16 |
| F12 | Calendar (En + Bn + Hijri) | Personal | §17 |
| F13 | Hijri (Umm al-Qura + ঢাকা সূর্যাস্ত) | Core | §18 |
| F14 | Special Days (ব্যক্তিগত + অ্যাডমিন + recurring Hijri + bulk) | Mixed | §19 |
| F15 | Tasks (quick + detailed + admin task) | Mixed | §20 |
| F16 | Tax Management | Personal | §21 |
| F17 | খসড়া খাতা (Khasra Khata) | Local | §22 |
| F18 | Family Bazar | Family | §23 |
| F19 | Family Planning | Family | §24 |
| F20 | Family Members/Roles/Invitations | Family | §25 |
| F21 | Product & Price Management | Family | §26 |
| F22 | Notifications & Reminders | Mixed | §27 |
| F23 | Auth (Guest, Google, Email) + PIN lock | Core | §28 |
| F24 | Settings (theme, backup, CSV, PIN, clear, audit) | Core | §28.4 |
| F25 | Cloud backup/sync/restore | Core | §30–31 |
| F26 | Admin Panel (notices/daily/special/task/FAQ) | Admin | §19.4, §27 |
| F27 | Family Spending (বাজার + অন্যান্য) | Family | §23.9 |
| F28 | Personal↔Family Bazar auto-sync | Family | §23.8 |
| F29 | Legacy FamilyView (personal members + bazar items) | Personal | §25.6 |

## 9. Information Architecture

```
App
├─ Identity layer: Guest | Firebase user (uid)  → data namespace per identity
├─ Device layer (never synced): PIN, theme, device flags
├─ Personal data (per identity): transactions, budget, categories, accounts,
│   transfers, debts, tasks, specialDays, taxes, familyMembers(legacy), bazarItems(legacy),
│   userAccounts, auditLog, read/dismiss/completed trackers
├─ Local-only per identity: Khasra drafts
├─ Global shared (read: any signed-in; write: Primary Admin): notices, dailyMessages,
│   adminSpecialDays, adminTasks, faq
└─ Family data (Firestore, role/permission gated): families/* , invitations/*
```

## 10. Navigation Architecture

বর্তমান কোড অডিট করে প্রাপ্ত চূড়ান্ত কাঠামো `[SRC: BottomNav, Header, HamburgerMenu, App]`:

```
Shell (Header + body + BottomNav + FAB + banners)
├─ Header: ☰ Menu | ব্যালেন্স (নাম+ব্যালেন্স) | 📅 Calendar | 📋 Tasks (n/10 badge) | 🔔 Notifications (unread badge) | ⚙ Settings
├─ BottomNav (6): হোম · টাইমলাইন · দেনা · ফ্যামিলি · রিপোর্ট · খুঁজুন
│   ├─ হোম (Dashboard)
│   ├─ টাইমলাইন
│   ├─ দেনা  (FAB = নতুন দেনা-পাওনা)
│   ├─ ফ্যামিলি: segmented [🛒 ফ্যামিলি বাজার (embedded) | 📝 ব্যক্তিগত তালিকা (legacy)]
│   ├─ রিপোর্ট
│   └─ খুঁজুন
├─ FAB (শুধু হোম/টাইমলাইন/দেনা ট্যাবে): লেনদেন যোগ (দেনা ট্যাবে: দেনা-পাওনা যোগ)
├─ ☰ Menu (অর্ধ-স্ক্রিন drawer, ডান অর্ধ = tap-to-close backdrop)
│   ├─ ⚙️ অ্যাডমিন প্যানেল (শুধু Primary Admin)
│   ├─ প্রশ্ন ও উত্তর (FAQ)
│   ├─ ট্যাক্স ব্যবস্থাপনা
│   ├─ অ্যাকাউন্ট ব্যবস্থাপনা (dynamic accounts)  
│   ├─ 🛒 ফ্যামিলি বাজার (fullscreen; invite badge)
│   ├─ 📋 খসড়া খাতা
│   ├─ হিজরি ক্যালেন্ডার (= Calendar)
│   ├─ নোটিফিকেশন (unread badge)
│   ├─ সেটিংস
│   └─ footer: নাম/tagline/Version/ওয়েবসাইট/Privacy Policy
├─ Dashboard-এর কার্ড: মাসিক বাজেট → BudgetModal; দেনা-পাওনা → দেনা ট্যাব; শীর্ষ-৩ খাত "বিস্তারিত" → রিপোর্ট; স্থানান্তর/ইতিহাস
└─ Family Bazar (fullscreen/embedded): BottomTabs
    ├─ হোম · বাজার · রিপোর্ট · পরিবার · আরও
    ├─ Header: পরিবার-সুইচার, 🎯 Family Planning (pending-approval badge), 🔍 খুঁজুন, ✕
    ├─ আরও: খুঁজুন · Family Planning · পণ্য তালিকা · ক্যাটাগরি · মাসিক বাজেট · পরিবারের সেটিংস · পরিবার বদলান
    ├─ FAB (হোম/বাজার ট্যাবে, লেখার অনুমতি থাকলে): বাজার যোগ
    └─ Sheets stack: purchase, purchase-details, product, member, invite, invite-details, settings, switcher, create-family,
       plan-home, plan-list, plan-detail, plan-create, plan-approval, plan-contribute, plan-verify, plan-members,
       plan-expenses, plan-mine, plan-owner-center, plan-history, plan-edit, plan-complete
```

Flutter প্রয়োগ: `go_router` (ShellRoute) + Family Bazar-এর ভেতরে নিজস্ব **sheet-stack navigator** (§10.3)। Calendar/Tasks/Notifications/Settings Header থেকে সরাসরি খোলে; Menu থেকে খুললে বন্ধ করলে Menu-তে ফেরে (`menuOrigin` নিয়ম, §10.1)।

### 10.1 Panel-origin নিয়ম `[SRC: menuOriginRef/closeMenuPanel]`
Menu থেকে খোলা প্যানেল (Admin/Tax/Accounts/FAQ/Calendar/Notifications/Settings/Khasra/Family Bazar) বন্ধ বা back করলে **Menu-তে ফেরে**; Header-আইকন থেকে খোলা হলে বন্ধ করলে সরাসরি আগের স্ক্রিন (Dashboard)।

### 10.2 Overlay-back stack `[SRC: useBackOverlay, popstate handler]`
প্রতিটি overlay (modal/sheet/dropdown) ঠিক এক ধাপ back-entry নেয়। Back প্রেস করলে শীর্ষ overlay বন্ধ হয়; অ্যাপ বন্ধ বা Dashboard-এ লাফ নয়। শীর্ষ-স্তরের modal-stack অগ্রাধিকার (উপর থেকে নিচে): Login → TransferHistory → Transfer → AddDebt → DebtDetail (ভেতরের edit/repay/statement আগে) → Calendar (ভেতরের বিস্তারিত আগে) → EditTx → Settings → Budget → AddTx।


### 10.3 Family Bazar sheet-stack Back (অবশ্যই সংরক্ষিত) `[SRC: useSheetBack, ctx.openSheet]`
- Family Bazar-এ সব দ্বিতীয়-স্তরের স্ক্রিন **sheet** (`ctx.openSheet({type,…})`)। `sheets` একটি **stack**; `openSheet` একটি এন্ট্রি push করে, `close` ঠিক **এক স্তর pop** করে। প্রতিটি push ব্রাউজার-হিস্ট্রির সমতুল্য ১টি back-entry নেয় (`useSheetBack(depth)`), তাই Android system back ও UI-র "←" একই কাজ করে।
- উদাহরণ চেইন: `Plan List → Plan Detail → Contribute/Verify/Edit ফর্ম`; `বাজার তালিকা → Purchase Details → Purchase ফর্ম`; `পণ্য তালিকা → Product Sheet`; `পরিবার → Member → (সম্পাদনা)`।
- **Back একবারে একধাপ:** ফর্ম → Details → List → (stack খালি → Family Bazar ট্যাব)। **কখনো সরাসরি Dashboard বা অ্যাপ-বাইরে নয়।**
- সংশোধন/সংরক্ষণ সফল হলে ওই sheet-টি pop হয় (বাকি stack অক্ষত)।
- Stack খালি থাকা অবস্থায় back: Family Bazar মডিউল বন্ধ হয়, §10.1 panel-origin নিয়মে (Menu থেকে খুললে Menu-তে, নইলে আগের স্ক্রিনে)। `[VERIFY]` ট্যাব-স্তরে (হোম ছাড়া অন্য ট্যাব থেকে) back কী করে তা `family-bazar.js` ~১৮৫৪–২০০৯ লাইনে নিশ্চিত করে অনুসরণ করুন।
- Flutter বাস্তবায়ন: `SheetStackNotifier` + `PopScope`/`WillPopScope` (বা `Navigator` নেস্টেড-stack) — `canPop` যতক্ষণ stack ≠ খালি। নেস্টেড `Navigator` ব্যবহার করলে প্রতিটি sheet একটি `Route`।
- একই নীতি মূল অ্যাপের modal-stack-এ (§10.2) ও Khasra (`editor → list`), Debt (`detail → edit/repay/statement`), Calendar (`একক-এন্ট্রি → তারিখ-বিস্তারিত → মাস`)-এ।

## 11. Dashboard (F01, F08)

### 11.1 উদ্দেশ্য
এক স্ক্রিনে মোট সম্পদ, এই মাসের অবস্থা, বাজেট, ঋণ, ওয়ালেট, শীর্ষ খাত ও সাম্প্রতিক লেনদেন।

### 11.2 নতুন ব্যবহারকারী (Onboarding state)
শর্ত: `transactions.isEmpty && debts.isEmpty && budget <= 0`। দেখাবে অভিবাদন + তিনটি বাটন: "প্রথম আয় যোগ করুন" (Income form), "প্রথম খরচ যোগ করুন" (Expense form), "মাসিক বাজেট সেট করুন" (BudgetModal)।

### 11.3 গণনা `[SRC: Dashboard stats]`
| মান | সূত্র |
|---|---|
| `allIncome/allExpense` | সব লেনদেনের যোগফল |
| **মোট বর্তমান সম্পদ** `availableBalance` | `allIncome − allExpense` (ট্রান্সফার ও ঋণ-repayment এতে অন্তর্ভুক্ত নয়) |
| `monthIncome/monthExpense` | `date`-এর `YYYY-MM` = বর্তমান মাস |
| `monthSavings` | `monthIncome − monthExpense` |
| `lastMonthExpense` | গত মাসের ব্যয় |
| `momChangePct` | `lastMonthExpense>0 ? round((monthExpense−last)/last×100) : null` |
| `savingsRatePct` | `monthIncome>0 ? round(savings/income×100) : null` |
| `budgetPct` | `budget>0 ? min(999, round(monthExpense/budget×100)) : null` |
| `budgetLeft` | `budget − monthExpense` |
| `daysLeftInMonth` | `max(1, daysInMonth − dayOfMonth + 1)` |
| **আজ নিরাপদ খরচ** | `budget>0 ? max(0, budgetLeft/daysLeftInMonth) : null` |
| `monthPctElapsed` | `round(dayOfMonth/daysInMonth×100)` |
| শীর্ষ ৩ খাত | চলতি মাসের ব্যয় ক্যাটাগরিতে group, desc, প্রথম ৩ |
| `last7Expense` | `today−6 … today` ব্যয় যোগ |
| debtStats | সব `remaining>0` দেনার যোগফল: `receivable`, `payable`, `net = receivable − payable` |
| bazarSpendThisMonth | legacy `bazarItems` (`purchased`, চলতি মাস) এর `computeBazarTotal` যোগফল; >0 হলে কার্ড দেখায় |

### 11.4 আর্থিক স্বাস্থ্য স্কোর `[SRC]`
```
score = 50
if monthIncome>0: score += clamp(round((savings/income)*50), -25, +25)
if budget>0: budgetPct<=70 → +15 ; <=100 → +5 ; else → -20
if payable>0 && availableBalance>0: score -= round(debtRatio*15)   // debtRatio = payable/(availableBalance+payable)
score = clamp(round(score), 0, 100)
```
Label: ≥75 "চমৎকার অবস্থায় আছেন"; ≥55 "ভালো অবস্থায় আছেন"; ≥35 "মোটামুটি অবস্থায় আছেন"; নইলে "সতর্ক হওয়া দরকার"। রং: success / success-mid / gold / danger।
সূচক সারি (🟢🟡🔴): **বাজেট** (না থাকলে 🟡 "সেট করা হয়নি"; ≤70 🟢 "ভালো"; ≤100 🟡 "নজরে রাখুন"; >100 🔴 "ছাড়িয়ে গেছে"), **সঞ্চয়** (null 🟡 "তথ্য নেই"; ≥20 🟢; ≥0 🟡 "মোটামুটি"; <0 🔴 "ঘাটতি"), **দেনা** (payable≤0 🟢 "কোনো দেনা নেই"; ratio<0.3 🟢; <0.6 🟡; নইলে 🔴 "চাপে আছেন")।

### 11.5 Insights (সর্বোচ্চ ২টি, ক্রমানুসারে) `[SRC]`
1. খাতভিত্তিক বাজেটে কোনো খাতের ব্যবহার ≥80% → (≥100% ⚠️ "সতর্কতা" / 🟡 "নজরে রাখুন"): "{খাত} খাতে নির্ধারিত বাজেটের N% ইতিমধ্যে শেষ হয়েছে।" (সর্বোচ্চ pct-এর একটি)
2. যে খাতে `গত মাস>0 && এ মাস > গত×1.15 && (এ−গত) ≥ 200` — সর্বোচ্চ % বৃদ্ধির খাত: "{খাত} খাতে খরচ গত মাসের তুলনায় N% বেড়েছে।"
3. `safeSpendToday != null && last7Expense/7 <= safeSpendToday` → "গত ৭ দিনে আপনার গড় দৈনিক খরচ বাজেটের নিরাপদ সীমার মধ্যে রয়েছে।"
4. `momChangePct < -5` → "গত মাসের তুলনায় এই মাসে আপনার ব্যয় N% কম হয়েছে।"

### 11.6 অন্যান্য ব্লক
- **তারিখ-সারি:** `{বার}, {তারিখ} · {বাংলা তারিখ} বঙ্গাব্দ · {হিজরি তারিখ} হিজরি` — হিজরি = `gregorianToHijri(islamicEffectiveDate(now))` (সূর্যাস্ত-সচেতন), ইংরেজি/বাংলা মধ্যরাতে বদলায়।
- **অভিবাদন:** স্থির `আসসালামু আলাইকুম। 😊 {profileName ?? "স্বাগতম"}` (সময়ভেদে ভিন্ন নয়)।
- **Header শিরোনাম:** `dashboardTitle(name)` — নাম বাংলা অক্ষরে শেষ হলে `{নাম}ের খাতা`, নইলে `{নাম} এর খাতা`; নাম না থাকলে "আমার খাতা"।
- **PulseBars:** আয়/ব্যয়/সঞ্চয় আপেক্ষিক বার।
- **বাজেট কার্ড:** বার (ভরাট ≤100% clamp); লেবেল "N% খরচ হয়েছে" + ≥100 "⚠️ বাজেট শেষ" / ≥90 "⚠️ ৯০%+" / ≥70 "⚠️ ৭০%+"; "অবশিষ্ট ৳X" বা "বাজেট ছাড়িয়েছে ৳X"; "মাসের N% দিন পার হয়েছে"; "আজ নিরাপদ খরচ: ৳X"; বাজেট না থাকলে empty-hint। ট্যাপ → BudgetModal।
- **আজকের হিসাব:** আজকের আয়/ব্যয়।
- **ঋণ সতর্কতা:** `debtDueInfo ∈ {overdue, today, soon}` সর্বোচ্চ ৩টি, `daysLeft` ASC; প্রতিটি ট্যাপে দেনা-পাওনা খোলে।
- **ট্যাক্স সতর্কতা:** unpaid ট্যাক্সে একই urgency window (overdue/today/soon ≤৩ দিন), সর্বোচ্চ ৩টি।
- **দেনা-পাওনা সারাংশ কার্ড:** মোট প্রাপ্য, মোট করজে হাসানা/দেনা, নিট।
- **আমার টাকা:** ওয়ালেট গ্রিড (সর্বোচ্চ ৬; `hasActivity || opening`), প্রতি ওয়ালেটে আইকন+রং, বোতাম "↔ স্থানান্তর", "ইতিহাস"।
- **শীর্ষ ৩ খরচের খাত** + "বিস্তারিত ›" → রিপোর্ট।
- **সাম্প্রতিক লেনদেন:** `date desc, createdAt desc`-এ ৫টি; ট্যাপে edit; empty state "এখনো কোনো লেনদেন…"।

### 11.7 Quick actions
FAB (+): লেনদেন যোগ (Dashboard/Timeline), নতুন দেনা-পাওনা (Debts)। অন্য ট্যাবে FAB নেই।

### 11.8 Timeline (F08) `[SRC]`
- গত ৭ দিন (আজ সহ) শুধু (`windowStart = today−6`)।
- ফিল্টার চিপ: সব / আয় / ব্যয়।
- **running balance:** সব লেনদেন `date asc, createdAt asc` ক্রমে ক্রমযোজিত (আয় +, ব্যয় −); প্রতিদিনের শেষ লেনদেনের running balance = "জমা" দিনের শেষ ব্যালেন্স।
- দিনের গ্রুপ: তারিখ+বার, `dayNet` (সব লেনদেনের নিট, ফিল্টার-নিরপেক্ষ), "জমা {dayEndBalance}"; আইটেম নতুন→পুরনো।
- হেডার: "আজ খরচ হয়েছে ৳X · জমা আছে ৳Y" (Y = সব-সময়ের ব্যালেন্স)।
- Empty: "গত ৭ দিনে দেখানোর মতো লেনদেন নেই।"
- ট্যাপ → edit।

### 11.9 Dashboard — Feature Spec Summary
**Functional:** §11.2–11.8। **Business Rules:** সূত্রসমূহ হুবহু। **Data:** transactions, debts, taxes, accountOpening, transfers, budget, categoryBudgets, bazarItems(legacy), profileName। **Permission:** সবাই (guest সহ)। **Offline:** পুরোপুরি লোকাল। **Sync:** পড়ার সময় কিছু নয়; দেখানো মানগুলো লোকাল state থেকে। **Error:** লোড ব্যর্থ হলে সম্পূর্ণ-স্ক্রিন লোডার ("খাতা খোলা হচ্ছে…") পরে empty state; storage write ব্যর্থ হলে `saveErr` banner "সংরক্ষণে সমস্যা হয়েছে…"। **Acceptance:** (১) সব সূত্র §11.3 অনুযায়ী Dart unit test-এ মেলে; (২) ৩০০০+ লেনদেনে এক-ফ্রেমের বেশি jank নেই (memoized/stat-cache); (৩) সূর্যাস্তের পরে হিজরি তারিখ পরের দিনের মান দেখায়, ইংরেজি/বাংলা নয়।

---
## 12. Income & Expense Ledger (F02–F06)

### 12.1 Transaction মডেল `[SRC]`
`id, type("income"|"expense"), amount(>0), category(key), date("YYYY-MM-DD"), note, method(key), accountId?, createdAt(ms)`; Family Bazar sync-এ অতিরিক্ত: `familyPurchaseId, familyId, source:"family-bazar"`; legacy: `familyMemberId, bazarItemId`।

### 12.2 Add/Edit ফর্ম
- ফিল্ড: ধরন (আয়/ব্যয়, presetType থেকেও), পরিমাণ, ক্যাটাগরি (ধরন অনুযায়ী তালিকা), তারিখ (ডিফল্ট আজ), নোট, মাধ্যম (ক্যাশ/ব্যাংক/বিকাশ/নগদ/রকেট/কার্ড), ঐচ্ছিক ডায়নামিক `accountId`।
- **Quick amount chips:** ৫০, ১০০, ২০০, ৫০০, ১০০০ — প্রতিটি ট্যাপে বর্তমান পরিমাণে যোগ হয়।
- **Validation:** ক্যাটাগরি বৈধ তালিকায় থাকতে হবে; পরিমাণ > 0 ("সঠিক পরিমাণ লিখুন"); তারিখ আবশ্যক ("তারিখ নির্বাচন করুন"); **ব্যয়ে মাধ্যমের ব্যালেন্স না থাকলে** ব্লক: "⚠️ আয় করুন — {মাধ্যম}-এ এত টাকা নেই" (সূত্র §12.6 `accountBalanceExcluding`, edit-এ নিজের পুরনো প্রভাব বাদ)। আয়ে ব্যালেন্স-চেক নেই। `[NOTE]` চেকটি শুধু legacy `method`-এর উপর; dynamic `accountId`-এর ব্যয়-চেক নেই।
- **Delete:** edit ফর্ম থেকে; **৬ সেকেন্ডের Undo banner** ("এন্ট্রি মুছে ফেলা হয়েছে" + "ফিরিয়ে আনুন") — মুছে যাওয়া আইটেম আগের index-এ ফেরে; audit log-এ এন্ট্রি: `লেনদেন মুছে ফেলা হয়েছে: আয়/ব্যয় ৳X (তারিখ)`। Undo buffer একটিই (সর্বশেষ)।
- **নিশ্চিতকরণ:** লেনদেন মোছায় আলাদা confirm dialog নেই (Undo-ই সুরক্ষা)।
- Flutter: modal bottom-sheet (fullscreen on small), `Form` + Bengali digit-aware `TextInputFormatter` (বাংলা অঙ্ক ইনপুট গ্রহণ → `parseNum`)।

### 12.3 Business Rules
1. আয় ব্যালেন্স বাড়ায়, ব্যয় কমায়।
2. Family Bazar-সূত্রের লেনদেন (`familyPurchaseId != null`) ব্যবহারকারী edit/delete করতে পারে এমন কোনো বিশেষ ব্লক কোডে নেই; তবে পরের purchase-sync তা ওভাররাইট করতে পারে `[NOTE]`।
3. Bulk CSV import: §28.4।
4. পরিমাণ নির্ভুলতা: Dashboard-এ `round`; ফর্ম `parseFloat`।

### 12.4 Data / Permission / Offline / Sync / Error / Acceptance
**Data:** `transactions[]` ব্যবহারকারীর ডকুমেন্টে। **Permission:** সকল (guest সহ)। **Offline:** সম্পূর্ণ। **Sync:** প্রতিটি মিউটেশন → লোকাল persist (তাৎক্ষণিক) → ক্লাউড push (১.৫s debounce, §31)। **Error:** persist ব্যর্থ → `saveErr` banner; ক্লাউড push ব্যর্থ → `syncStatus=error`, `pendingChanges++`। **Acceptance:** CRUD + undo + balance-block Dart test; edit-এ নিজের পুরনো প্রভাব বাদ দিয়ে ব্যালেন্স-চেক।

### 12.5 Income/Expense Category (F03)
- **ডিফল্ট ব্যয় (১২):** খাবার🍚, বাসা ভাড়া🏠, যাতায়াত🚌, মোবাইল/নেট📱, শিক্ষা📚, চিকিৎসা🏥, কেনাকাটা🛍️, ফ্যামিলি👪, ভ্রমণ✈️, বিল🧾, দান🤲, অন্যান্য🔧 (key: food, home, transport, mobile, education, health, shopping, family, travel, bill, donation, other_expense)।
- **ডিফল্ট আয় (৬):** দৈনিক/বেতন💰(salary), ব্যবসা💼(business), হাদিয়া🎁(gift), বিনিয়োগ📈(investment), বিল🧾(bill_income), অন্যান্য🔧(other_income)।
- ডিফল্ট ক্যাটাগরির জন্য কাস্টম SVG আইকন; কাস্টম ক্যাটাগরি emoji (৩৬টি পছন্দ `CAT_ICON_CHOICES`)।
- **Custom:** key = `custom_{income|expense}_{uid8}`; নাম আবশ্যক (trim)। Edit: নাম+আইকন। অজানা key-তে fallback: `{label:key, icon:"🔧"}`।
- **Delete safety:** ব্যবহারে `0` হলে সরাসরি মোছা; নইলে panel: "'X' ক্যাটাগরিতে N টি লেনদেন আছে…" → **Migrate** (অন্য ক্যাটাগরি বেছে "নিশ্চিত — সরিয়ে নিন"; সব লেনদেনের `category` বদলায়, পুরনো ক্যাটাগরি মোছে, তারিখ/পরিমাণ অক্ষত)।
- Task/Tax-এর "সাব-ক্যাটেগরি" তালিকা = `expenseCats` (একই উৎস, তিন জায়গায় অভিন্ন)।
- **Auto "ফ্যামিলি বাজার" ক্যাটাগরি:** key `family_bazar`, label "ফ্যামিলি বাজার", icon 🛒; প্রথম sync-এ স্বয়ংক্রিয় তৈরি; পরে নাম বদলালে সেটিই ব্যবহার (key দিয়ে), কখনো duplicate নয়।
- Permission: সবাই। Offline: পূর্ণ। Sync: `expenseCats/incomeCats` ডকুমেন্টের অংশ। Error: খালি নাম → বাতিল। Acceptance: migrate-পরে কোনো লেনদেন অনাথ নেই।

### 12.6 Balance Calculation (F04) — সূত্র `[SRC]`
```
Total balance (header)  = Σ income − Σ expense                     // transfers/repayments বাদ
Legacy wallet(method m) = accountOpening[m]
                        + Σ(tx.method==m ? ±amount : 0)             // tx.method null → "cash"
                        − Σ transfers.fromMethod==m  + Σ transfers.toMethod==m
                        + Σ over debts: repayments with r.method==m: (receivable ? +amount : −amount)
Dynamic account a       = a.openingBalance
                        + Σ tx.accountId==a ±amount
                        − transfers.fromAccountId + transfers.toAccountId
                        ± repayments.accountId==a (receivable +, payable −)
```
- ওয়ালেট তালিকা balance desc সাজানো; `hasActivity` = কোনো যোগফল ≠ 0।
- `method` না থাকা repayment legacy হিসাবে বাদ (অনুমান নয়)।
- **Overdraft guard** (`accountBalanceExcluding`): `opening + Σtx(method==m, শুধু tx.method সেট থাকলে) ± transfers ± repayments`, excludeTxId/excludeTransferId/excludeRepaymentId বাদ। `[NOTE N7]` `method`-হীন (Family Bazar) tx এই চেকে ধরা হয় না, কিন্তু প্রদর্শিত ব্যালেন্সে "cash"।
- Dynamic overdraft: `computeDynamicAccountBalances` পুনঃব্যবহার, edit হলে সংশ্লিষ্ট transfer/repayment বাদ।

### 12.7 Transfer (F05)
- ফিল্ড: উৎস, গন্তব্য (প্রিফিক্সড সিলেক্টর `m:{method}` | `a:{accountId}` — মিশ্রণ বৈধ), পরিমাণ>0, তারিখ, সময় (ডিফল্ট এখন), নোট।
- Validation: পরিমাণ ("সঠিক পরিমাণ লিখুন"); `উৎস == গন্তব্য` → "উৎস ও গন্তব্য একই হতে পারবে না"; উৎসে ব্যালেন্স কম → "⚠️ {উৎস}-এ এত টাকা নেই"।
- Transfer-ইতিহাস modal: তালিকা, edit (ওপরে nested), delete + Undo (৬s)।
- Transfer মোট সম্পদ বদলায় না; শুধু ওয়ালেট ব্যালেন্স।
- Permission: সবাই; Offline: পূর্ণ; Sync: `transfers[]`; Acceptance: edit-এ নিজের পুরনো প্রভাব বাদ।

### 12.8 Dynamic Accounts (F06) — "অ্যাকাউন্ট ব্যবস্থাপনা"
- মডেল: `id, name, type(cash|bank|mfs|card|other), openingBalance, openingBalanceDate, active, createdAt, updatedAt`। লেবেল: ক্যাশ, ব্যাংক, MFS/ওয়ালেট, কার্ড, অন্যান্য।
- নাম আবশ্যক ("অ্যাকাউন্টের নাম লিখুন")। Add → audit "নতুন অ্যাকাউন্ট যোগ করা হয়েছে: X"।
- **Delete শুধু ব্যবহার = 0 হলে** (tx + transfer + repayment); নইলে blocked-message দেখায় এবং Deactivate অপশন। Deactivate (active=false) নতুন entry-র picker থেকে লুকায়, ইতিহাস অক্ষত।
- "লেনদেন দেখুন" → Search ট্যাবে `accountId` seed সহ।
- এটি legacy `METHODS`-এর **অতিরিক্ত**, প্রতিস্থাপন নয়; পুরনো লেনদেনে accountId অনুমান করা হয় না।

---

## 13. Budget (F07)

- **মাসিক সামগ্রিক বাজেট** (`budget`, number, 0 = সেট নেই) এবং **খাতভিত্তিক** (`categoryBudgets: {catKey: amount>0}`)।
- BudgetModal: মান লিখে সংরক্ষণ; খাতভিত্তিক অংশ expandable ("দেখুন/লুকান"), প্রতি ব্যয়-ক্যাটাগরির একটি input (placeholder ৳০), মোট খাতভিত্তিক যোগফল দেখায়, "খাতভিত্তিক বাজেট সংরক্ষণ করুন"; শুধু `>0` মান রাখা হয়।
- Settings → টাকা → "মাসিক বাজেট (সামগ্রিক ও খাতভিত্তিক)" → Budget modal।
- ব্যবহারের থ্রেশহোল্ড: Dashboard বাজেট কার্ড (70/90/100) §11.6; খাতভিত্তিক Insight ≥80%; Reports → "বাজেট ব্যবহার" তালিকা।
- Business rule: Budget কোনো লেনদেন ব্লক করে না — শুধু সতর্কতা।
- Permission: সবাই। Offline: পূর্ণ। Sync: `budget`, `categoryBudgets` ডকুমেন্টে। Error: অঋণাত্মক সংখ্যা ছাড়া অন্য ইনপুট উপেক্ষা। Acceptance: ০/খালি = বাজেট সরানো; Dashboard পরিবর্তন তাৎক্ষণিক।

> Family Bazar-এর আলাদা মাসিক বাজেট (§23.7) ব্যক্তিগত বাজেট থেকে সম্পূর্ণ আলাদা।

---

## 14. Debt / Due — দেনা-পাওনা (F09)

### 14.1 মডেল
`Debt{ id, type("receivable"=পাওনা|"payable"=দেনা), person, amount, date, time, dueDate?, method, note, repayments[], dueNotified, createdAt }`;
`Repayment{ id, amount, date, time?, note, method?, accountId?, createdAt }`। মাধ্যম তালিকা = ৬টি + "অন্য মাধ্যম" (`other`)।

### 14.2 সূত্র `[SRC]`
```
remaining = amount − Σ repayments.amount
status    = remaining<=0 ? paid("পরিশোধ সম্পন্ন") : repayments.nonEmpty ? partial("আংশিক পরিশোধ") : pending("বাকি আছে")
dueInfo   = (remaining<=0 || !dueDate) ? null :
            diff<0 → overdue "মেয়াদোত্তীর্ণ · N দিন পার"
            diff==0 → today "আজই শেষ দিন"
            diff<=3 → soon "N দিন বাকি"   else ok "N দিন বাকি"
```
তালিকা সাজানো: paid সবার নিচে; তারপর `createdAt desc`। ফিল্টার: সব/পাওনা/দেনা। শীর্ষ সারাংশ: মোট প্রাপ্য, মোট দেনা (remaining>0 গুলোর যোগফল)।

### 14.3 ফর্ম ও Validation
নাম ("নাম লিখুন"), পরিমাণ>0 ("সঠিক পরিমাণ লিখুন"), তারিখ+সময়, ফেরতের সম্ভাব্য তারিখ (ঐচ্ছিক), মাধ্যম, নোট/কারণ (ঐচ্ছিক)।
**লক্ষ্যণীয়:** দেনা/পাওনা তৈরি নিজে কোনো লেনদেন বা ওয়ালেট-ব্যালেন্স বদলায় না; শুধু **repayment (method/accountId সহ)** ব্যালেন্সে প্রভাব ফেলে (§12.6)।

### 14.4 Repayment
- Ceiling: নতুনে `remaining`; edit-এ `remaining + oldAmount`। বেশি হলে "অবশিষ্ট (৳X) এর বেশি লেখা যাবে না"।
- উৎস-সিলেক্টর `m:`/`a:`। **payable repayment** টাকা খরচ করে → উৎসে ব্যালেন্স না থাকলে "⚠️ এই অ্যাকাউন্টে/মাধ্যমে এত টাকা নেই" (edit-এ নিজের পুরনো প্রভাব বাদ)। **receivable repayment কখনো ব্লক হয় না**।
- Repayment delete: inline "নিশ্চিত?" + ৬s Undo ("পরিশোধ মুছে ফেলা হয়েছে")। Debt delete: audit log + Undo ("দেনা-পাওনা মুছে ফেলা হয়েছে")।
- **Statement:** "স্টেটমেন্ট শেয়ার/দেখুন" — সিস্টেম share sheet (Flutter `share_plus`); না পারলে read-only টেক্সট বক্স (select-all)।
- নেস্টেড back: Detail → (edit | repay | statement) → Detail → তালিকা।

### 14.5 Due Reminder
২০s লুপে: `dueDate==আজ && remaining>0 && dueNotified != আজ` → banner/notification ("{নাম} এর কাছে পাওনা আজ ফেরত পাওয়ার কথা" / "{নাম} কে আজ পরিশোধ করার কথা"), `dueNotified = আজ`।

### 14.6 Spec
**Permission:** সবাই। **Offline:** পূর্ণ। **Sync:** `debts[]`। **Error:** উপরের বার্তাসমূহ। **Acceptance:** ceiling/overdraft/receivable-never-blocked/undo — Dart test।

---

## 15. Reports (F10)

শুধু বিদ্যমান রিপোর্ট (নতুন নয়) `[SRC: Reports]`:
1. **পরিসর:** আজ, গতকাল, গত ৭ দিন + **চলতি + আগের ১০ মাস (মোট ১১)** — ডিফল্ট চলতি মাস।
2. **সারাংশ:** আয়, ব্যয়, সঞ্চয় (`income−expense`), সঞ্চয়-হার `income>0 ? round(saved/income×100) : 0`।
3. **খাতভিত্তিক ব্যয়** (সব ব্যয় ক্যাটাগরি, desc) + Donut chart (শতাংশ, ১০-রঙের palette) + বার।
4. **Combo chart** (মাস-পরিসরে): চলতি মাসের দৈনিক ব্যয় (বার) বনাম আগের মাসের দৈনিক ব্যয় (লাইন); ট্যাপে দিনের ২ মান।
5. **বাজেট ব্যবহার:** `categoryBudgets>0` প্রতিটির `spent/amt%`, desc।
6. **"🔍 খুঁজুন" বোতাম:** নির্বাচিত পরিসর `dateFrom/dateTo` seed করে Search খোলে (advanced panel খোলা)।
7. **মাসিক পর্যালোচনা** (মাস-পরিসরে): মোট আয়/ব্যয়/সঞ্চয়, সর্বোচ্চ খরচের খাত, `momPct = (expense − prevExpense)/prevExpense` (আগের মাসের combo-মোট থেকে), `withinBudget = budget>0 && expense<=budget` → "🏆 এই মাসে বাজেটের মধ্যে ছিলেন"; **শেয়ার** (সিস্টেম share; fallback টেক্সট বক্স)। শেয়ার-টেক্সট: `{মাস}-এর হিসাব / মোট আয় / মোট ব্যয় / সঞ্চয় / সবচেয়ে বেশি খরচ / গত মাসের তুলনায় / 🏆…`।
- Empty: তথ্য না থাকলে empty-state; chart null/0 হলে লুকায়।
- **Permission:** সবাই। **Offline:** পূর্ণ। **Sync:** নেই (derived)। **Acceptance:** মাস-তালিকা exactly ১১টি; সূত্র test।

---

## 16. Search (F11)

`SearchView` ফিল্টার (সব AND) `[SRC]`:
- **টেক্সট:** ক্যাটাগরি-লেবেল বা নোট substring (case-insensitive)।
- চিপ: আজ / এই সপ্তাহ (`today−6…today`) / এই মাস (১ম…আজ); মাধ্যম-চিপ (৬টি)।
- সিলেক্ট: ধরন (সব/আয়/ব্যয়), মাধ্যম, ক্যাটাগরি (ধরন-অনুযায়ী তালিকা), সদস্য (legacy familyMembers থাকলে), অ্যাকাউন্ট (userAccounts থাকলে)।
- Advanced: তারিখ from/to, পরিমাণ min/max; "ফিল্টার মুছুন"।
- ফলাফল: `date desc, createdAt desc`; শিরোনাম "N টি ফলাফল · নিট ±৳X" (`Σ আয় − Σ ব্যয়`)।
- **Debt repayment আলাদা বিভাগ:** মাধ্যম/অ্যাকাউন্ট/তারিখ/পরিমাণ/টেক্সট (`person+note`) ফিল্টার; **কখনো লেনদেন-ফলাফল বা নিট যোগফলে মেশে না**; রং: receivable সবুজ, payable লাল।
- Seeding: Reports/Account কার্ড থেকে (`seed.ts` ধরে একবারই প্রয়োগ, পরে ব্যবহারকারীর হাতের পরিবর্তন মুছে দেয় না)।
- Empty: "কোনো লেনদেন পাওয়া যায়নি"।
- অন্যান্য সার্চ: Family Bazar search (§23.10), খসড়া খাতা ইতিহাস সার্চ (§22.6), Family Plans সার্চ (title/description)।
- Performance: ১০k+ লেনদেনে লোকাল ডেটাবেস query + debounce (৩০০ms); ইনডেক্স: `date`, `type`, `category`, `method`, `accountId`।
- **Acceptance:** সব ফিল্টার-কম্বিনেশন test; repayment বিভাগ বিচ্ছিন্ন।

---

## 17. Calendar (F12) — মূল মডিউল

### 17.1 প্রবেশ
Header 📅 বা ☰ → "হিজরি ক্যালেন্ডার"। fullscreen।

### 17.2 মাস-গ্রিড
- সপ্তাহ রবি→শনি; শুক্রবার কলাম আলাদা ছায়া।
- হেডার: ইংরেজি মাস-বছর; বাংলা মাস-পরিসর (`বৈশাখ – জ্যৈষ্ঠ ১৪৩৩`); হিজরি মাস-পরিসর। `‹ ›` মাস পরিবর্তন।
- প্রতি ঘর: ইংরেজি দিন (বড়), বাংলা দিন ও হিজরি দিন (ছোট); দাগ/ডট যদি বিশেষ দিবস থাকে (শিরোনাম tooltip)।
- **রঙের অগ্রাধিকার (উপর থেকে):** আজ → আইয়ামে বিদ (হিজরি দিন ১৩/১৪/১৫) → শুক্রবার → সোম/বৃহস্পতিবার।
- **তারিখ ট্যাপ → "বিশেষ দিন" বিস্তারিত:** ইংরেজি পূর্ণ তারিখ+বার, বাংলা তারিখ, হিজরি তারিখ; ব্যক্তিগত লেবেল তালিকা (প্রতিটির পাশে ✕ মোছা) + নতুন লেবেল যোগ ইনপুট; অ্যাডমিন বিশেষ দিবস (শিরোনাম+বিবরণ, read-only)।
- **মাসের তালিকা (গ্রিডের নিচে):** ওই মাসের সব বিশেষ দিবস (ব্যক্তিগত + অ্যাডমিন), প্রতিটি ট্যাপে একক-এন্ট্রি বিস্তারিত।
- নেস্টেড back: একক-এন্ট্রি → তারিখ-বিস্তারিত → ক্যালেন্ডার → (menu/dashboard)।
- **`[NOTE N1]`** Task/Reminder এই গ্রিডে দেখানো যাবে না।

### 17.3 বাংলা তারিখ (বাংলাদেশ ২০১৯ সংশোধিত) `[SRC: gregorianToBangla]`
- নববর্ষ = **১৪ এপ্রিল** (স্থির)। `m>4 || (m==4 && d>=14)` → `বাংলাবছর = y−593`, নয়তো `y−594`।
- মাস-দৈর্ঘ্য: বৈশাখ–ভাদ্র ৩১ দিন করে ৫ মাস (বৈশাখ, জ্যৈষ্ঠ, আষাঢ়, শ্রাবণ, ভাদ্র = ৩১), আশ্বিন–ফাল্গুন ৩০ (৬টি), **চৈত্র = ৩১ যদি (বর্ষ-শুরুর ইংরেজি বছর+১) অধিবর্ষ, নইলে ৩০**। অর্থাৎ `monthLens=[31,31,31,31,31,30,30,30,30,30,30,chaitra]`।
- নাম: বৈশাখ, জ্যৈষ্ঠ, আষাঢ়, শ্রাবণ, ভাদ্র, আশ্বিন, কার্তিক, অগ্রহায়ণ, পৌষ, মাঘ, ফাল্গুন, চৈত্র।
- হিজরি মাস-নাম (বাংলা): মুহাররম, সফর, রবিউল আউয়াল, রবিউস সানি, জমাদিউল আউয়াল, জমাদিউস সানি, রজব, শাবান, রমজান, শাওয়াল, জিলকদ, জিলহজ।
- Spec: **Permission:** সবাই; **Offline:** পূর্ণ (কোনো নেটওয়ার্ক নয়); **Sync:** ব্যক্তিগত special days `specialDays` ডকুমেন্টে, অ্যাডমিন দিবস Firestore থেকে fetch; **Error:** অ্যাডমিন দিবস লোড ব্যর্থ হলে শুধু ব্যক্তিগত দেখায়; হিজরি টেবিলের বাইরে `{day:0,month:"",year:0}` — UI "—" দেখাবে; **Acceptance:** ১৪ এপ্রিল = ১ বৈশাখ; অধিবর্ষে চৈত্র ৩১; আইয়ামে বিদ রং; Fri/Mon/Thu রং।

---

## 18. Hijri Calendar (F13) — Umm al-Qura

### 18.1 নিয়ম `[SRC: hijri-ummalqura.js, README]`
- **একমাত্র উৎস:** Umm al-Qura মাস-শুরুর টেবিল (R.H. van Gent সংকলন; `UQ_TABLE` — প্রতিটি মান MCJDN = CJDN−2,400,000; `UQ_TABLE[j+1]−UQ_TABLE[j]` = মাসের দৈর্ঘ্য ২৯/৩০; index 0 = ১ মুহাররম ১৩৫৬; `absMonth = 12×(year−1)+month`; `UQ_BASE_ABS_MONTH`)। **Arithmetic/tabular/Kuwaiti approximation নিষিদ্ধ**।
- **কভারেজ:** ১ মুহাররম ১৩৫৬ হি. (১৪ মার্চ ১৯৩৭) – ১৫০০ হি. (১৬ নভেম্বর ২০৭৭)। সীমার বাইরে `null`; অন্য পদ্ধতিতে নীরব fallback **নয়**। UI "—"/"তথ্য নেই"।
- **Flutter পোর্ট:** `hijri_ummalqura.dart`-এ `UQ_TABLE` সোর্স থেকে হুবহু (ফাইলের ২৩–১২০ লাইন) কপি করে const `List<int>` করতে হবে; মান হাতে লেখা/অনুমান নিষিদ্ধ। CJDN সূত্র: Meeus Gregorian↔CJDN (`gregorianToCjdn`/`cjdnToGregorian`), `findMonthIndex` = binary search (সবচেয়ে বড় `j` যেখানে `UQ_TABLE[j] <= mcjdn`)।
- **API:** `gregorianToHijri(y,m,d) → {year,month,day,monthLength}|null`; `hijriToGregorianYmd(y,m,d) → "YYYY-MM-DD"|null` (দিন > মাসের দৈর্ঘ্য হলে `null`); `hijriMonthLength`; `nextHijriOccurrence(hMonth,hDay,fromYmd)` (এই হিজরি বছর থেকে +২ বছর পর্যন্ত চেষ্টা; `ymd >= fromYmd` প্রথমটি; নিজ দিনও অন্তর্ভুক্ত); `hijriOccurrenceInGregorianMonth(hMonth,hDay,gYear,gMonth)` (বছর `h1.year−1 … h1.year+1`)।
- **ঢাকা সূর্যাস্ত ভিত্তিক দিন-পরিবর্তন (শুধু হিজরি):**
  1. `now` → **Asia/Dhaka** wall-clock Y-M-D (ডিভাইস টাইমজোন নির্বিশেষে; Dart-এ `timezone` প্যাকেজের `Asia/Dhaka` বা নির্দিষ্ট UTC+6)।
  2. `sunset = calcSunsetInstant(y,m,d, lat=23.8103, lon=90.4125)` (NOAA/Meeus সূত্র: zenith 90.83°; `t = dayOfYear + (18 − lngHour)/24`; `M = 0.9856t − 3.289`; `L = M + 1.916 sin M + 0.02 sin 2M + 282.634`; RA quadrant-সংশোধন; `sinDec = 0.39782 sin L`; `cosH` ∉[−1,1] → null; `T = H + RA − 0.06571t − 6.622`; `UT = (T − lngHour) mod 24`)।
  3. `instant >= sunset` → effective তারিখ = ঢাকার **পরের দিন** (মাস/বছর overflow স্বাভাবিক), নইলে ঢাকার আজ।
  4. `todayHijri = gregorianToHijri(effective)`।
- **ইংরেজি/বাংলা তারিখ মধ্যরাতে বদলায়**; এই লজিক তাদের ছোঁয় না।
- **"±১ দিন" সীমাবদ্ধতা:** রমজান/শাওয়াল/জিলহজের প্রকৃত শুরু সরকারি চাঁদ-দেখা ঘোষণার ওপর নির্ভর করে; Umm al-Qura পূর্ব-গণনাকৃত। অ্যাডমিন ফর্মে এই সতর্কতা-লেখা দেখাতে হবে।
- **সম্পূর্ণ অফলাইন।**
- Reference test vectors: `১ মুহাররম ১৪৪৮ = ২০২৬-০৬-১৬`; round-trip; ২০২৬-০৬-১৬ ঢাকা সূর্যাস্ত ≈ ১৮:৩০–১৯:২০ স্থানীয়; ১০:০০ UTC (১৬:০০ ঢাকা) → হিজরি দিন একই; ১৫:০০ UTC (২১:০০ ঢাকা) → পরের দিন; ৩১ ডিসেম্বর সূর্যাস্ত-পরে → ১ জানুয়ারি (পরবর্তী বছর)।
- **Spec:** Permission সবাই; Offline পূর্ণ; Sync নেই (গণনা); Error: out-of-range → null হ্যান্ডলিং; Acceptance: `tests/hijri-ummalqura.test.js` ও `special-day-hijri.test.js`-এর সব কেস Dart-এ পাস।

---

## 19. Special Days (F14)

### 19.1 ব্যক্তিগত বিশেষ দিন
- ডেটা: `specialDays: { "YYYY-MM-DD": [label,…] }` (একই তারিখে একাধিক; legacy স্ট্রিং→ অ্যারে `normalizeSpecialDays`)।
- সম্পাদনা: Calendar-এর তারিখ-বিস্তারিত (যোগ/✕) এবং Settings → ক্যালেন্ডার টেক্সট-এডিটর (প্রতি লাইন `YYYY-MM-DD: লেবেল`; অবৈধ লাইন নীরবে বাদ; "সংরক্ষিত হয়েছে ✓" ১.৫s)। Settings-এ সংরক্ষণ সম্পূর্ণ map **প্রতিস্থাপন** করে।

### 19.2 অ্যাডমিন বিশেষ দিবস (`adminSpecialDays`)
ফিল্ড: `title(আবশ্যক: "শিরোনাম আবশ্যক"), description, dateType("gregorian"|"hijri"), date?, hijri?{year,month,day}, recurrence("hijri"|null), hijriMonth?, hijriDay?`।
- **মোড টগল:** ইংরেজি তারিখ | হিজরি তারিখ।
  - ইংরেজি মোডে হিজরি প্রিভিউ "হিজরি: D মাস Y"।
  - হিজরি মোডে দিন(১–৩০) + মাস + বছর (বছর না থাকলে recurring); প্রিভিউ "ইংরেজি তারিখ: …"; অবৈধ → "সঠিক হিজরি তারিখ দিন"।
  - **🔁 পুনরাবৃত্তি: প্রতি হিজরি বছর** (শুধু হিজরি মোডে): পরিচয় = `{hijriMonth, hijriDay}`; **`date=null`, `hijri=null` সংরক্ষিত — কোনো স্থির ইংরেজি তারিখ কখনো সংরক্ষণ নয়**; প্রতিবার প্রদর্শনে `resolveSpecialDayDate`/`resolveSpecialDayInMonth` দিয়ে লাইভ গণনা। প্রিভিউ "এই বছর ইংরেজি তারিখ: …"; গণনা না গেলে "সঠিক হিজরি দিন/মাস দিন"।
  - ইংরেজি মোডে ফিরলে recurring বন্ধ; তারিখ = recurring-এর পরের occurrence বা hijri-resolved।
- `resolveSpecialDayDate(s, aroundYmd)`: recurring → `nextHijriOccurrence(m,d, aroundYmd ?? today)`; নইলে `s.date`। `resolveSpecialDayInMonth(s,gY,gM)`: recurring → `hijriOccurrenceInGregorianMonth`; fixed → তারিখ ওই মাসে পড়লে সেই তারিখ নইলে null।

### 19.3 Bulk Import (অ্যাডমিন)
- সারি-ভিত্তিক টেবিল: কলাম `# | তারিখ | বিবরণ/শিরোনাম | বিস্তারিত | ✕`; শুরুতে **১০ সারি**।
- উপরে রেডিও: **ইংরেজি তারিখ** / **হিজরি তারিখ (প্রতি হিজরি বছর পুনরাবৃত্তি)**; পুরো টেবিলের মোড একটাই। হিজরি মোডে প্রতি সারিতে শুধু দিন+মাস।
- **Enter নিয়ম (শিরোনাম ঘরে):** শেষ সারি নয় → পরের সারির শিরোনামে ফোকাস; **শেষ সারি + শিরোনাম অ-খালি → নতুন সারি যোগ ও ফোকাস**; শেষ সারি + খালি → কিছু হয় না। (তারিখ/বিস্তারিত ঘরে Enter-to-add নেই।)
- সারি "ব্যবহৃত" = শুধু শিরোনাম অ-খালি। ✕ মোছা (অন্তত ১ সারি থাকবে); "+ আরেকটি লাইন"; "মোট পূরণ করা লাইন: N"।
- **Validation:** কোনো ব্যবহৃত সারি নেই → "অন্তত একটি লাইনে শিরোনাম দিন"; শিরোনাম আছে কিন্তু তারিখ নেই → "লাইন N, M-এ তারিখ দেওয়া হয়নি" (সিরিয়াল সহ), নীরবে স্কিপ নয়।
- Hijri-মোডের প্রতিটি এন্ট্রি স্বয়ংক্রিয়ভাবে **recurring** (`recurrence:"hijri", date:null, hijri:null`)।
- **ডুপ্লিকেট কী:** fixed = `date|title`; recurring = `hijri:{month}-{day}|title`; fixed ও recurring একই শিরোনামে কখনো collide করে না। ডুপ্লিকেট বাদ; বার্তা "✓ N টি যোগ হয়েছে (M টি আগে থেকেই ছিল, বাদ দেওয়া হয়েছে)"। সফলে ১০ নতুন খালি সারি রিসেট।
- ব্যাচ-রাইট (Firestore `WriteBatch`); লেখার পর রিফেচ; প্রত্যাশিত ডকুমেন্ট না ফিরলে ১.২s অপেক্ষা করে আরেকবার (eventual-consistency guard)।
- Admin-only; সার্ভার rules দ্বারা জোরপূর্বক।

### 19.4 Admin Panel (F26) — ৫ ট্যাব
| ট্যাব | CRUD | ফিল্ড |
|---|---|---|
| 📢 নোটিশ | যোগ/সম্পাদনা/মুছা (inline "নিশ্চিত?") | `title, content, published(default true)` |
| ✨ দৈনিক বার্তা | একই | `title, content` |
| 📅 বিশেষ দিবস | একই + বাল্ক | উপরের ফিল্ড; তালিকায় recurring-এর "এই বছর" তারিখ |
| 📋 টাস্ক | একই | `title, description, category, dueDate, time, repeat, reminderDate, reminderTime, published` |
| ❓ FAQ | একই | `question, answer` |
- প্রতিটি লেখা `runAdminOp` দিয়ে: `isAdmin(user)` না হলে "অ্যাডমিন অনুমতি নেই।"; `permission-denied` → "{লেবেল} সংরক্ষণ করা যায়নি — অনুমতি নেই। (Firestore permission denied)"; অন্য → "{লেবেল} সংরক্ষণ করা যায়নি। আবার চেষ্টা করুন।"; সফলে সব কালেকশন রিফেচ।
- অ্যাডমিন টাস্ক যোগ করলে অ্যাডমিনের নিজের "আমার টাস্ক" তালিকায়ও যোগ হয় (একই `addTask`, একই `MAX_TASKS=10` — সীমা ছাড়ালে নীরবে no-op)।
- **FAQ seed:** `/faq` খালি ও অ্যাডমিন সেশন → ৩টি seed Q&A একবার লেখা ("আমার তথ্য কি নিরাপদ?", "অফলাইনে অ্যাপ কাজ করে কি?", "ব্যাকআপ কীভাবে নেব?")।
- লোড: লোডিং ("লোড হচ্ছে..."), ত্রুটি ("লোড ব্যর্থ হয়েছে। …" + রিফ্রেশ)।
- **শনাক্তকরণ:** `isAdmin(user)` = uid == Primary Admin UID **অথবা** email (lowercase) == Primary Admin Email (দুটি কনফিগ ধ্রুবক; UI সুবিধামাত্র — আসল সীমা rules)।

### 19.5 Spec
**Permission:** পড়া — signed-in সবাই; লেখা — Primary Admin। **Offline:** অ্যাডমিন কনটেন্ট ক্যাশ নয় (সার্ভার-মালিকানা); অফলাইনে খালি/পূর্বে-লোড-করা সেশন ডেটা; ব্যক্তিগত দিবস পূর্ণ অফলাইন। **Sync:** অ্যাডমিন কনটেন্ট on-demand fetch (সাইন-ইন ও রিফ্রেশে), realtime listener নয়। **Error:** উপরে। **Acceptance:** `special-day-bulk-import`/`special-day-hijri` test পোর্ট; recurring-এ কখনো `date` সংরক্ষিত হয় না।

---

## 20. Tasks (F15)

### 20.1 Task মডেল `[SRC]`
`{ id, text, done, date?, time?, category?, note, repeat?, reminderDate?, reminderTime?, remindedAt? }`। **amount/টাকা ফিল্ড নেই এবং যোগ করা যাবে না** (পুরনো `amount` ডেটা থাকলে নিরীহভাবে উপেক্ষা; `addTask` কখনো amount সংরক্ষণ করে না)।
Admin Task (`adminTasks`): `title, description, category, dueDate, time, repeat, reminderDate, reminderTime, published`।

### 20.2 তিনটি যোগ-পথ (একই সাব-ক্যাটেগরি তালিকা = `expenseCats`)
1. **Quick-add** (Header Tasks ড্রপডাউন): ক্যাটাগরি ড্রপডাউন + টেক্সট + "+" (শুধু text/category পাঠায়)।
2. **বিস্তারিত টাস্ক:** টাস্কের নাম*, তারিখ, সময়, সাব-ক্যাটেগরি, নোট/বিস্তারিত, রিমাইন্ডার প্রিসেট, রিপিট।
3. **অ্যাডমিন Task Management** (§19.4)।
- `text.trim()` ফাঁকা বা `tasks.length >= 10` → no-op (বিস্তারিত ফর্মে ফাঁকা নামে "টাস্কের নাম লিখুন")।

### 20.3 Reminder Preset ও Repeat
| Preset | মিনিট আগে |
|---|---|
| কোনোটি না (`none`) | — (reminder নেই) |
| নির্ধারিত সময়ে (`ontime`) | 0 |
| ৫ মিনিট আগে | 5 |
| ১০ মিনিট আগে | 10 |
| ১ ঘণ্টা আগে | 60 |
| ১ দিন আগে | 1440 |
| নিজের মতো (`custom`) | নিজের `reminderDate`+`reminderTime` |

`computeTaskReminderFields(taskDate, taskTime, preset, customDate, customTime)`:
- `none`/অনুপস্থিত → `{null,null}`; `custom` → কাস্টম মান হুবহু; অন্যথায় `base = taskDate + (taskTime ?? "00:00")` থেকে মিনিট বিয়োগ → `reminderDate("YYYY-MM-DD"), reminderTime("HH:mm")`; `taskDate` না থাকলে/অবৈধ `{null,null}`। (উদা: "১ দিন আগে" = আগের দিন একই সময়।)
- **Repeat তালিকা:** নেই, প্রতিদিন (daily), প্রতি সপ্তাহে (weekly), প্রতি মাসে (monthly), প্রতি বছরে (yearly), নিজের মতো (custom)। সংরক্ষণ: `none → null`। `[NOTE N3 / OPEN D1]` স্বয়ংক্রিয় পুনঃনির্ধারণ বর্তমানে নেই।
- Header ড্রপডাউনের সরাসরি reminder-সম্পাদনা: তারিখ (min=আজ) + সময় → `setTaskReminder(id, date||today, time||null)` এবং `remindedAt=null` রিসেট; "বাতিল" বোতামে reminder পরিষ্কার। Task-এ reminder থাকলে "রিমাইন্ডার: D মাস, HH:mm" ট্যাগ।

### 20.4 তালিকা আচরণ
- শিরোনাম "ছোট কাজ (n/10)"; "👤 আমার টাস্ক" + (যদি থাকে) "⭐ অ্যাডমিন টাস্ক" বিভাগ।
- Check = `done` টগল; সক্রিয় তালিকা শুধু `!done` দেখায় (done টাস্ক ডেটায় থাকে, সীমায় গোনা হয়); Header badge `done/total`।
- প্রতি-সারি: ✎ সম্পাদনা, 🔔 reminder, ✕ মুছা। অ্যাডমিন টাস্ক: ব্যবহারকারী শুধু নিজের `completedAdminTaskIds` টগল করে — শেয়ার্ড ডকুমেন্ট কখনো বদলায় না; শুধু `published != false` ও ব্যবহারকারী-অসম্পূর্ণ দেখায়।
- hint: "অ্যাপ খোলা থাকা অবস্থায়…" (reminder সীমা বোঝাতে)।

### 20.5 Reminder firing (Task, Tax, Debt-due একত্রে) `[SRC loop]`
প্রতি **২০ সেকেন্ডে** `now` (HH:mm) ও `today` নিয়ে: Task fires যদি `reminderTime == HH:mm && reminderDate == today && !done && remindedAt != today`; Tax: `... && !paid && remindedAt != today`; Debt: §14.5। Fire হলে `remindedAt = today` (একবারই) persist; in-app banner (ট্যাপে বন্ধ) + system notification (permission granted হলে; title `{dashboardTitle} — রিমাইন্ডার`, body = fired তালিকা `, `-এ যুক্ত)।
Flutter বাস্তবায়ন: foreground-এ একই ২০s ticker; এর সাথে `flutter_local_notifications` দিয়ে `reminderDate+reminderTime`-এ native scheduled notification (একই একবার-semantic, `remindedAt` গার্ড), Android 13+ `POST_NOTIFICATIONS` runtime permission, exact alarm অনুমতি। এটি **একই নিয়মের নেটিভ প্রয়োগ**, নতুন ফিচার নয়; দৈনিক/সাপ্তাহিক repeat নতুন করে চালু **নয়** (D1)।

### 20.6 Spec
**Permission:** ব্যক্তিগত — সবাই; অ্যাডমিন টাস্ক তৈরি/সম্পাদনা — Primary Admin। **Offline:** পূর্ণ; অ্যাডমিন টাস্ক শেষ-লোড-করা অবস্থা। **Sync:** `tasks[]`, `completedAdminTaskIds[]` ব্যক্তিগত ডকুমেন্টে। **Error:** টাস্ক-সীমা পূর্ণ → যোগ-বোতাম লুকায় (`< MAX_TASKS` শর্তে); নাম ফাঁকা error। **Acceptance:** `task-amount`, `tax-reminder` test পোর্ট; "১ দিন আগে" = আগের দিন; once-per-day; done টাস্ক fire নয়।

---

## 21. Tax Management (F16)

### 21.1 মডেল ও ফর্ম
`Tax{ id, name, amount, category?, dueDate, time?, note, repeat?, reminderDate?, reminderTime?, remindedAt?, paid(default false), createdAt }`।
ফর্ম: ট্যাক্সের নাম*, পরিমাণ*, সাব-ক্যাটেগরি (`expenseCats`), পরিশোধের শেষ তারিখ (ডিফল্ট আজ), সময়, নোট, রিমাইন্ডার প্রিসেট (Task-এর **একই** `TASK_REMINDER_PRESETS` + `computeTaskReminderFields`), রিপিট (একই `TASK_REPEAT_OPTIONS`)। Validation: নাম ফাঁকা বা পরিমাণ ≤0 → "নাম ও সঠিক পরিমাণ দিন"।

### 21.2 প্যানেল
- ☰ → ট্যাক্স ব্যবস্থাপনা। **Unpaid** তালিকা `dueDate asc`; নিচে "মোট অপরিশোধিত"।
- **Paid** ট্যাক্স মূল তালিকা ছেড়ে ভাঁজ-করা "পরিশোধিত" বিভাগে (খুললে দেখা যায়, ↺ দিয়ে undo)।
- সারি: নাম, শেষ তারিখ (overdue হলে লাল), ক্যাটাগরি, "🔔 রিমাইন্ডার সেট করা আছে"/রিপিট ট্যাগ, পরিমাণ; অ্যাকশন: ✓ paid টগল (paid-এ ↺), ✎, 🗑 (inline "নিশ্চিত?")।
- Empty: "কোনো অপরিশোধিত ট্যাক্স নেই।"

### 21.3 Business Rules
1. `taxDueInfo` = `debtDueInfo` আকৃতি (paid/dueDate-হীন → null; overdue/today/soon ≤৩/ok)।
2. **Paid ট্যাক্সের reminder বাজে না** (সঠিক মিনিটেও না); reminder না থাকলেও না; একই দিনে ২য়বার না।
3. Tax paid টগল কোনো লেনদেন তৈরি করে না।
4. Dashboard সতর্কতা ও Notification "রিমাইন্ডার" ট্যাব (`!paid && dueDate>=today`) এ প্রতিফলিত।
- **Permission:** সবাই। **Offline:** পূর্ণ। **Sync:** `taxes[]`। **Acceptance:** `tax-reminder.test.js` সব কেস।

---
## 22. Khasra Khata — খসড়া খাতা (F17)

### 22.1 উদ্দেশ্য
অনুষ্ঠান/সংস্থার জন্য পণ্য-তালিকা, পরিমাণ × দর − ছাড় হিসাব করে খসড়া সংরক্ষণ, ইতিহাস থেকে পুনঃসম্পাদনা, প্রিন্ট ও PDF। **ব্যক্তিগত লেজারের অংশ নয়, শুধু ডিভাইসে** `[NOTE N8]`।

### 22.2 Screens
`list` (ইতিহাস) · `editor` (নতুন/সম্পাদনা)। ☰ → "খসড়া খাতা" (fullscreen)। Back: editor → list → (Menu)। Editor-এ ঘরে ঘরে অসংরক্ষিত পরিবর্তন থাকলে (dirty) back-এ কনফার্ম।

### 22.3 Editor ফিল্ড
- **সংগঠন/অনুষ্ঠানের নাম*** · **তারিখ*** (ডিফল্ট আজ; বাংলা প্রদর্শন `২৭ সেপ্টেম্বর, ২০২৬`)।
- **টেবিল সারি (শুরুতে ১০টি `INITIAL_ROWS`):** `# | পণ্য/বিবরণ | পরিমাণ | একক | দর | ছাড় | মোট`।
- **একক (UNITS):** `kg, gm, pcs, ltr, ml, dozen, packet, box, bag, bundle` (ডিফল্ট `kg`)।
- নিচে: মোট ছাড়, **সর্বমোট**; বাটন: সংরক্ষণ, প্রিন্ট, PDF, নতুন খসড়া, "+ সারি"।

### 22.4 গণনা (সম্পূর্ণ নির্ভুল সূত্র) `[SRC: khasra-khata.test.js]`
```
parseNum(v): বাংলা অঙ্ক→ইংরেজি, কমা বাদ, trim; ফাঁকা/অবৈধ/≤0 → 0
lineGross    = round2(qty × rate)
lineDiscount : raw = discount (বাংলা অঙ্ক→ইংরেজি, trim)
               raw "%"-এ শেষ হলে  d = gross × min(parseNum(raw−%), 100) / 100   // শতকরা
               নইলে               d = parseNum(raw)                              // টাকা
               return round2(min(d, gross))                                      // [0, gross]-এ clamp, টাইপো-তে ঋণাত্মক লাইন নয়
lineTotal    = round2(lineGross − lineDiscount)
totals       = { discount: Σ lineDiscount, grand: Σ lineTotal }  (round2)
round2(n)    = round((n + ε) × 100) / 100
```
- সব গণনা রিয়েল-টাইমে (প্রতি কীস্ট্রোকে) পুনর্গণিত; সারির মোট কলাম read-only।
- প্রদর্শন `fmtNum`: দক্ষিণ-এশীয় গ্রুপিং + বাংলা অঙ্ক, সর্বোচ্চ ২ দশমিক (trailing zero বাদ), ঋণাত্মক `−`; `fmtTaka` = `fmtNum + "৳"` (প্রত্যয় — প্রিন্ট/PDF-এর রীতি)।

### 22.5 সারি ও Enter নেভিগেশন `[SRC: enterNav]`
- সারি "ব্যবহৃত" যদি `desc/qty/rate/discount`-এর কোনোটি অ-খালি (শুধু `unit` গণ্য নয়)।
- **বিবরণ ঘরে Enter:** শেষ সারি নয় → **একই কলামে পরের সারি**; শেষ সারি ও বিবরণ অ-খালি → **নতুন সারি যোগ ও ফোকাস**; শেষ সারি ও খালি → কিছু নয় ("লেখা থামানো = সারি বাড়া থামা")।
- **পরিমাণ / দর / ছাড় ঘরে Enter:** একই কলামে পরের সারি, **কিন্তু বিদ্যমান সারির সীমা পর্যন্ত — কখনো নতুন সারি তৈরি করে না**।
- Flutter: `TextInputAction.next` + `onSubmitted` → `FocusNode` ম্যাট্রিক্স `[row][col]`; hardware/soft keyboard "Enter/Next/Done" একই আচরণ।

### 22.6 সংরক্ষণ, ইতিহাস, সার্চ
- **Validation (`validateDraft`):** নাম খালি → "সংগঠন/অনুষ্ঠানের নাম লিখুন"; তারিখ নেই → "তারিখ দিন"; কোনো সারিতে বিবরণ নেই → "অন্তত একটি পণ্যের বিবরণ লিখুন"।
- **`buildDraft`:** শুধু ব্যবহৃত সারি সংরক্ষিত; সংখ্যা **টাইপ-করা স্ট্রিং হিসেবে** রাখা; `unit` ডিফল্ট `kg`; `totalDiscount`, `grandTotal` গণনা করে রাখা; id = `kk{base36 now}{rand5}`; edit-এ `id`/`createdAt` অপরিবর্তিত, `updatedAt` নতুন।
- **ইতিহাস:** `date desc`, একই তারিখে `createdAt desc`; কার্ড: নাম, বাংলা তারিখ, সর্বমোট; ট্যাপে edit; মুছতে confirm।
- **Search (`searchDrafts`):** নাম substring (case-insens), কাঁচা `2026-09-27`, বাংলা `২৭ সেপ্টেম্বর, ২০২৬` টেক্সট, এবং **বাংলা অঙ্কে টাইপ করা কোয়েরি** সবই মেলে। ফাঁকা কোয়েরি = সব (সাজানো)।
- **Local storage:** key `hisabkhata-khasra-v1:{uid|"guest"}` — ব্যবহারকারীর ভিত্তিতে বিচ্ছিন্ন। Flutter: Isar/Hive box `khasra_drafts` (partition by identity); সংরক্ষণ ব্যর্থ → ব্যবহারকারীকে ত্রুটি।
- **Firebase: না।** Sync: না। JSON ব্যাকআপে অন্তর্ভুক্ত নয় `[NOTE N8]` (যদি পরবর্তীতে চাই → `[OPEN D2]`)।

### 22.7 Print ও PDF
- **Print:** স্বয়ংসম্পূর্ণ ছাপার পাতা (শিরোনাম, নাম, তারিখ, `ক্রম | বিবরণ | পরিমাণ+একক | দর | ছাড় | মোট` সারি, মোট ছাড়, সর্বমোট)। Flutter: `printing` প্যাকেজ (`Printing.layoutPdf`)।
- **PDF:** A4 (595.28×841.89pt), বহু-পাতা (সারি ভাগ হয়ে পাতা বাড়ে), বাংলা ফন্ট সঠিক রেন্ডার বাধ্যতামূলক (Noto Sans Bengali/Hind Siliguri embed — `pdf` প্যাকেজে `pw.Font.ttf`)। ফাইল শেয়ার/সেভ (`share_plus`/`open_filex`)। বর্তমান JS রাস্টার-ভিত্তিক; Flutter-এ টেক্সট-ভিত্তিক PDF গ্রহণযোগ্য যদি লেআউট/বিষয়বস্তু অভিন্ন থাকে।
- **Permission:** সবাই (guest সহ)। **Offline:** পূর্ণ। **Errors:** ফন্ট লোড ব্যর্থ → ত্রুটি বার্তা, ভাঙা PDF নয়। **Acceptance:** `khasra-khata.test.js`-এর সব কেস (অঙ্ক, %, clamp, Enter, search, key isolation, empty-row ফিল্টার) Dart-এ।

---

## 23. Family Bazar (F18, F27, F28)

### 23.1 ধারণা
একাধিক ব্যবহারকারী একটি **পরিবার (family)** শেয়ার করে। প্রতি সদস্য নিজের বাজার (purchase) যোগ করে; role+permission ঠিক করে অন্যের কোন তথ্য দেখা যাবে। ডেটা Firestore-এ; অফলাইন-ক্যাশ Firestore persistence (§30)।

### 23.2 Roles ও Permissions `[SRC: family-bazar-core.js, firestore.rules]`
| Role | লেবেল | সারসংক্ষেপ |
|---|---|---|
| `owner` | মালিক | সম্পূর্ণ নিয়ন্ত্রণ; পরিবার মোছা/ক্যাটাগরি/বাজেট/সদস্য |
| `admin` | এডমিন | সদস্য, ক্যাটাগরি, বাজেট পরিচালনা; (admin-কে owner সম্পাদনা/অন্য admin সম্পাদনা নয়) |
| `member` | সদস্য | নিজের বাজার যোগ/সম্পাদনা |
| `viewer` | ভিউয়ার | শুধু অনুমতি-পাওয়া তথ্য দেখা; **কোনো purchase লিখতে পারে না** |

৭টি granular permission (সদস্য-ডকুমেন্টে `permissions` map, সব `bool`): `monthlyTotal`, `categorySummary`, `purchaseDetails`, `priceHistory`, `locationComparison`, `reports`, `memberManagement`।
**Preset (`permissionPreset(role)`):** owner = সব `true`; admin = সব `true` **কিন্তু `purchaseDetails=false`** (ডিফল্টে admin-ও অন্যের বিস্তারিত দেখে না); viewer = `monthlyTotal, categorySummary, reports`; member = `monthlyTotal, categorySummary, priceHistory, reports`। `normalizePermissions`: শুধু `=== true` মান `true`।
**নিয়ম:** `isActive(m)` = status `active` (ডিফল্ট); `canManageMembers = owner|admin|memberManagement`; `canWritePurchases = active && role != viewer`; `canEditMember(actor,target)`: নিজেকে নয়, owner-কে নয়, admin-কে শুধু owner পারে, actor-এর `canManageMembers` থাকতে হবে; `assignableRoles(actor)`: owner → admin/member/viewer; অন্য → member/viewer। **UI বোতাম লুকানো শুধু সুবিধা; Firestore Rules আসল সীমা (§34, §49)।**

### 23.3 পরিবার তৈরি/বেছে নেওয়া
- সাইন-ইন প্রয়োজন (guest → "লগইন করুন")। প্রথমবার: "পরিবার তৈরি করুন" (নাম আবশ্যক) → creator = `owner`, relation=`self`, সব permission।
- একাধিক পরিবারের সদস্য হওয়া যায়; **Family Switcher** (Header)। সক্রিয় পরিবার `activeFamilyId` (ডিভাইস-লোকাল preference, uid-ভিত্তিক)।
- Pending আমন্ত্রণ আছে কিন্তু কোনো পরিবার নেই → আমন্ত্রণ-গ্রহণ স্ক্রিন।

### 23.4 স্ক্রিন-কাঠামো ও Tabs
**বটম ট্যাব:** হোম · বাজার · রিপোর্ট · পরিবার · আরও।
- **হোম:** পরিবারের নাম/মাস; সারাংশ কার্ড (এই মাসের মোট `monthlyTotal`, আজ/গতকাল/এই সপ্তাহ/গত সপ্তাহ `periodTotals`, গত মাসের তুলনা `pctChange`); পরিবারের বাজেট অবস্থা; ক্যাটাগরি সারাংশ (permission অনুযায়ী); সাম্প্রতিক বাজার; "আগামী ৭ দিনের আনুমানিক খরচ" (`estimateNext7`); **সদস্যভিত্তিক মাসিক ব্যয় (§23.9)**; Family Planning দ্রুত-কার্ড।
- **বাজার (Bazar tab):** পরিবারের বাজার-তালিকা; নিজেরটি সবসময়, অন্যেরটি `purchaseDetails` থাকলে; তারিখ-গ্রুপ; ফিল্টার চিপ; FAB = "বাজার যোগ"।
- **রিপোর্ট:** দৈনিক/সাপ্তাহিক/মাসিক সিরিজ (`dailySeries/weeklySeries/monthlySeries`), ক্যাটাগরি-সারি (`categoryRows` — শতাংশ + আগের মাসের তুলনা), সদস্যভিত্তিক মোট; `reports`/`monthlyTotal`/`categorySummary` permission-গেটেড।
- **পরিবার:** সদস্য তালিকা (নাম, সম্পর্ক, role, ফোন), আমন্ত্রণ, সদস্য-sheet।
- **আরও:** খুঁজুন · Family Planning · পণ্য তালিকা · ক্যাটাগরি · মাসিক বাজেট · পরিবারের সেটিংস · পরিবার বদলান।

### 23.5 Purchase (বাজার যোগ/সম্পাদনা) `[SRC: validatePurchaseDraft, buildPurchase]`
- ফিল্ড: তারিখ*, বাজার/দোকান (`market`), এলাকা/লোকেশন (`location`), নোট, **দামের ইতিহাস ট্র্যাক করুন** টগল (`trackPrice`, ডিফল্ট true), এবং আইটেম-সারি।
- **আইটেম:** পণ্যের নাম* (autocomplete — পূর্বের পণ্য + ক্যাটাগরি অনুমান), ক্যাটাগরি, পরিমাণ*, একক (`kg,g,L,ml,pcs,হালি,ডজন,প্যাকেট`), একক দাম, মোট।
- **Validation (বার্তা হুবহু):** তারিখ অবৈধ → "সঠিক তারিখ দিন"; ভবিষ্যৎ → "ভবিষ্যতের তারিখে বাজার যোগ করা যাবে না"; নাম খালি → "N নম্বর পণ্যের নাম লিখুন"; নাম >৮০ → "…অনেক বড়"; পরিমাণ ≤0/NaN → "N নম্বর পণ্যের পরিমাণ ০-এর বেশি হতে হবে"; দাম ও মোট দুটোই নেই → "N নম্বর পণ্যের দাম দিন"; ঋণাত্মক → "…দাম ঋণাত্মক হতে পারে না"; কোনো আইটেম নেই → "অন্তত একটা পণ্য দিন"; **>৪০ আইটেম → "একবারে সর্বোচ্চ ৪০টি পণ্য যোগ করা যায়"**। সম্পূর্ণ খালি সারি নীরবে বাদ।
- **গণনা:** `unitPrice` না থাকলে `total/qty`; `total` না থাকলে `qty × unitPrice`; সব `round2`; purchase `total = Σ item.total`।
- বাংলা অঙ্ক ও `৳`/কমা/`।`(দাঁড়ি=দশমিক) ইনপুট গ্রহণ (`parseNum`)।
- **Stable ID:** `productId = "p_" + FNV-1a-32(nameKey).toString(36)`, `nameKey = NFC.trim.collapse-spaces.lowercase` — **একই নাম → সকল ডিভাইসে একই id** (concurrent সৃষ্টিতেও); `locKey(location) = hash36`। Dart-এ FNV-1a (offset `0x811c9dc5`, prime `0x01000193`, 32-bit, `toRadixString(36)`) অভিন্ন বাস্তবায়ন বাধ্যতামূলক, নইলে বিদ্যমান ডেটা ও rules-এর সাথে বিচ্ছিন্ন হবে।
- **Edit/Delete:** Edit শুধু `memberId == নিজের uid` ও `canWritePurchases` (rules; owner-ও অন্যেরটি সম্পাদনা করতে পারে না)। Delete rules: মালিক-সদস্য নিজে অথবা family owner (UI-তে নিজের purchase-এর delete; নতুন UI যোগ নয়)। Delete-এ কনফার্ম।
- **Purchase details sheet:** আইটেম তালিকা, মোট, বাজার/এলাকা, নোট, সম্পাদনা/মুছুন (নিজের হলে)।
- **Drafts/prefs (লোকাল):** সদস্যের ব্যবহৃত বাজার/এলাকা/পণ্য-সাজেশন uid-ভিত্তিক লোকাল preference (`readPrefs/writePrefs`) — ক্লাউডে যায় না।

### 23.6 Atomic Write Plan `[SRC: planPurchaseChange]`
প্রতিটি purchase create/edit/delete **একটি atomic Firestore batch**-এ:
1. `purchases/{purchaseId}` set/delete।
2. `memberMonthly/{uid}_{YYYY-MM}` — `total`, `count`, `days.{date}` `increment(delta)` (statDeltas: পুরনো থেকে `−`, নতুন `+`; একই-হয়ে-যাওয়া শূন্য delta বাদ)।
3. `memberCategoryMonthly/{uid}_{YYYY-MM}` — `categories.{catKey}.total` increment; `catKey = categoryId || "uncategorized"`।
4. `priceHistory/{purchaseId}_{itemId}` — `trackPrice != false` ও `unitPrice>0` আইটেমের জন্য; edit-এ বাদ-যাওয়া আইটেম delete।
5. `locations/{productId}_{locKey}_{hash36(unit)}` — `location` অ-খালি ও trackPrice; best-effort (ডক-id সব সদস্যের শেয়ার্ড, তাই batch-এর বাইরে, ব্যর্থতা বাকি লেখা আটকায় না); delete-এ `locationRelease` (শুধু যদি ডকটি এই purchase-এর হয়, অন্যথায় অক্ষত)।
- **মাসিক fetch:** `where(month==m)` (+ `memberId==uid` যদি `purchaseDetails` না থাকে), `limit(400)`, `date desc, createdAt desc`।
- **Aggregate-ই dashboard-এর উৎস** (Firestore read কমাতে): হোম/রিপোর্ট কয়েকটি ছোট ডকুমেন্ট পড়ে, সব purchase নয়।
- **`rebuildMyStats`:** পুরনো/অসঙ্গত aggregate মেরামত — সদস্য নিজের সব purchase পড়ে aggregate পুনর্গঠন (পরিবার-সেটিংস থেকে "মেরামত")।

### 23.7 Family Budget (পরিবারের মাসিক বাজেট)
- Owner/Admin সেট করে; সংরক্ষণ `families/{fid}/budgets/current = { monthlyAmount(number≥0), updatedAt, updatedBy }`। `budgetStatus(amount, spent)`: `amount<=0 → null`; `raw = spent/amount×100`; `pct = round(raw)`; **level: `raw>=100 over`, `>=90 w90`, `>=80 w80`, নইলে `ok`**; `remaining = max(0, a−spent)`, `over = max(0, spent−a)`।
- বাজেট-সীমা পেরোলে purchase আটকায় না — শুধু সতর্কতা।
- ব্যক্তিগত বাজেট (§13) থেকে সম্পূর্ণ আলাদা।

### 23.8 Personal Ledger ↔ Family Bazar Auto-Sync (F28) `[SRC: App sync effect, expense-sync.test.js]`
**নিয়ম:**
1. Purchase **save** হলে **ওই purchase-এর মালিকের** ব্যক্তিগত লেজারে একটি `expense` তৈরি/হালনাগাদ: `{ id: র‍্যান্ডম uid (নির্ধারক নয়), type:"expense", amount: purchase.total, category:"family_bazar", date: purchase.date, note: [market, location] "• " দিয়ে জোড়া, দুটোই ফাঁকা হলে "ফ্যামিলি বাজার", familyPurchaseId: purchaseId, familyId, source:"family-bazar", createdAt }` — **`method` সেট থাকে না** `[NOTE N7]`।
2. **Idempotent:** `transactions.find(t => t.familyPurchaseId == purchaseId)` থাকলে update, নইলে create — একই `purchaseId` একাধিকবার sync → একটিই লেনদেন।
3. Purchase **edit** → বিদ্যমান লিঙ্কড লেনদেনে patch merge (`type, amount, date, category, note, familyPurchaseId, familyId, source` ওভাররাইট; বাকি ফিল্ড যেমন `method` অক্ষত)। Purchase **delete** (`newPurchase == null`) → লিঙ্কড লেনদেন মুছে। কোনো tombstone/ট্র্যাকিং নেই।
4. **অন্য সদস্যের লেজারে কখনো লেখা হয় না** — sync শুধু `memberId == currentUser.uid` purchase-এর জন্য; অন্যদের purchase শুধু family aggregate-এ।
5. ক্যাটাগরি "ফ্যামিলি বাজার" key `family_bazar` (§12.5); কাস্টম নাম বদলালেও key-তেই ম্যাপ হয়; কখনো ডুপ্লিকেট নয়।
6. Sync লুপ: Family Bazar মডিউলে `onPersonalSync` callback → `App` লেজার মিউটেশন; ক্লাউডে ব্যক্তিগত ডকুমেন্ট যথারীতি debounce-push।
7. **দ্বিমুখী নয়:** ব্যক্তিগত লেজারে লিঙ্কড লেনদেন হাতে বদল করলে purchase বদলায় না; পরের purchase-sync তা পুনরায় লিখে `[NOTE]`।
- **Acceptance:** `expense-sync.test.js` — create/edit/delete/idempotent/অন্যের-purchase-লেখা-নয় — Dart-এ।

### 23.9 Family Spending — সদস্যভিত্তিক মাসিক ব্যয় `[SRC: useNumbers, README]`
প্রতি সদস্যের: **Family Bazar ব্যয় (memberMonthly aggregate, চলতি মাস) + অন্যান্য ব্যয় (`otherExpense`) = মোট মাসিক ব্যয়**।
- **Other expense:** `otherExpenseByMonth[YYYY-MM] = round2(Σ amount)` যেখানে `type==expense && !familyPurchaseId` (Family Bazar-লিঙ্কড বাদ — দ্বিগুণ গণনা এড়াতে)। **চলতি মাস ও গত মাস** — এই দুটি মান ১.৫s debounce-এ `publishOtherExpense({cm,pm})` দিয়ে ব্যবহারকারীর **সব পরিবারের** `memberOtherMonthly/{uid}_{YYYY-MM} = {memberId, month, total}` ডকে প্রকাশ হয় (একই payload আগেই প্রকাশিত হলে স্কিপ, ব্যর্থতা নীরব)। `monthlyTotal` permission থাকলে অন্যরা দেখে।
- **সদস্য সরানো/ছাড়া:** পুরনো purchase ও aggregate ডকুমেন্ট থাকে (ইতিহাস অক্ষত); তবে **চলতি পরিবার মাসিক মোট ("এই মাসে পরিবারে বাজার খরচ") শুধু বর্তমান active সদস্যদের** ধরে গণনা — সরানো সদস্য ওই মোটে ধরা হয় না; ইতিহাস/রিপোর্টে তার আগের purchase দেখা যায় (নাম snapshot `memberName` সহ)।
- Dashboard "সদস্যভিত্তিক" তালিকা `monthlyTotal` permission থাকলে অন্যদের, নইলে শুধু নিজের।

### 23.10 Family Bazar Search
"আরও → খুঁজুন"/Header 🔍: পণ্যের নাম, বাজার, এলাকা, নোট (`matches` = `nameKey` contains) — **শুধু যা ব্যবহারকারী দেখার অনুমতি পায়** (নিজের purchase + অন্যদের `purchaseDetails` থাকলে) তার উপর ক্লায়েন্ট-সাইড; ফলাফল tap → purchase details। Empty: "কিছু পাওয়া যায়নি"।

### 23.11 Realtime ও লোডিং `[SRC: useFamilyData]`
- **Realtime listener (onSnapshot):** `families/{id}` (নাম/বাজেট), `members` (সদস্য-তালিকা ও আমার role/permission — role বদলালে UI তাৎক্ষণিক বদলায়), আমন্ত্রণ (আমার ইনকামিং + পরিবারের পাঠানো), plans (Family Planning — §24.12)। বাকি (purchases, aggregates, priceHistory, locationPrices) **on-demand fetch** (ট্যাব খুললে/রিফ্রেশে/save-এর পর) — অপ্রয়োজনীয় listener এড়ানো।
- Listener অনুমতি-ত্রুটি (`permission-denied`) → বন্ধুসুলভ বার্তা (`friendlyError`): সংযোগ নেই / অনুমতি নেই / লগইন করুন / অজানা।
- লোডিং স্কেলিটন; ত্রুটিতে "আবার চেষ্টা করুন"।

### 23.12 Back-stack (অবশ্যই) §10.3 এ বিস্তারিত।

### 23.13 Spec (Family Bazar)
| | |
|---|---|
| Functional | §23.1–23.11 |
| Business rules | permission preset, FNV id, atomic aggregates, budget levels, ledger sync, active-only family total |
| Data | `families, members, purchases, memberMonthly, memberCategoryMonthly, memberOtherMonthly, priceHistory, locations, categories, products, budgets, plans, invitations` (§32, §48) |
| Permission | §33 Matrix |
| Offline | Firestore persistence ক্যাশ থেকে পড়া; লেখা queue হয় (§30); লিঙ্কড ব্যক্তিগত লেনদেন লোকালে তাৎক্ষণিক |
| Sync | batch writes + realtime listeners (§31) |
| Errors | rules deny, নেটওয়ার্ক, validation, batch-fail — রোলব্যাক (atomic) ও টোস্ট |
| Acceptance | `core.test.js`, `expense-sync.test.js` পোর্ট; viewer লিখতে পারে না; ৪০-আইটেম সীমা; aggregate delta সঠিক |

---

## 24. Family Planning (F19) — পূর্ণাঙ্গ মডিউল

### 24.1 লক্ষ্য
পরিবারের নির্দিষ্ট লক্ষ্যের (ভ্রমণ, ঘর মেরামত…) জন্য সমষ্টিগত সঞ্চয়: প্ল্যান তৈরি → Owner/Admin অনুমোদন → সদস্যদের অবদান দাবি → **Owner/Admin যাচাই** → অনুমোদিত সংগ্রহ → লক্ষ্য পূরণ → সম্পন্ন। এটি **বিদ্যমান family role সিস্টেম পুনর্ব্যবহার** করে; কোনো নতুন permission সিস্টেম নেই।

### 24.2 Lifecycle
```
Plan তৈরি (status = pending_approval)
   │
   ├─ Owner/Admin: approve ──────────────► active
   ├─ Owner/Admin: reject (কারণসহ) ──────► rejected   (শেষ; কোনো contribution নেওয়া যায় না)
   └─ Owner/Admin: request changes (নোট) ─► changes_requested
          └─ creator সম্পাদনা + resubmit ─► pending_approval (আবার)

active ── Contribution (claimed; status=pending)
            │
            └─ Owner/Admin Verification:
                 • পেয়েছি (received ≥ claimed) ──► approved
                 • আংশিক   (received < claimed) ──► partial     (official = receivedAmount)
                 • প্রত্যাখ্যান (কারণসহ) ────────► rejected     (official = 0)
          Official collected বাড়লে → refreshAchievedStatus
active ── approvedTotal ≥ target ──► target_achieved   (কমলে আবার active)
target_achieved ── Owner/Admin: "সম্পন্ন করুন" ──► completed (ম্যানুয়াল; বোতাম শুধু `target_achieved` অবস্থায়)
(paused / cancelled: মডেলে আছে, UI নেই — [NOTE N6])
```

### 24.3 ⚠️ মূল ব্যবসায়িক নিয়ম — Official Collected Amount
**Owner/Admin verify না করা পর্যন্ত কোনো contribution official collected amount-এ গণনা হয় না।**
- `contributionCredit(c)`: `status ∈ {approved, partial}` হলে `receivedAmount ?? claimedAmount`; **`pending` ও `rejected` = ০**।
- `approvedTotal(plan) = Σ contributionCredit`। এটিই "সংগৃহীত টাকা", প্রগ্রেস, লক্ষ্য-পূরণ ও অবশিষ্ট সবকিছুর ভিত্তি।
- **উদাহরণ (বাধ্যতামূলক টেস্ট কেস):** সদস্য দাবি করল **৳১০,০০০** → verify-এর আগে সংগৃহীত **৳০** (pendingTotal ৳১০,০০০ আলাদা দেখায়)। Owner যাচাই করে **৳৮,০০০ received** → status `partial`, **official collected = ৳৮,০০০, ৳১০,০০০ নয়**। বাকি ৳২,০০০ কোথাও গণনা হয় না।
- `[NOTE N11]` `received ≥ claimed` হলে status `approved` ও credit = `receivedAmount` (claimed-এর চেয়ে বেশিও হতে পারে)।
- সদস্য নিজের contribution-এর পরিমাণ/অবস্থা নিজে "approved" করতে পারে না (rules + UI)।

### 24.4 Plan মডেল (`plan(row)` normalization)
`id, title(≤60), type, icon, targetAmount, perMemberTarget?, startDate, endDate, description, participantMode("all"|"selected"), participantUids[], contributionMode("monthly"|"once"|"both" ডিফল্ট both), expenseApprovalRequired(false), status, createdBy/Name/At, approvedBy/Name/At, rejectedBy/At/rejectionReason, changesRequestedBy/At/changesRequestNote, lastModifiedBy/At, completedAt, contributions[], expenses[], auditLog[]`।
**Plan ধরন (১১):** ভ্রমণ✈️, ঘর/মেরামত🏠, শিক্ষা🎓, ডিভাইস/ইলেকট্রনিক্স💻, যানবাহন🚗, পশু/কুরবানি🐄, বিবাহ💍, জরুরি তহবিল🏦, পরিবারের ডিভাইস📱, সঞ্চয়💰, অন্যান্য📌 (অজানা → `other`)।
**Status লেবেল:** pending_approval "পেন্ডিং"; changes_requested "পরিবর্তন প্রয়োজন"; active "সক্রিয়"; target_achieved "লক্ষ্য পূর্ণ"; completed "সম্পন্ন"; rejected "প্রত্যাখ্যাত"; paused "স্থগিত"; cancelled "বাতিল"।
**Status tab গ্রুপ:** সব; সক্রিয় = {active, target_achieved}; পেন্ডিং = {pending_approval, changes_requested}; সম্পন্ন = {completed}।
**Contribution:** `id, memberUid, memberName, claimedAmount, date, paymentMethod, note, receiptName?, status(pending|approved|rejected|partial), receivedAmount?, verifiedBy/Name/At, rejectionReason, createdAt`। Payment method: নগদ, বিকাশ, নগদ (Nagad), রকেট, ব্যাংক ট্রান্সফার, অন্যান্য। `receiptName` কেবল নাম-ফিল্ড (ফাইল আপলোড/Storage নেই)।
**Expense:** `id, title, amount, date, note, addedBy/Name, status(approved|pending), createdAt`।
**Audit entry:** `{id, ts, actorUid, actorName, action, details}`; **ঘূর্ণায়মান লগ — সর্বোচ্চ ২০০, বেশি হলে পুরনো বাদ** (`appendPlanAudit`)।

### 24.5 Plan Create/Edit Validation (`validatePlanDraft`) — বার্তা হুবহু
নাম খালি "পরিকল্পনার নাম লিখুন" / >৬০ "পরিকল্পনার নাম অনেক বড়"; ধরন অবৈধ "ধরন বেছে নিন"; লক্ষ্য ≤0 "লক্ষ্য টাকা দিন"; শুরু/শেষ অবৈধ "শুরুর তারিখ দিন"/"শেষ তারিখ দিন"; শেষ<শুরু "শেষ তারিখ শুরুর তারিখের আগে হতে পারে না"; `selected` মোডে কেউ নেই "অন্তত একজন সদস্য বেছে নিন"; `perMemberTarget` দিলে >0 "সদস্য প্রতি লক্ষ্য সঠিক নয়"।
- Create ফর্ম: নাম, ধরন, লক্ষ্য, (ঐচ্ছিক) সদস্য-প্রতি লক্ষ্য, শুরু, শেষ, বিবরণ, অংশগ্রহণকারী (সব সদস্য | নির্বাচিত), অবদানের ধরন (মাসিক/একবারে/উভয়)।
- Create → status `pending_approval`; audit "plan_created"-ধরনের এন্ট্রি; creator যদি owner/admin — তবুও pending থেকেই শুরু (কোডে স্বয়ংক্রিয় অনুমোদন নেই)।
- **Edit & resubmit:** `changes_requested` অবস্থায় creator সম্পাদনা করে `resubmitPlan` → `pending_approval`, change-note মুছে, audit "plan_resubmitted"।
- Create permission: `canCreatePlan(role)` = owner/admin/member। **Viewer পারে না** (UI ও rules)।

### 24.6 Approval Center (Owner/Admin)
- `canApprovePlan(role)` = owner বা admin।
- pending plans তালিকা (`pendingApprovalPlans`); প্রতিটিতে: **অনুমোদন** (`approvePlan` → active, `approvedBy/At`, audit), **প্রত্যাখ্যান** (কারণ ঐচ্ছিক ইনপুট → `rejectPlan`, audit "প্রত্যাখ্যান করেছেন: {কারণ}"), **পরিবর্তন চান** (নোট → `requestPlanChanges`, audit)।
- নিজের তৈরি plan নিজে অনুমোদন করা কোডে ব্লক করা নেই; Owner/Admin হলে পারে `[NOTE]`।
- Header 🎯 ও আরও-মেনুতে **pending-approval badge** (সংখ্যা) — Owner/Admin-এর জন্য; অন্যদের জন্য নয়।

### 24.7 Contribution ফ্লো
1. সক্রিয় (active/target_achieved?) plan-এ অংশগ্রহণকারী (`isParticipant`: mode `all` বা uid ∈ participantUids) ও `canContribute` (owner/admin/member) সদস্য "অবদান দিন": পরিমাণ*, তারিখ* (ডিফল্ট আজ), পেমেন্ট মাধ্যম, নোট, (ঐচ্ছিক) রসিদ-নাম। Validation: "টাকার পরিমাণ দিন", "তারিখ দিন"। Status = `pending`; audit।
2. **Owner/Admin "Verification" পাতা:** `pendingVerificationContributions` তালিকা; প্রতি সারিতে —
   - **পেয়েছি** (ডিফল্ট `received = claimed`; পরিমাণ সংশোধনযোগ্য) → `received >= claimed ⇒ approved`, নইলে `partial`; `verifiedBy/Name/At` সেট; audit; তারপর `refreshAchievedStatus`।
   - **প্রত্যাখ্যান** + কারণ → `rejected`, credit ০।
3. সংগ্রহ বাড়ার পর `refreshAchievedStatus`: `active ∧ approvedTotal ≥ target ⇒ target_achieved`; `target_achieved ∧ approvedTotal < target ⇒ active` (যেমন partial দিয়ে মান কমলে)।
4. "সদস্যদের অবদান" (`memberContributionRows`): প্রতি সদস্য `claimed / pending / approved` (approved = credit-এর যোগফল), `approved desc` সাজানো।
5. "আমার অবদান" পাতা: নিজের contribution ও স্ট্যাটাস, প্রত্যাখ্যানের কারণ।
- Verification কে করল ও কখন — `verifiedBy/Name/At` + audit।

### 24.8 Plan থেকে খরচ (Expense from collected money)
- অংশগ্রহণকারী/মালিক/অ্যাডমিন (UI গেট) "খরচ যোগ": শিরোনাম*, পরিমাণ*, তারিখ*, নোট। Validation: "খরচের নাম লিখুন", "পরিমাণ দিন", "তারিখ দিন"।
- `spentTotal` = শুধু `status == approved` expense-এর যোগফল। `remainingAfterSpend = approvedTotal − spentTotal`; `remainingTarget = max(0, target − approvedTotal)`।
- `expenseApprovalRequired` প্ল্যান-ফ্ল্যাগ থাকলেও **UI-তে এটি সেট/অনুমোদনের পথ নেই** `[NOTE N6]` — সব খরচ ডিফল্ট `approved`।
- Plan খরচ ব্যক্তিগত লেজারে যায় না (বিদ্যমান আচরণ)।

### 24.9 Plan Completion
`completePlan` — **UI-তে "🎉 সম্পন্ন করুন" শুধু `status == target_achieved` হলে ও Owner/Admin (`vis.admin`) দেখে**; rules owner/admin-কে `completed/paused/cancelled/active`-এ যেতে দেয় (UI শুধু completed ব্যবহার করে); status `completed`, `completedAt`; audit "পরিকল্পনা সম্পন্ন হিসেবে চিহ্নিত করেছেন"। সম্পন্ন প্ল্যানে আর contribution/expense নয় (UI গেট)।
Plan delete: creator বা owner/admin (rules); কনফার্ম।

### 24.10 Plan হোম / তালিকা / বিস্তারিত
- **Plan Home (Dashboard totals `dashboardTotals`):** মোট প্ল্যান, সক্রিয় (`active|target_achieved`), মোট লক্ষ্য, মোট অনুমোদিত সংগ্রহ, পেন্ডিং contribution-এর যোগফল, মোট অবশিষ্ট (`Σ remainingTarget`)।
- **Plan List:** ট্যাব সব/সক্রিয়/পেন্ডিং/সম্পন্ন; সার্চ (`searchPlans` title+description); নতুন→পুরনো (`sortPlansNewest`)।
- **Plan Detail:** প্রগ্রেস বার (`progressPct = min(100, round(approved/target×100))`), সংগৃহীত/অবশিষ্ট/খরচ/পেন্ডিং, সদস্যদের অবদান সারাংশ, contribution তালিকা, expense তালিকা, **Audit/History** (সময়সহ কে কী করল: তৈরি, অনুমোদন, যাচাই, প্রত্যাখ্যান…), স্ট্যাটাস-অনুযায়ী অ্যাকশন বাটন।
- **"আমার প্ল্যান":** `plansCreatedBy` ও `plansParticipatingIn` (নিজের নয় এমন)।
- **Owner Center:** pending approvals + pending verifications একত্রে।

### 24.11 Realtime
`families/{id}/plans` onSnapshot — কেউ অনুমোদন/যাচাই করলে অন্য ডিভাইসে তাৎক্ষণিক আপডেট; pending-approval badge লাইভ। মিউটেশন `_mutatePlan` (পড়ো → বদলাও → লিখো) `[NOTE N10]`: Flutter-এ Firestore `runTransaction` ব্যবহার বাধ্যতামূলক, যাতে দুই admin একসাথে verify করলে একটি আপডেট না হারায়; ফলাফল-আচরণ অভিন্ন।

### 24.12 Spec (Family Planning)
| | |
|---|---|
| Permission | Create/Contribute: owner/admin/member; Approve/Reject/Request-changes/Verify/Complete: owner/admin; View: সব সদস্য (participant/permission সাপেক্ষে); Viewer: **কিছুই তৈরি/বদল নয়** |
| Offline | Firestore ক্যাশ থেকে দেখা; লেখা queue (সংযোগে সিঙ্ক)। Transaction অফলাইনে চলে না → অফলাইনে plan-মিউটেশন ব্লক করে "ইন্টারনেট প্রয়োজন" দেখাতে হবে (বর্তমান `_mutatePlan` অফলাইনে ব্যর্থ হয় `[NOTE]`) |
| Sync | realtime listener (plans)। কোনো ব্যক্তিগত লেজার মিরর **নেই** |
| Errors | validation বার্তা §24.5; permission-denied → "অনুমতি নেই"; নেটওয়ার্ক → "ইন্টারনেট…"; plan-না-পাওয়া |
| Acceptance | `family-planning.test.js` সব কেস; ১০,০০০/৮,০০০ উদাহরণ; ২০০-সীমা লগ; viewer ব্লক; resubmit → pending |

---

## 25. Family Members & Roles (F20, F29)

### 25.1 সদস্য ডকুমেন্ট `families/{fid}/members/{uid}`
`uid, name, phone?, relation(key), role, status("active"|"removed"…), permissions{7}, joinedAt, inviteId?, photoURL?, updatedAt`। সম্পর্ক তালিকা (১২): আমি(self), বাবা, মা, ভাই, বোন, স্বামী, স্ত্রী, ছেলে, মেয়ে, দাদা/নানা, দাদি/নানি, অন্যান্য। আমন্ত্রণে `self` দেওয়া যায় না।

### 25.2 Invitation
- Owner/Admin/`memberManagement` পারে। ফর্ম: ইমেইল* (`isValidEmail`; অবৈধ → ত্রুটি), নাম, সম্পর্ক, role (`INVITABLE_ROLES`: admin/member/viewer — admin কেবল owner আমন্ত্রণ করতে পারে), permissions (preset থেকে শুরু, টগল সম্পাদনাযোগ্য)।
- মডেল `invitations/{id}`: `familyId, familyName, invitedEmail(lowercase), relation, role, permissions, phone?(≤২০), status(pending|accepted|rejected|cancelled), invitedBy, createdAt, expiresAt(= now+৭ দিন; rules সর্বোচ্চ ৩০ দিন), respondedAt?`। মেয়াদোত্তীর্ণ/non-pending আমন্ত্রণ ইনকামিং তালিকায় আসে না।
- প্রাপক **যাচাইকৃত (email_verified) ইমেইলে** সাইন-ইন করলে ইনকামিং আমন্ত্রণ দেখে ও গ্রহণ করতে পারে (☰ মেনুতে badge + Family Bazar-এ): **গ্রহণ** → member ডকুমেন্ট তৈরি (ওই role/permissions/relation); **প্রত্যাখ্যান** (`rejected`)। গ্রহণ = একটি batch: member ডক (`inviteId` সহ) + `families.memberUids arrayUnion` + আমন্ত্রণ `accepted`।
- Owner/Admin পাঠানো আমন্ত্রণ বাতিল করতে পারে (cancel) এবং স্ট্যাটাস দেখে।
- সদস্য আগে থেকেই সক্রিয় হলে পুনরায় আমন্ত্রণ নয় (ডুপ্লিকেট চেক)।

### 25.3 Member Profile
- Owner অন্য সদস্যের **নাম, ফোন, সম্পর্ক** সম্পাদনা করতে পারে। সদস্য নিজের নাম/ফোন/সম্পর্কও সম্পাদনা করতে পারে (rules-সম্মত)।
- Role/permission সম্পাদনা: `canEditMember(actor,target)` ও `assignableRoles` অনুযায়ী; **নিজের যে permission নেই তা অন্যকে দেওয়া যায় না** (Owner ছাড়া; UI টগল locked; rules `grantable`); **Owner-এর role কেউ বদলাতে পারে না; admin-কে শুধু owner বদলায়**।
- সদস্য সরানো (remove): Owner/Admin (admin-কে শুধু owner)। Remove হলে `status` পরিবর্তন; পুরনো purchase অক্ষত (§23.9)।
- সদস্য নিজে পরিবার **ছাড়তে** পারে (owner ছাড়া)। Owner পরিবার **মুছতে** পারে (কনফার্ম, destructive)।
- ফোন থাকলে কল (`tel:`) ও WhatsApp (`wa.me`) লিংক (best-effort; বাংলাদেশি মোবাইল নম্বর ধরে আন্তর্জাতিক ফরম্যাট)। Flutter: `url_launcher`।
- Spec: **Offline:** ক্যাশ থেকে দেখা; লেখা queue। **Errors:** permission-denied → "অনুমতি নেই"; অবৈধ ইমেইল। **Acceptance:** `canEditMember`/`assignableRoles` ম্যাট্রিক্স টেস্ট।

### 25.4 Family Settings
পরিবারের নাম (Owner), মাসিক বাজেট (Owner/Admin), "আমার পরিসংখ্যান মেরামত" (`rebuildMyStats`), পরিবার ছাড়ুন/মুছুন।

### 25.5 Family Categories
ডিফল্ট ২১টি (মুদি ও খাবার ১৫ + গৃহস্থালী ৬ — id `def_*`, কনস্ট্যান্ট, seeding-লেখা নেই) + কাস্টম (`families/{id}/categories`: `name, icon, group`)। Owner/Admin কাস্টম যোগ/সম্পাদনা/মুছতে পারে। নাম-সংশোধন/ক্যাটাগরি-পরিবর্তনে পুরনো purchase-এর snapshot (`category` নাম) অক্ষত (§26)।

### 25.6 Legacy "ব্যক্তিগত তালিকা" (FamilyView, F29) `[NOTE N12]`
ফ্যামিলি ট্যাবের দ্বিতীয় অংশ: **ব্যক্তিগত** `familyMembers[]` (নাম, সম্পর্ক…) ও `bazarItems[]` (বাজার-আইটেম: নাম, দাম/পরিমাণ/ইউনিট, `purchased`, তারিখ, সদস্য) — শুধু ব্যক্তিগত ডকুমেন্টে, ক্লাউড Family Bazar-এর সাথে সম্পর্কহীন। বিদ্যমান আচরণ হুবহু রাখতে হবে: তালিকা, `computeBazarTotal`, কেনা-চিহ্ন → ঐচ্ছিক লেনদেন লিঙ্ক (`bazarItemId`), সদস্য-ভিত্তিক সারাংশ; ডিলিটে confirm। (`family_bazar` অটো-সিঙ্ক এর সাথে সম্পর্কিত নয়।)

---

## 26. Product & Price Management (F21)

### 26.1 Product
- সংগ্রহ `families/{fid}/products`: `{ id: productId, name, categoryId, category(snapshot), unit?, createdAt, updatedAt }`। `productId = "p_"+hash36(name)` (নির্ধারক)।
- "পণ্য তালিকা" (আরও): সার্চ, ক্যাটাগরি-গ্রুপ, পণ্য ট্যাপ → **Product Sheet**।
- **Product Sheet:** বর্তমান/সর্বশেষ দাম, গড়, সর্বনিম্ন/সর্বোচ্চ, ৭/৩০ দিন আগের দাম ও পরিবর্তন, আগের কেনার তুলনা, এ মাস বনাম গত মাসের গড়, মূল্য-সিরিজ চার্ট (৭ দিন/৩০ দিন/সব); **একক ভিন্ন হলে আলাদা করে** (সর্বশেষ কেনার একককেই বিশ্লেষণ, বাকি `otherUnitCount` হিসেবে নোট)।
- **Category correction:** পণ্যের ক্যাটাগরি বদলানো যায় → শুধু **product ডকুমেন্টের** `categoryId/category` বদলায়; **ঐতিহাসিক purchase আইটেম, aggregate ও priceHistory অক্ষত** (snapshot)।
- **Rename (typo correction):** `renameProduct(familyId, productId, oldName, newName)` — **একই product ডক** (id অপরিবর্তিত), `name = newName`, `aliases`-এ `oldName` যোগ (`arrayUnion`)। পুরনো নামে খোঁজ/অটোকমপ্লিট একই পণ্যে মেলে (`name` বা `aliases` উভয়ে `nameKey` মিল)। **পুরনো purchase আইটেম ও priceHistory-র নাম-snapshot ও `productId` অক্ষত।** নতুন নামে নতুন id তৈরি হয় না।
- **Archive:** `archived=true/false` — তালিকা, সার্চ ও অটোকমপ্লিট থেকে লুকায়; ইতিহাস অক্ষত।
- **Category correction:** `setProductCategory(familyId, productId, categoryId|null)` — শুধু product ডকের `categoryId`; **ঐতিহাসিক purchase/aggregate/price অক্ষত**।
- Permission: পণ্য দেখা — `priceHistory` permission (বিস্তৃত বিশ্লেষণ); সম্পাদনা — owner/admin (কাস্টম ক্যাটাগরি/পণ্য rules অনুযায়ী)।

### 26.2 Price History (`families/{fid}/priceHistory`)
সারি: `{ productId, productName, memberId, price(unitPrice), unit, date, month, purchaseId }`, id=`{purchaseId}_{itemId}`। **Rules:** `unitPrice>0` এবং `trackPrice != false` হলেই লেখা হয়। `sortPriceRows`: `date asc` → `createdAt` → `id`। `analyzePrices(rows, today)` (§26.1 মানগুলি), `priceMovers(rows, minPct=3)`: প্রতি `(product|unit)` সর্বশেষ দুই কেনার % পরিবর্তন; `|pct| < minPct` বাদ; `|pct| desc`।

### 26.3 Location/Area Price Comparison (`locations`)
ডক-id = `{productId}_{locKey}_{hash36(unit)}` — প্রতি (পণ্য, এলাকা, একক) সর্বশেষ মূল্য। `locationComparison(rows)`: প্রতি `(nameKey(location)|unit)` এর **সর্বশেষ তারিখ** সারি; **সস্তা→দামি** সাজানো। শুধু `location` অ-খালি ও trackPrice সক্রিয় হলে লেখা; `locationComparison` permission-গেটেড।

### 26.4 Spec
**Offline:** ক্যাশ-রিড। **Sync:** purchase batch-এর অংশ (price) + best-effort (location)। **Errors:** location-লেখা ব্যর্থ হলে purchase সফল থাকে; rules deny। **Acceptance:** `analyzePrices`, `priceMovers`, `locationComparison`, id-নির্ধারকত্ব, category-পরিবর্তনে ইতিহাস অক্ষত।

---

## 27. Notifications & Reminders (F22)

**শুধু বিদ্যমান আচরণ — কোনো নতুন feed নেই।**
1. **Notification Center (🔔 / ☰):** ৩ ট্যাব — **নোটিশ** (অ্যাডমিন `notices`, `published != false`), **দৈনিক বার্তা** (`dailyMessages`), **রিমাইন্ডার** (ব্যবহারকারীর নিজস্ব: `task.reminderDate>=today` unpaid/undone, tax `!paid && dueDate>=today`, debt due)। ট্যাবে unread badge।
2. **Read/Unread:** `readNoticeIds`, `readDailyMessageIds` ব্যক্তিগত ডকুমেন্টে; আইটেম খুললে read; Header 🔔 badge = unread নোটিশ+দৈনিক সংখ্যা।
3. **Dismiss:** `dismissedDailyMessageIds` — **শুধু দৈনিক বার্তা** ব্যবহারকারী নিজের জন্য আড়াল করতে পারে (শেয়ার্ড ডকুমেন্ট বদলায় না); নোটিশে dismiss নেই।
4. **In-app reminder banner + system notification:** §20.5।
5. **Family Planning:** Header 🎯 ও আরও-তে pending-approval সংখ্যা badge (Owner/Admin); Plan Owner Center-এ "যাচাইয়ের অপেক্ষায়"।
6. **Hamburger badge:** ইনকামিং ফ্যামিলি আমন্ত্রণ সংখ্যা (Family Bazar আইটেমে) ও নোটিফিকেশন unread।
7. **Toast/Banner:** `saveErr`, undo banner (৬s), sync-status chip, reminder banner।
8. **System Notification Permission:** Settings → নোটিফিকেশন: অবস্থা (অনুমোদিত/অননুমোদিত/অসমর্থিত) + "চালু করুন"। Android 13+ runtime permission; reminder কেবল permission থাকলে system notif পাঠায়, তবে in-app banner সবসময়।
- **Spec — Permission:** পড়া signed-in ও guest (সীমিত: অ্যাডমিন কনটেন্ট লোড signed-in ছাড়া হয় না)। **Offline:** ব্যক্তিগত রিমাইন্ডার পূর্ণ; অ্যাডমিন কনটেন্ট শেষ-লোড। **Sync:** read/dismiss ids ব্যক্তিগত ডকুমেন্টে। **Errors:** লোড ব্যর্থ → "লোড ব্যর্থ…"। **Acceptance:** badge সংখ্যা, read-টগল, dismiss স্থায়িত্ব।

---
## 28. Authentication (F23) & Settings (F24)

### 28.1 পরিচয়-মডেল
- **Guest/Local:** `identity = "guest"` — লগইন ছাড়াই পূর্ণ ব্যক্তিগত মডিউল (লেজার, বাজেট, দেনা, টাস্ক, ট্যাক্স, ক্যালেন্ডার, খসড়া খাতা)। ক্লাউড-নির্ভর মডিউল (Family Bazar, Family Planning, অ্যাডমিন কনটেন্ট, ব্যাকআপ/সিঙ্ক) লগইন চায়।
- **Signed-in:** `identity = firebase uid`। **ব্যবহারকারী-ডেটা বিচ্ছিন্নতা:** লোকাল স্টোরেজ কী `userDataKey(identity)` ভিত্তিক; পরিচয় বদলালে (`settleIdentity`) স্ক্রিন **আগে খালি** করা হয়, তারপর নতুন পরিচয়ের ডেটা লোড — আগের ব্যবহারকারীর রেকর্ড মুহূর্তের জন্যও দেখা যায় না।
- **এক-বারের মাইগ্রেশন:** পুরনো ফ্ল্যাট কী `hisabkhata-data-v1` (প্রি-মাল্টি-ইউজার) থাকলে প্রথম guest লোডে `guest` কী-তে কপি।
- **Device-level (পরিচয়-নিরপেক্ষ, ক্লাউডে যায় না):** `hisabkhata-device-v1` = `{ pin, theme, autoSync }`।

### 28.2 Login স্ক্রিন
- বিকল্প: **Google দিয়ে সাইন-ইন**; **ইমেইল+পাসওয়ার্ড** (সাইন-ইন / নতুন অ্যাকাউন্ট / পাসওয়ার্ড ভুলে গেছি → reset email); "লগইন ছাড়া চালিয়ে যান" (guest)।
- Firebase Auth ত্রুটি → বাংলা বার্তা (ভুল পাসওয়ার্ড, অ্যাকাউন্ট নেই, ইমেইল ব্যবহৃত, দুর্বল পাসওয়ার্ড, অবৈধ ইমেইল, নেটওয়ার্ক, অনেকবার চেষ্টা…)। Google: popup-ব্যর্থ হলে redirect fallback (web-এর জন্য); Flutter: `google_sign_in` + `firebase_auth` (native flow)।
- সাইন-ইন সেশন পর্সিস্ট (`Persistence.LOCAL` সমতুল্য — Firebase Auth Flutter ডিফল্ট)।
- **Logout:** স্থানীয় ডেটা মোছে না; পরিচয় `guest`-এ ফেরে এবং guest ডেটা লোড হয় (ব্যবহারকারীর ডেটা তার uid-কী-তেই থাকে)। কনফার্ম ডায়ালগ।

### 28.3 Login-পরবর্তী ডেটা সমন্বয় (`settleIdentity`) `[SRC]`
1. লোকাল (`userDataKey(uid)`) লোড → UI-তে প্রয়োগ।
2. ক্লাউড `users/{uid}` fetch (`syncStatus = syncing`):
   - **ক্লাউড ডক আছে →** ক্লাউড ডেটা **লোকালকে ওভাররাইট** করে (UI + লোকাল স্টোরেজ)।
   - **ক্লাউড ডক নেই কিন্তু লোকাল আছে →** লোকাল ডেটা ক্লাউডে **push** (হারানো এড়াতে)।
   - ব্যর্থ → `syncStatus = error` (লোকাল ডেটা দিয়েই চলে)।
3. `loaded = true`। Merge/field-level conflict resolution **নেই** `[NOTE N9]`।

### 28.4 Settings (সম্পূর্ণ অডিট) `[SRC: SettingsModal]`
| বিভাগ | আইটেম |
|---|---|
| **অ্যাকাউন্ট** | নাম/ইমেইল/ছবি; লগইন বা লগআউট; Sync অবস্থা (Offline/Syncing/Synced/Error + সর্বশেষ sync সময়); **অটো-সিঙ্ক টগল** (`autoSync`, ডিফল্ট চালু); **এখনই সিঙ্ক** (manual); **ক্লাউড থেকে ফিরিয়ে আনুন** (Restore); অপেক্ষমাণ পরিবর্তন সংখ্যা |
| **ডিসপ্লে/থিম** | আলো / ডার্ক / অটো (system); বাংলা অঙ্ক সর্বত্র |
| **টাকা** | মাসিক বাজেট (§13); **প্রারম্ভিক ব্যালেন্স** (প্রতি মাধ্যমের `accountOpening`); ক্যাটাগরি ব্যবস্থাপনা (§12.5) |
| **ক্যালেন্ডার** | ব্যক্তিগত বিশেষ দিন টেক্সট-এডিটর (`YYYY-MM-DD: লেবেল`) §19.1 |
| **ডেটা ও ব্যাকআপ** | **JSON এক্সপোর্ট** (সম্পূর্ণ ব্যক্তিগত ডেটা ফাইল হিসেবে শেয়ার/সেভ — Blob `application/json`); **CSV এক্সপোর্ট** (লেনদেন, পূর্বদৃষ্টি-সহ); **CSV ইমপোর্ট** (টেক্সট পেস্ট) — `[NOTE]` কোডে **JSON ইমপোর্ট নেই**; পুনরুদ্ধার = ক্লাউড Restore (§31.1)। JSON ইমপোর্ট নতুন করে যোগ করা যাবে না |
| **নোটিফিকেশন** | system permission অবস্থা + চালু করুন (§27) |
| **নিরাপত্তা** | **৪-সংখ্যার PIN** সেট (দুইবার লিখে নিশ্চিত — না মিললে "দুটি পিন মেলেনি, আবার চেষ্টা করুন"); **বদল/বন্ধ করতে আগে বর্তমান PIN যাচাই** বাধ্যতামূলক; **সব ডেটা মুছুন** (কনফার্ম; নিচে) |
| **কার্যকলাপ ইতিহাস** | Audit log তালিকা (নতুন→পুরনো; কর্ম, বিবরণ, সময়) |
| **অ্যাপ সম্পর্কে** | নাম, tagline, ভার্সন, ওয়েবসাইট, Privacy Policy লিংক |

**CSV Export:** হেডার হুবহু `তারিখ,ধরন,খাত,পরিমাণ,মাধ্যম,নোট`; প্রতি লেনদেন `date,আয়|ব্যয়,ক্যাটাগরি-লেবেল,amount,মাধ্যম-লেবেল,note` (নোটে কমা থাকলে সুরক্ষিত)।
**CSV Import (`runImport`):** টেক্সট পেস্ট → লাইনে ভাগ (ফাঁকা বাদ); প্রথম লাইনে "তারিখ" থাকলে হেডার ধরে স্কিপ; প্রতি লাইন `,` দিয়ে ভাগ, **<৪ অংশ হলে স্কিপ**; `date` অবশ্যই `YYYY-MM-DD` ও `parseFloat(amount)` সত্য (০/NaN স্কিপ); ধরন `আয়→income`, `ব্যয়→expense`, অন্য সবকিছু **expense**; ক্যাটাগরি লেবেল মিললে সেই key, **না মিললে ওই ধরনের তালিকার শেষ ক্যাটাগরি** (নতুন ক্যাটাগরি তৈরি হয় না); মাধ্যম লেবেল না মিললে `cash`; বাকি অংশ কমা দিয়ে জুড়ে note। কোনো বৈধ সারি না থাকলে "কোনো বৈধ সারি পাওয়া যায়নি — এক্সপোর্ট করা CSV ফরম্যাট মেনে পেস্ট করুন।"; সফলে "N টি এন্ট্রি যোগ হয়েছে ✓" (বাংলা অঙ্ক) এবং টেক্সট-বক্স খালি। ইমপোর্টকৃত সারির `id`/`createdAt` নতুন।
**সব ডেটা মুছুন (`clearAll`):** সব ব্যক্তিগত ফিল্ড ডিফল্টে রিসেট (লেনদেন, বাজেট, টাস্ক, specialDays, দেনা, ক্যাটাগরি = ডিফল্ট সেট, categoryBudgets, accountOpening, transfers, `profileName=null`, familyMembers, bazarItems, taxes, auditLog, userAccounts, read/dismiss/completed IDs) → লোকালে persist → সাইন-ইন থাকলে **খালি অবস্থা ক্লাউডেও push** (ব্যর্থতা নীরব)। **Family Bazar/Planning ক্লাউড ডেটা মোছে না; খসড়া খাতা মোছে না; PIN/theme মোছে না।**
**Audit Log:** `{id, action, details, ts}`; ঘূর্ণায়মান **সর্বোচ্চ ২০০** (`appendAudit`); ব্যক্তিগত ডকুমেন্টের অংশ (সিঙ্ক হয়)। রেকর্ড হয়: লেনদেন/দেনা/অ্যাকাউন্ট মুছা, ডেটা ইমপোর্ট/মুছে ফেলা ইত্যাদি destructive কাজ।

### 28.5 PIN Lock `[SRC]`
- ৪ অঙ্ক। অ্যাপ খোলা/foreground-এ ফিরলে (যদি `pin` সেট) লক-স্ক্রিন; ভুল PIN → shake/ত্রুটি; সঠিক → আনলক। PIN ভুলে গেলে রিকভারি নেই (ক্লাউডে PIN নেই)।
- Flutter: PIN **hash (salted) করে `flutter_secure_storage`-এ** রাখতে হবে `[NOTE N13]`; বায়োমেট্রিক অ্যাড-অন বর্তমানে নেই → **যোগ করা যাবে না**।

### 28.6 Spec
**Permission:** Guest/Signed-in। **Offline:** guest ও লোকাল পূর্ণ; Auth নেটওয়ার্ক-নির্ভর (সাইন-ইনের সময়)। **Sync:** §31। **Errors:** auth ত্রুটি বাংলা বার্তা; import অবৈধ JSON → "ফাইলটি বৈধ নয়", কিছু বদলায় না। **Acceptance:** পরিচয়-বিচ্ছিন্নতা টেস্ট; cloud-overwrites-local ও local-pushed-when-no-cloud টেস্ট; PIN আনলক/ভুল।

---

## 29. Offline Architecture

### 29.1 নীতি
Local-first, cloud-second। প্রতিটি মিউটেশন (ক) লোকাল DB-তে তাৎক্ষণিক লেখা, (খ) `pendingChanges++`, (গ) অনলাইন+সাইন-ইন+autoSync হলে debounce push। অ্যাপ কখনো নেটওয়ার্কের জন্য UI ব্লক করে না (Family মডিউল ছাড়া যা Firestore-ক্যাশ ব্যবহার করে)।

### 29.2 Local database সুপারিশ
| স্তর | প্রযুক্তি | কী রাখে |
|---|---|---|
| **Structured আর্থিক ডেটা** | **Isar** (প্রথম পছন্দ: ইনডেক্সড query, বড় লেনদেন-তালিকা) — ব্যাকআপ বিকল্প **Hive CE** | transactions, debts(+repayments), transfers, tasks, taxes, userAccounts, specialDays, categories, auditLog, khasra drafts, দৈনিক/read ID ইত্যাদি |
| **সহজ preference** | `shared_preferences` | theme, autoSync, activeFamilyId, onboarding ফ্ল্যাগ, ছোট UI সেটিং |
| **সংবেদনশীল** | `flutter_secure_storage` | PIN hash |
| **Family ক্যাশ** | Firestore offline persistence (SDK-নিয়ন্ত্রিত) | families/* ডেটা |
**নিষিদ্ধ:** মূল structured আর্থিক ডেটা `SharedPreferences`-এ রাখা।
**ডিজাইন-সিদ্ধান্ত:** ক্লাউডে ব্যক্তিগত ডেটা এখনও **একক ডকুমেন্ট `users/{uid}`** (Firestore ১MiB সীমা বিবেচনায় বর্তমান আচরণ); লোকালে **normalized collections** (প্রতি এন্টিটি আলাদা) রাখা যায়, push-এর সময় একই JSON-আকৃতির ডকুমেন্টে সংকলিত হবে — ক্লাউড স্কিমা ও বিদ্যমান ডেটার সাথে সামঞ্জস্য বজায় থাকবে (§48)।

### 29.3 Local vs Cloud — কোন ডেটা কোথায়
| এন্টিটি | Local | Firebase | Realtime | Offline | Sync |
|---|---|---|---|---|---|
| User settings (theme/pin/autoSync) | ✅ (device) | ❌ | ❌ | ✅ | ❌ |
| Transactions | ✅ | ✅ `users/{uid}` | ❌ | ✅ | ✅ (debounce push) |
| Categories (income/expense/custom) | ✅ | ✅ | ❌ | ✅ | ✅ |
| Budget & categoryBudgets | ✅ | ✅ | ❌ | ✅ | ✅ |
| Opening balances / userAccounts | ✅ | ✅ | ❌ | ✅ | ✅ |
| Transfers | ✅ | ✅ | ❌ | ✅ | ✅ |
| Debts + Repayments | ✅ | ✅ | ❌ | ✅ | ✅ |
| Tasks (personal) | ✅ | ✅ | ❌ | ✅ | ✅ |
| Taxes | ✅ | ✅ | ❌ | ✅ | ✅ |
| Personal SpecialDays | ✅ | ✅ | ❌ | ✅ | ✅ |
| Legacy familyMembers / bazarItems | ✅ | ✅ | ❌ | ✅ | ✅ |
| Audit log (personal) | ✅ | ✅ | ❌ | ✅ | ✅ |
| Read/Dismiss/CompletedAdminTask IDs | ✅ | ✅ | ❌ | ✅ | ✅ |
| Khasra drafts | ✅ | ❌ | ❌ | ✅ | ❌ |
| Admin: notices/daily/special/tasks/FAQ | ❌ (in-memory) | ✅ global | ❌ (on-demand) | ⚠️ শেষ-লোড | ❌ |
| Family, Members, Invitations | Firestore cache | ✅ | ✅ | ⚠️ ক্যাশ-রিড | ✅ |
| FamilyPurchase | Firestore cache | ✅ | ❌ (on-demand) | ⚠️ ক্যাশ-রিড; লেখা queued | ✅ |
| Aggregates (memberMonthly/Category) | cache | ✅ | ❌ | ⚠️ | ✅ |
| PriceHistory / LocationPrices / Products / FamilyCategories | cache | ✅ | ❌ | ⚠️ | ✅ |
| FamilyPlan (+contributions/expenses/audit) | cache | ✅ | ✅ | ⚠️ ক্যাশ-রিড; transaction-মিউটেশন অনলাইন-নির্ভর | ✅ |
| Family Bazar prefs (market/location suggestions, activeFamilyId) | ✅ | ❌ | ❌ | ✅ | ❌ |
| Linked personal tx (source=family-bazar) | ✅ | ✅ (ব্যক্তিগত ডকের অংশ) | ❌ | ✅ | ✅ |

---

## 30. Firebase Architecture

- **Firebase Authentication:** Google + Email/Password।
- **Cloud Firestore:** একটি ডেটাবেস; offline persistence **চালু** (Flutter-এ ডিফল্ট; `Settings(persistenceEnabled: true, cacheSizeBytes: unlimited বা বড় সীমা)`)।
- **কোনো Cloud Functions, Storage, FCM, Analytics নেই** — যোগ করা যাবে না।
- **Config:** `firebase_options.dart` (FlutterFire CLI) — কী/ID সোর্স-রেপোতে হার্ডকোড-কপি নয়, প্রজেক্ট কনফিগ থেকে জেনারেট। Primary Admin UID/Email → `AppConfig` (সোর্সের `firestore.rules` ধ্রুবকের সাথে **অভিন্ন** থাকতে হবে)।
- **Rules:** `firestore.rules` বিদ্যমান ফাইল **অপরিবর্তিত** রেখে ডিপ্লয় (§49)।
- **Listener নীতি:** শুধু families/members/invitations/plans (§23.11); বাকি on-demand।

## 31. Data Synchronization

### 31.1 ব্যক্তিগত ডেটা (সব মডিউল একরকম)
```
Local write ──► pendingChanges++ ──► [online && signedIn && autoSync] ──► debounce 1.5s ──► set users/{uid} (পুরো ডক)
   ├─ সফল: syncStatus=synced, lastSyncedAt=now, pendingChanges=0
   ├─ ব্যর্থ: syncStatus=error, pendingChanges++ (পুনঃচেষ্টা সংযোগ ফিরলে)
   └─ offline: pendingChanges++ ; reconnect effect → flush
```
| ফ্লো | আচরণ |
|---|---|
| **Local → Firebase** | উপরের push; manual "এখনই সিঙ্ক" (অফলাইনে → error, `pending≥1`) |
| **Realtime** | ব্যক্তিগত ডেটায় নেই |
| **Update** | পুরো-ডক set (last-write-wins) |
| **Delete** | লোকালে মুছে (undo-সহ) → পরের push-এ ডকে অনুপস্থিত |
| **Conflict** | **কোনো merge নেই।** দুই ডিভাইসে অফলাইন সম্পাদনা → শেষে যে push করে সে জেতে; login-এ ক্লাউড লোকালকে ওভাররাইট করে। Flutter-এ নতুন merge বানানো যাবে না; কেবল ডকুমেন্টেড সীমাবদ্ধতা। |
| **Restore** | Settings → "ক্লাউড থেকে ফিরিয়ে আনুন": আগে `previewCloudVsLocal` (দুই পাশের সংখ্যা তুলনা) → `pendingChanges>0` হলে বিশেষ সতর্কতা → কনফার্ম → লোকাল ওভাররাইট, `pending=0` |
| **Logout/Switch** | §28.1 |

### 31.2 Family Bazar
```
Purchase save ──► Firestore atomic batch (purchase + aggregates + price) ──► [অফলাইনে: SDK queue → সংযোগে অটো-commit]
              ├─► location price (best-effort, আলাদা)
              └─► onExpenseSync → ব্যক্তিগত লেজার লিঙ্কড tx (লোকাল তাৎক্ষণিক → §31.1 push)
Realtime: families/members/invitations listener (role বদল → UI তাৎক্ষণিক)
Delete: batch (purchase delete + aggregate −delta + price rows delete + location release) ; লিঙ্কড tx মুছে
Update (edit): old→new delta একই batch
Conflict: aggregate = increment() (অ্যাটমিক); দুই ডিভাইসে একই purchase edit → last-write-wins; ID-নির্ধারণ (FNV) concurrent product-ডুপ্লিকেট এড়ায়
```
### 31.3 Family Planning
```
Create/Contribute/Verify/Approve/... ──► plans/{id} মিউটেশন (Flutter: runTransaction)
Realtime: plans onSnapshot → সব সদস্যের ডিভাইসে লাইভ (status, collected, badge)
Conflict: transaction retry; দুজন একসাথে verify করলে দুটিই রেকর্ড হয়
Delete: plan ডক মুছা (creator/owner/admin)
Offline: ক্যাশ-রিড; মিউটেশন অনলাইন প্রয়োজন (বার্তা)
```
### 31.4 অন্যান্য
| মডিউল | Local | Firebase | Realtime | Conflict | Delete | Update |
|---|---|---|---|---|---|---|
| Khasra | ✅ শুধু | ❌ | ❌ | n/a (একক-ডিভাইস) | confirm, স্থায়ী | পুনঃসংরক্ষণ (`updatedAt`) |
| Admin কনটেন্ট | ❌ | ✅ | ❌ | last-write | inline confirm | প্রতি লেখার পর রিফেচ |
| Invitations | cache | ✅ | ✅ | status-মেশিন (pending→accepted/declined/cancelled) | cancel | rules-নিয়ন্ত্রিত |

---
## 32. Data Models (Dart specification)

নীতি: প্রতিটি মডেল `immutable` (freezed বা hand-written `copyWith`, `==`, `hashCode`), `fromJson/toJson` (Firestore/Local JSON-এর **বিদ্যমান ফিল্ড-নাম হুবহু** — কারণ বিদ্যমান ক্লাউড ডেটার সাথে সামঞ্জস্য বাধ্যতামূলক), টাকার মান `double` নয়: **`Decimal`/`int paisa` নয় — বিদ্যমান আচরণ অনুযায়ী `double` + `round2` সহায়ক** (পরিবর্তন করলে বিদ্যমান ডেটার সাথে মিল ভাঙে)। তারিখ = `String "YYYY-MM-DD"` (কোর লজিকে) + টাইমস্ট্যাম্প = `int` (epoch ms)।
ছক-সংকেত: **L**=Local, **F**=Firebase, **R**=Realtime, **O**=Offline, **S**=Sync।

| Entity | বিদ্যমান? | L | F | R | O | S |
|---|---|---|---|---|---|---|
| UserProfile (`profileName`, device prefs) | ✅ | ✅ | ✅(name) | ❌ | ✅ | ✅ |
| Transaction | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ |
| Category (income/expense) | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ |
| Budget (+categoryBudgets) | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ |
| Account (dynamic) + accountOpening | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ |
| Transfer | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ |
| Debt, Repayment | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ |
| Task, AdminTask | ✅ | ✅/❌ | ✅ | ❌ | ✅/⚠️ | ✅ |
| Tax | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ |
| SpecialDay (personal), AdminSpecialDay | ✅ | ✅/❌ | ✅ | ❌ | ✅/⚠️ | ✅ |
| KhasraDocument, KhasraLine | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ |
| Family, FamilyMember, FamilyInvitation | ✅ | cache | ✅ | ✅ | ⚠️ | ✅ |
| FamilyProduct, FamilyCategory | ✅ | cache | ✅ | ❌ | ⚠️ | ✅ |
| FamilyPurchase (+Item) | ✅ | cache | ✅ | ❌ | ⚠️ | ✅ |
| FamilyPriceHistory, FamilyLocationPrice | ✅ | cache | ✅ | ❌ | ⚠️ | ✅ |
| FamilyMemberMonthly/CategoryMonthly/OtherMonthly | ✅ | cache | ✅ | ❌ | ⚠️ | ✅ |
| FamilyBudget (`budgets/current`) | ✅ | cache | ✅ | ❌ | ⚠️ | ✅ |
| FamilyPlan, FamilyContribution, FamilyPlanExpense | ✅ (embedded) | cache | ✅ | ✅ | ⚠️ | ✅ |
| AuditLog (personal), PlanAuditEntry | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ |
| Notice, DailyMessage, FaqItem | ✅ | ❌ | ✅ | ❌ | ⚠️ | ❌ |
> `FamilyPlanExpense` ও `FamilyContribution` আলাদা সাব-কালেকশন **নয়** — plan ডকুমেন্টের ভেতরে অ্যারে। অনুমানে আলাদা collection বানানো যাবে না।

### 32.1 Personal
```dart
class Transaction { String id; TxType type /*income|expense*/; double amount; String category /*key*/;
  String date /*yyyy-MM-dd*/; String note; String? method /*cash|bank|bkash|nagad|rocket|card|other*/;
  String? accountId; int createdAt;
  String? familyPurchaseId; String? familyId; String? source /*"family-bazar"*/; // sync-linked
  String? familyMemberId; String? bazarItemId; }                                  // legacy links
class Category { String key; String label; String icon /*emoji or built-in svg id*/; bool isCustom; }
class BudgetState { double budget; Map<String,double> categoryBudgets; }
class UserAccount { String id, name; AccountType type /*cash|bank|mfs|card|other*/; double openingBalance;
  String? openingBalanceDate; bool active; int createdAt, updatedAt; }
class Transfer { String id; String? fromMethod, toMethod, fromAccountId, toAccountId;
  double amount; String date; String? time; String note; int createdAt; }
class Debt { String id; DebtType type /*receivable|payable*/; String person; double amount; String date; String? time;
  String? dueDate; String method; String note; List<Repayment> repayments; String? dueNotified; int createdAt; }
class Repayment { String id; double amount; String date; String? time; String note; String? method; String? accountId; int createdAt; }
class Task { String id; String text; bool done; String? date, time, category, note, repeat, reminderDate, reminderTime, remindedAt; }
class AdminTask { String id, title, description, category; String? dueDate, time, repeat, reminderDate, reminderTime; bool published; int createdAt; }
class Tax { String id, name; double amount; String? category, dueDate, time, note, repeat, reminderDate, reminderTime, remindedAt; bool paid; int createdAt; }
typedef SpecialDays = Map<String /*yyyy-MM-dd*/, List<String> /*labels*/>;
class AdminSpecialDay { String id, title, description; String dateType /*gregorian|hijri*/; String? date;
  ({int year,int month,int day})? hijri; String? recurrence /*"hijri"|null*/; int? hijriMonth, hijriDay; int createdAt; }
class AuditLogEntry { String id; String action; String details; int ts; }              // max 200 rolling
class LegacyFamilyMember { String id, name, relation; ... }                              // বিদ্যমান ফিল্ড হুবহু
class BazarItem { String id; String name; double? price; double? qty; String? unit; bool purchased; String? date; String? memberId; ... }
```
> `Task` ও `Tax`-এ **amount নেই** (Task) — Tax-এ `amount` আছে, Task-এ নেই।

### 32.2 Khasra
```dart
class KhasraLine { String desc; String qty; String unit /*kg|gm|pcs|ltr|ml|dozen|packet|box|bag|bundle*/; String rate; String discount; } // স্ট্রিং হিসেবেই (টাইপ-করা মান)
class KhasraDocument { String id /*kk{base36}{rand5}*/; String name; String date; List<KhasraLine> rows;
  double totalDiscount; double grandTotal; int createdAt, updatedAt; }
```

### 32.3 Family
```dart
class Family { String id; String name; String ownerId; List<String> memberUids; String? photoURL; Map settings; String? lastRemovedUid; int createdAt, updatedAt; }
class FamilyMember { String uid; String name; String? phone; String relation; Role role; String status /*active*/;
  FamilyPermissions permissions /*7 bools*/; String? inviteId; String? photoURL; int joinedAt, updatedAt; }
enum Role { owner, admin, member, viewer }
class FamilyPermissions { bool monthlyTotal, categorySummary, purchaseDetails, priceHistory, locationComparison, reports, memberManagement; }
class FamilyInvitation { String id, familyId, familyName, invitedEmail, relation; Role role; FamilyPermissions permissions;
  String? phone; InviteStatus status /*pending|accepted|rejected|cancelled*/; String invitedBy; int createdAt, expiresAt; int? respondedAt; }
class FamilyCategory { String id; String name; String icon; String group /*grocery|household*/; }   // custom; defaults const
class FamilyProduct { String id /*p_hash*/; String name; String? categoryId; String? category; String? unit; List<String> aliases; bool archived; int createdAt, updatedAt; }
class FamilyPurchase { String purchaseId; String memberId, memberName; String date; String month; String market, location, note;
  bool trackPrice; List<PurchaseItem> items /*1..40*/; double total; int createdAt, updatedAt; String? familyId; }
class PurchaseItem { String itemId; String productId; String productName; String? categoryId; String? category;
  double quantity; String unit; double unitPrice; double total; }
class FamilyPriceHistory { String id /*purchaseId_itemId*/; String productId, productName, memberId; double price; String? unit; String date, month, purchaseId; }
class FamilyLocationPrice { String id; String productId, productName, location; String? market; double price; String? unit; String date, memberId, purchaseId, itemId; }
class MemberMonthly { String memberId, month; double total; int count; Map<String,double> days; }
class MemberCategoryMonthly { String memberId, month; Map<String,({String name,double total})> categories; }
class MemberOtherMonthly { String memberId, month; double total; }
class FamilyBudget { double monthlyAmount; int updatedAt; String updatedBy; }          // budgets/current
```
### 32.4 Family Planning
```dart
class FamilyPlan { String id, title /*≤60*/, type, icon; double targetAmount; double? perMemberTarget; String startDate, endDate, description;
  ParticipantMode participantMode /*all|selected*/; List<String> participantUids; ContributionMode contributionMode /*monthly|once|both*/;
  bool expenseApprovalRequired; PlanStatus status; String createdBy; String? createdByName; int createdAt;
  String? approvedBy, approvedByName; int? approvedAt; String? rejectedBy; int? rejectedAt; String rejectionReason;
  String? changesRequestedBy; int? changesRequestedAt; String changesRequestNote; String? lastModifiedBy; int? lastModifiedAt; int? completedAt;
  List<FamilyContribution> contributions; List<FamilyPlanExpense> expenses; List<PlanAuditEntry> auditLog /*≤200*/; }
enum PlanStatus { pending_approval, changes_requested, active, target_achieved, completed, rejected, paused, cancelled }
class FamilyContribution { String id, memberUid, memberName; double claimedAmount; String date, paymentMethod, note; String? receiptName;
  ContribStatus status /*pending|approved|rejected|partial*/; double? receivedAmount; String? verifiedBy, verifiedByName; int? verifiedAt; String rejectionReason; int createdAt; }
class FamilyPlanExpense { String id, title; double amount; String date, note; String? addedBy; String addedByName; ExpenseStatus status /*approved|pending*/; int createdAt; }
class PlanAuditEntry { String id; int ts; String? actorUid; String actorName; String action; String details; }
```
### 32.5 Global
```dart
class Notice { String id, title, content; bool published; int createdAt, updatedAt; }
class DailyMessage { String id, title, content; int createdAt; }
class FaqItem { String id, question, answer; int createdAt; }
```
সব এন্টিটির সম্পূর্ণ JSON ফিল্ড তালিকা সোর্স (`app/02-main-app.js` `applyUserData`/`persistAll`, `family-*-core.js` constructors) থেকে নিতে হবে; উপরের তালিকা প্রয়োজনীয় ন্যূনতম।

---

## 33. Permission Matrix

### 33.1 ব্যক্তিগত মডিউল
| অ্যাকশন | Guest | Signed-in | Primary Admin |
|---|---|---|---|
| লেজার/বাজেট/দেনা/রিপোর্ট/সার্চ/টাস্ক/ট্যাক্স/ক্যালেন্ডার/খসড়া খাতা | ✅ | ✅ | ✅ |
| ক্লাউড ব্যাকআপ/সিঙ্ক/Restore | ❌ | ✅ | ✅ |
| অ্যাডমিন কনটেন্ট পড়া | ❌ | ✅ | ✅ |
| অ্যাডমিন কনটেন্ট লেখা (নোটিশ/বার্তা/দিবস/টাস্ক/FAQ/Bulk) | ❌ | ❌ | ✅ |
| Family Bazar / Planning | ❌ (লগইন প্রয়োজন) | ✅ | ✅ |

### 33.2 Family Bazar
| অ্যাকশন | Owner | Admin | Member | Viewer |
|---|---|---|---|---|
| পরিবার তৈরি | ✅ (যেকোনো signed-in) | – | – | – |
| পরিবারের নাম/ছবি/settings | ✅ | ✅ | ❌ | ❌ |
| পরিবার মোছা | ✅ | ❌ | ❌ | ❌ |
| পরিবার ছাড়া | ❌ (owner নয়) | ✅ | ✅ | ✅ |
| মাসিক বাজেট সেট | ✅ | ✅ | ❌ | ❌ |
| ক্যাটাগরি যোগ/সম্পাদনা/মোছা | ✅ | ✅ | ❌ | ❌ |
| পণ্য rename/category/archive | ✅ | ✅ | ✅ (canWrite, rules create/update) | ❌ |
| পণ্য delete | ✅ | ✅ | ❌ | ❌ |
| Purchase যোগ | ✅ | ✅ | ✅ | ❌ |
| নিজের purchase সম্পাদনা | ✅ | ✅ | ✅ | ❌ |
| নিজের purchase মোছা | ✅ | ✅ | ✅ | ✅ (rules: নিজের; কিন্তু তৈরি করতে পারে না) |
| অন্যের purchase মোছা (rules) | ✅ | ❌ | ❌ | ❌ |
| অন্যের purchase বিস্তারিত দেখা | ✅ | permission `purchaseDetails` (ডিফল্ট ❌) | permission (ডিফল্ট ❌) | permission (ডিফল্ট ❌) |
| মাসিক মোট (অন্যদের) | ✅ | perm `monthlyTotal` (ডিফল্ট ✅) | perm (ডিফল্ট ✅) | perm (ডিফল্ট ✅) |
| ক্যাটাগরি সারাংশ | ✅ | perm (ডিফল্ট ✅) | perm (ডিফল্ট ✅) | perm (ডিফল্ট ✅) |
| দামের ইতিহাস | ✅ | perm (ডিফল্ট ✅) | perm (ডিফল্ট ✅) | perm (ডিফল্ট ❌) |
| এলাকাভিত্তিক তুলনা | ✅ | perm (ডিফল্ট ✅) | perm (ডিফল্ট ❌) | perm (ডিফল্ট ❌) |
| রিপোর্ট | ✅ | perm (ডিফল্ট ✅) | perm (ডিফল্ট ✅) | perm (ডিফল্ট ✅) |
| সদস্য আমন্ত্রণ | ✅ | ✅ | perm `memberManagement` | perm |
| সদস্যের role/permission বদল | ✅ (admin/member/viewer) | ✅ (member/viewer শুধু; admin/owner নয়) | perm-নির্ভর (member/viewer) | perm-নির্ভর |
| সদস্য সরানো | ✅ (owner বাদে) | ✅ (admin ছাড়া) | perm-নির্ভর | perm-নির্ভর |
| অন্যের name/phone/relation সম্পাদনা | ✅ | ❌ | ❌ | ❌ |
| নিজের name/phone/relation | ✅ | ✅ | ✅ | ✅ |
| আমন্ত্রণ বাতিল (যে পাঠিয়েছে) | ✅ | ✅ | ✅(যদি পাঠায়) | – |
> `owner` সর্বদা সব permission `true`। অন্যকে এমন permission দেওয়া যায় না যা দাতার নিজের নেই (Owner ছাড়া)। ডিফল্টগুলো `permissionPreset` — ক্লিক করে পরিবর্তনযোগ্য।
> ✅ = ডিফল্টে অনুমোদিত, "perm" = সংশ্লিষ্ট permission-flag-এর ওপর নির্ভর।

### 33.3 Family Planning
| অ্যাকশন | Owner | Admin | Member | Viewer |
|---|---|---|---|---|
| Plan তৈরি (→ pending) | ✅ | ✅ | ✅ | ❌ |
| Plan দেখা | ✅ | ✅ | ✅ | ✅ (সব সদস্য read) |
| Approve / Reject / Request changes | ✅ | ✅ | ❌ | ❌ |
| নিজের plan edit & resubmit (`changes_requested`) | ✅ | ✅ | ✅ (creator) | ❌ |
| Active plan-এর তথ্য সম্পাদনা | creator বা owner/admin | creator বা owner/admin | creator | ❌ |
| Contribution দাবি | ✅ | ✅ | ✅ | ❌ |
| Contribution verify (পেয়েছি/আংশিক/প্রত্যাখ্যান) | ✅ | ✅ | ❌ | ❌ |
| Expense যোগ | ✅ | ✅ | ✅ (canWrite) | ❌ |
| Plan "সম্পন্ন" (`target_achieved` → `completed`) | ✅ | ✅ | ❌ | ❌ |
| Plan মোছা | ✅ | ✅ | creator | ❌ |
| Audit দেখা | সব সদস্য | | | |
> `isParticipant` শুধু UI-তে "আমার প্ল্যান" ও contribute-বোতাম প্রদর্শনে ব্যবহৃত; rules-এ নয়।

### 33.4 Notifications/Tasks/Tax
সব ব্যক্তিগত; কোনো role-নির্ভরতা নেই; অ্যাডমিন টাস্কের "সম্পন্ন চিহ্ন" প্রতি-ব্যবহারকারী নিজের ডকে।

---

## 34. Security Requirements

1. **Authentication বাধ্যতামূলক** ক্লাউড-ডেটার জন্য; guest কখনো Firestore-এ লেখে না।
2. **User isolation:** `users/{uid}` — শুধু `request.auth.uid == uid` পড়া/লেখা।
3. **Family isolation:** পরিবার-ডকুমেন্ট পড়া `uid ∈ memberUids`; সাব-কালেকশনে `isMember(familyId)` (সদস্য-ডকের `status=="active"`); অন্য পরিবারের ডেটা পড়া/লেখা অসম্ভব।
4. **Role-based access:** viewer-এর কোনো purchase/product/price/plan লেখা নেই (`canWrite` = active ∧ role≠viewer)।
5. **Owner/Admin সীমা:** admin-কে শুধু owner পরিবর্তন করে; owner role কেউ বদলায় না; পরিবার মোছা শুধু owner; grant-limit (`grantable`)।
6. **Invitation নিরাপত্তা:** তৈরি — `canManage`, `invitedEmail` lowercase+regex, `expiresAt ≤ now+৩০ দিন`; পড়া/গ্রহণ — **`email_verified == true` ও ইমেইল মিল**; গ্রহণ সদস্য-ডক তৈরির সাথে `role`/`permissions` আমন্ত্রণের সাথে মেলা বাধ্যতামূলক।
7. **Purchase লেখা:** শুধু নিজের `memberId`; `month`/`date` ফরম্যাট সঙ্গতি; ১–৪০ আইটেম; `total ≥ 0`। Aggregate/price-history ডকও শুধু নিজের `uid_` প্রিফিক্স/`memberId`।
8. **Plan নিরাপত্তা:** তৈরি = `pending_approval`, খালি `contributions/expenses`, `createdBy == uid`; অনুমোদন-বদল শুধু নির্দিষ্ট ফিল্ডে (`affectedKeys().hasOnly`); contribution append-only (`size+1`) সদস্যের জন্য; যাচাই শুধু owner/admin; expense append-only।
9. **Admin কনটেন্ট:** লেখা শুধু Primary Admin UID (rules-এ ধ্রুবক); UI-র `isAdmin` কেবল সুবিধা।
10. **সংবেদনশীল ডেটা:** PIN → secure storage (hash); অ্যাক্সেস টোকেন লগ নয়; ক্লাউডে পাসওয়ার্ড নেই; Crash/analytics SDK যোগ নয় (বিদ্যমান নেই)।
11. **Client-validated + server-enforced:** UI validation বার্তা বাংলা; সার্ভার rules চূড়ান্ত।
12. **ডেটা-ট্রান্সপোর্ট:** Firebase SDK TLS; Android `usesCleartextTraffic=false`।
13. `firestore.rules` ফাইল **অপরিবর্তিত** রাখা এবং Flutter ডিপ্লয় পাইপলাইনে `firebase deploy --only firestore:rules` দিয়ে একই ফাইল ব্যবহার; Firebase Emulator Rules টেস্ট (§40) বাধ্যতামূলক।

---

## 35. UI/UX Requirements

### 35.1 Visual identity (বজায় রাখা)
- **থিম:** আলো + ডার্ক + অটো; টোকেন-ভিত্তিক রং (`success`, `danger`, `gold`, `primary`, `surface`, `muted`) — মূল UI সবুজ-প্রাধান্য ফিনান্স প্যালেট; আয় সবুজ, ব্যয় লাল, সতর্কতা সোনালি/অ্যাম্বার। সঠিক HEX মান বিদ্যমান CSS ভেরিয়েবল (`--hk-*`) থেকে ডিজাইন-টোকেন ফাইলে (`core/theme/tokens.dart`) পোর্ট; এ PRD-তে নতুন রং উদ্ভাবন নয়।
- **রং-টোকেন (বিদ্যমান `--hk-*` থেকে পোর্ট `[SRC: app/11-styles.js]`):**

| টোকেন | আলো | ডার্ক |
|---|---|---|
| `bg` | `#F5EFE2` | `#101716` |
| `card` | `#FFFFFF` | `#17211F` |
| `surface-soft` | `#F5EFE2` | `#1B2422` |
| `header-bg` | `#0F5B46` | `#0B3F30` |
| `success` | `#0F5B46` | `#4FBE86` |
| `success-mid` | `#217E68` | `#5FCB95` |
| `danger` | `#B84A3A` | `#E0776A` |
| `danger-mid` | `#E68A79` | `#C2604D` |
| `danger-soft` | `#E3B3A5` | `#6B3C34` |
| `gold` | `#D8A64A` | (একই `#D8A64A`) |
| `border` / `border-soft` / `border-light` / `border-med` / `border-strong` | `#E3DCC9` / `#E9E0C8` / `#DCCFAE` / `#C9BB98` / `#D8CBA8` | `#26332F` / `#26332F` / `#2E3B36` / `#3A4A43` / `#33443E` |
| `label` / `text-muted` / `text-muted-2` | `#8A9285` / `#687260` / `#5C6B5F` | `#7C8F84` / (থিম-অনুযায়ী) / `#B7C4BB` |
| `muted-on-dark` / `-2` | `#B8C4C7` / `#9FB3B8` | `#9FB0A6` / `#8FA89A` |
> অবশিষ্ট টোকেন (`primary`, `text`, `income/expense` ইত্যাদি) `app/11-styles.js` থেকে সম্পূর্ণ তালিকা পোর্ট করতে হবে; এই তালিকা নমুনা-সত্যায়িত অংশ। পরিচিতি: ক্রিম/পার্চমেন্ট পটভূমি, গাঢ় সবুজ হেডার, সোনালি অ্যাকসেন্ট।
- **Typography:** বাংলা-প্রথম ফন্ট — **Hind Siliguri / Noto Sans Bengali** (বান্ডল করা, অফলাইন)। বডি ১৪–১৬sp, সেকেন্ডারি ১২–১৩sp, কার্ড-শিরোনাম ১৬–১৮sp semibold, বড় সংখ্যা (ব্যালেন্স) ২৪–৩২sp bold; `textScaleFactor` সম্মান করা (১.০–১.৫ পর্যন্ত লেআউট না ভাঙা)।
- **Spacing:** ৪-pt গ্রিড; পাতার প্যাডিং ১৬; কার্ড অভ্যন্তরীণ ১২–১৬; কার্ডের মধ্যে ১২; কার্ড ব্যাসার্ধ ১২–১৬; বোতাম ব্যাসার্ধ ১২।
- **Cards:** elevation ০–২, বর্ডার-সূক্ষ্ম, সারাংশ-কার্ডে আইকন+শিরোনাম+মান।
- **Buttons:** Primary (filled), Secondary (outlined/tonal), Danger (লাল), Text; সর্বনিম্ন উচ্চতা ৪৮dp; loading-এ spinner + disable।
- **Forms:** বাংলা label, inline error (লাল, `Semantics` সহ), সংখ্যা-কীবোর্ড (`TextInputType.numberWithOptions(decimal: true)`) বাংলা অঙ্ক গ্রহণ করে; তারিখ = Material `showDatePicker` (বাংলা লোকেল), সময় = `showTimePicker`।
- **Bottom Navigation:** ৬ আইটেম (হোম, টাইমলাইন, দেনা, ফ্যামিলি, রিপোর্ট, খুঁজুন) — `NavigationBar`; আইকন+ছোট লেবেল; সক্রিয় সূচক। Family Bazar-এর নিজস্ব ৫-ট্যাব বার।
- **Top Header:** ☰, শিরোনাম/ব্যালেন্স, 📅, 📋(badge), 🔔(badge), ⚙; স্ট্যাটাস-বার safe-area মেনে।
- **FAB:** নির্দিষ্ট ট্যাবে (§10); bottom-nav-এর উপরে, কনটেন্ট ঢাকে না (list-bottom padding)।
- **Modal/Sheet:** `showModalBottomSheet(isScrollControlled)` বা fullscreen route; কীবোর্ডে `viewInsets` প্যাডিং; drag-handle; ✕।
- **Loading:** ফুল-স্ক্রিন প্রাথমিক লোডার ("খাতা খোলা হচ্ছে…"); তালিকায় skeleton/shimmer; বোতামে inline spinner।
- **Empty states:** প্রতিটি তালিকার নির্দিষ্ট বাংলা বার্তা (§ ফিচার-অংশ) + প্রাসঙ্গিক CTA।
- **Error states:** inline/banner/SnackBar + "আবার চেষ্টা করুন"।
- **Confirmation:** destructive কাজে `AlertDialog` (দেনা/লেনদেন মোছায় Undo-banner; পরিবার মোছা, সব ডেটা মুছা, প্ল্যান মোছা, Khasra মোছা, Restore-এ confirm)।
- **Responsive:** মোবাইল পোর্ট্রেট-প্রথম; ট্যাবলেটে সর্বোচ্চ কনটেন্ট-প্রস্থ ~৬০০dp কেন্দ্রীভূত; ল্যান্ডস্কেপ সমর্থিত কিন্তু আলাদা লেআউট নয়।
- **Charts:** Donut, Bar/Combo, Sparkline, Progress — কাস্টম `CustomPainter` বা `fl_chart`; সংখ্যা ও অ্যাক্সেসিবল সারাংশ-টেক্সট।
- **Animations:** সংযত (sheet, fade); `reduce motion` সম্মান।
- **Haptics/Sound:** নেই (যোগ করা যাবে না)।

### 35.2 Bengali numerals / ফরম্যাট `[SRC: fmt]`
- সব সংখ্যা প্রদর্শনে **বাংলা অঙ্ক** (০–৯) ও **দক্ষিণ-এশীয় গ্রুপিং** (`১২,৩৪,৫৬৭`): শেষ ৩ অঙ্কের পর ২-২ করে কমা।
- টাকা `৳` প্রিফিক্স (লেজার/ড্যাশবোর্ড); Khasra-য় `৳` সাফিক্স।
- ইনপুটে বাংলা/ইংরেজি দু-ধরনের অঙ্ক, `,`, `৳`, `।`(দশমিক) গ্রহণ।
- তারিখ প্রদর্শন: `২৭ সেপ্টেম্বর, ২০২৬` / `{বার}, {তারিখ}`; ইংরেজি মাসের নাম বাংলায়; বার: রবি, সোম, মঙ্গল, বুধ, বৃহস্পতি, শুক্র, শনি।

## 36. Localization

- **ডিফল্ট ভাষা:** বাংলা (`bn_BD`); সব লেবেল/বার্তা বাংলা। English fallback: যেখানে বিদ্যমান UI ইংরেজি ব্যবহার করে (যেমন মাধ্যমের নাম "Nagad", ইউনিট `kg/gm/L/ml/pcs`, ইমেইল, ব্র্যান্ড, স্ট্যাটাস লেবেল "Offline/Synced" যদি তাই থাকে)।
- ARB ফাইলে স্ট্রিং (`app_bn.arb` প্রাথমিক, `app_en.arb` fallback) — কিন্তু **ইংরেজি UI-ভাষা বদলের সুইচ বর্তমানে নেই → যোগ করা যাবে না**; ARB কাঠামো ভবিষ্যৎ-সামঞ্জস্যের জন্য।
- বাংলা তারিখ (বঙ্গাব্দ, ১৪ এপ্রিল নববর্ষ) ও হিজরি (বাংলা মাসনাম) §17–18।
- সংখ্যা ফরম্যাটার: কেন্দ্রীয় `BnFormat` (core/utils)।
- সাজানো: বাংলা-সচেতন তুলনা অপ্রয়োজনীয় (বর্তমানে তারিখ/পরিমাণ-ভিত্তিক)।

## 37. Accessibility

- প্রতিটি আইকন-বোতামে `Semantics(label: …)`/`tooltip` (বাংলা): "মেনু", "ক্যালেন্ডার", "টাস্ক", "নোটিফিকেশন", "সেটিংস", "মুছুন" ইত্যাদি।
- টাচ-টার্গেট ≥ 48×48dp; ঘনিষ্ঠ আইকন-সারিতে ফাঁক।
- কনট্রাস্ট WCAG AA (৪.৫:১) আলো ও ডার্ক উভয় থিমে; **শুধু রঙে অর্থ নয়** (আয়/ব্যয়ে চিহ্ন +/−, বাজেটে টেক্সট লেবেল)।
- ফন্ট সাইজ সিস্টেম-স্কেল মেনে; `MediaQuery.textScaler`; ওভারফ্লো এড়াতে `Flexible`/wrap।
- স্ক্রিন-রিডার (TalkBack): পড়ার ক্রম যৌক্তিক; চার্টের সারাংশ-টেক্সট; `liveRegion` দিয়ে টোস্ট/undo-banner ঘোষণা; modal খুললে ফোকাস সরানো ও বন্ধে ফেরানো।
- ফর্মে `autofillHints`, ত্রুটি-ক্ষেত্রে ফোকাস।
- Reduce motion সম্মান।

## 38. Error Handling (প্রতি মডিউল)

সাধারণ বার্তা-নীতি: বাংলা, মানবিক, করণীয়-সহ; প্রযুক্তিগত স্ট্যাক ব্যবহারকারীকে নয়।
| ত্রুটি | আচরণ |
|---|---|
| **Network** | ব্যক্তিগত মডিউলে ব্লক নয় (লোকালে সংরক্ষণ, `pendingChanges++`); sync-চিপ "Offline"; Family মডিউলে ক্যাশ-রিড + "ইন্টারনেট সংযোগ নেই" টোস্ট; Plan মিউটেশনে "ইন্টারনেট প্রয়োজন" |
| **Firebase** | `friendlyError`: `permission-denied`→"এই কাজের অনুমতি নেই", `unavailable/network`→"ইন্টারনেট সংযোগ পরীক্ষা করুন", `unauthenticated`→"আবার লগইন করুন", `not-found`→"পাওয়া যায়নি", অন্য→"কিছু একটা ভুল হয়েছে, আবার চেষ্টা করুন" |
| **Validation** | ফিল্ডের নিচে/ফর্ম-শীর্ষে বার্তা (প্রতি ফিচারে হুবহু বার্তা-তালিকা); সার্ভার কখনো অবৈধ ডেটা পায় না |
| **Permission** | UI-তে বোতাম লুকানো/লকড; সার্ভার deny হলে টোস্ট; admin ops-এ "অনুমতি নেই" |
| **Empty data** | প্রতি তালিকার নির্দিষ্ট বার্তা + CTA |
| **Sync error** | `syncStatus=error`, চিপ লাল; স্বয়ংক্রিয় পুনঃচেষ্টা সংযোগ ফিরলে; manual "এখনই সিঙ্ক" |
| **Local DB error** | `saveErr` banner "সংরক্ষণে সমস্যা হয়েছে — স্টোরেজ ভরা কিনা দেখুন"; ডেটা-হ্রাস এড়াতে মেমরিতে রাখা ও পুনঃচেষ্টা; ক্র্যাশ নয় |
| **Auth** | বাংলা বার্তা (§28.2) |
| **Reminder permission denied** | in-app banner কাজ করে; Settings-এ অবস্থা + নির্দেশনা |
| **Hijri out-of-range** | "—" |
| **PDF/Print ফন্ট ব্যর্থ** | ত্রুটি-বার্তা, ভাঙা ফাইল নয় |

---

## 39. Performance

- **Local DB ইনডেক্স:** `Transaction(date, type, category, method, accountId, familyPurchaseId)`; `Debt(dueDate)`; `Task(reminderDate)`; `Tax(dueDate, paid)`; `KhasraDocument(date)`।
- **Pagination/lazy:** লেনদেন তালিকা `ListView.builder` (sliver) + পেজড কোয়েরি (৫০টি/পাতা), Search ফলাফলও; Timeline শুধু ৭ দিন; Dashboard আঁচড়ে সব-লেনদেন স্ক্যান নয় — ইনক্রিমেন্টাল/ক্যাশ্ড aggregate (মাস-ভিত্তিক) ও `select` কোয়েরি।
- **Heavy গণনা** (Reports, health score) isolate/`compute` বা memoized provider; ৫০k লেনদেনেও <১৬ms ফ্রেম।
- **Debounce:** cloud push ১.৫s; Search ৩০০ms; Khasra কীস্ট্রোক গণনা সরাসরি (সস্তা)।
- **Firestore read optimization:** Family dashboard aggregate ডক (কয়েকটি ছোট) থেকে; purchases মাসিক `limit(400)`; priceHistory/locations প্রয়োজনে (product sheet খুললে); listener কেবল families/members/invitations/plans।
- **Listener নিয়ম:** সক্রিয় পরিবারের জন্যই; Family মডিউল বন্ধ হলে unsubscribe; স্ক্রিন-ব্যাকগ্রাউন্ডে `pause`।
- **স্টার্টআপ:** লোকাল ডেটা প্রথমে (<১s), ক্লাউড fetch ব্যাকগ্রাউন্ডে; ফন্ট/অ্যাসেট প্রি-ক্যাশ।
- **Image/Asset:** কোনো রিমোট ইমেজ নয় (বিদ্যমান: প্রোফাইল ফটো URL ছাড়া); আইকন SVG/emoji।
- **Large state:** Riverpod `select`/`.family` দিয়ে সংকীর্ণ rebuild।

---
## 40. Testing Strategy

### 40.1 স্তর ও টুল
| স্তর | টুল | লক্ষ্য |
|---|---|---|
| Unit | `flutter_test`, `test` | pure domain: গণনা, validators, Hijri, Khasra, Plan, Bazar core |
| Widget | `flutter_test` + golden | ফর্ম validation বার্তা, Enter-নেভিগেশন, empty/error state, role-গেটেড বোতাম |
| Integration | `integration_test` | লেজার→ব্যালেন্স→রিপোর্ট; অফলাইন→অনলাইন sync; Family Bazar→ব্যক্তিগত লেজার |
| Rules | Firebase Emulator + `@firebase/rules-unit-testing` (Node) | `firestore.rules` প্রতি ম্যাট্রিক্স-সারি |
| Sync/Offline | fake `FirestoreGateway`, connectivity stub | pending, debounce, reconnect flush, restore |

**CI গেট:** `flutter analyze` (০ warning), সব test পাস, domain কভারেজ ≥ ৯০%, rules টেস্ট পাস।

### 40.2 বিদ্যমান JS টেস্ট → Dart পোর্ট (বাধ্যতামূলক পুনরুৎপাদন)
| JS test ফাইল | Dart টেস্ট | মূল কেস |
|---|---|---|
| `tests/core.test.js` | `test/family_bazar/core_test.dart` | permissionPreset (owner/admin/member/viewer, admin.purchaseDetails=false); normalizePermissions; `canEditMember`/`assignableRoles`; `validatePurchaseDraft` (সব বার্তা, ৪০-সীমা, ভবিষ্যৎ তারিখ, unitPrice↔total ডেরিভেশন); FNV `productIdFor` (গোল্ডেন মান সোর্স থেকে এক্সট্র্যাক্ট); `statDeltas`/`planPurchaseChange` (edit/delete/মাস-বদল); `budgetStatus` লেভেল (ok/w80/w90/over, 80/90/100 সীমানা); `periodTotals` (সপ্তাহ শনিবার শুরু); `estimateNext7` (not-enough-data, round50, মান-পরিসীমা); `analyzePrices`, `priceMovers(3%)`, `locationComparison`; `categoryRows` |
| `tests/expense-sync.test.js` | `test/ledger/family_sync_test.dart` | create→১ লেনদেন; একই purchaseId দ্বিতীয়বার→আপডেট (নতুন নয়); edit→amount/date/note বদল; delete→মুছে; `family_bazar` ক্যাটাগরি স্বয়ংক্রিয় ও ডুপ্লিকেটহীন; `otherExpenseByMonth` Family-লিঙ্কড বাদ; অন্য uid-এর লেজারে লেখা নয় |
| `tests/family-planning.test.js` | `test/family_planning/plan_test.dart` | validatePlanDraft/Contribution/Expense সব বার্তা; `contributionCredit` (pending/rejected=0; partial=received; approved=received??claimed); **১০,০০০ দাবি / ৮,০০০ যাচাই ⇒ সংগৃহীত ৮,০০০**; `approvedTotal/pendingTotal/spentTotal/remainingTarget/remainingAfterSpend/progressPct(100 cap)`; `isTargetAchieved` ও `refreshAchievedStatus` (active↔target_achieved); transitions (approve/reject/request/resubmit/complete) + audit; audit ২০০-সীমা ঘূর্ণন; `plansInStatusTab`, `searchPlans`, `sortPlansNewest`; `isParticipant` (all/selected); `dashboardTotals`; role helper (viewer সব false) |
| `tests/khasra-khata.test.js` | `test/khasra/khasra_test.dart` | parseNum (বাংলা অঙ্ক, কমা, ≤0→0); lineGross/discount (টাকা, %, >১০০% clamp, gross-এর বেশি clamp); lineTotal; totals; `enterNav` ম্যাট্রিক্স (desc শেষ সারি→add/none; qty/rate/discount→কখনো add নয়); `buildDraft` (ফাঁকা সারি বাদ, স্ট্রিং রক্ষা, id/createdAt edit-এ স্থির); `validateDraft` বার্তা; `searchDrafts` (নাম, ISO, বাংলা তারিখ, বাংলা অঙ্ক কোয়েরি); `storageKey` identity-বিচ্ছিন্ন; fmtNum গ্রুপিং |
| `tests/hijri-ummalqura.test.js` | `test/calendar/hijri_test.dart` | টেবিল সীমা (১৩৫৬/১৫০০) ও `null` বাইরে; round-trip Gregorian↔Hijri সমগ্র পরিসরে নমুনা; `১ মুহাররম ১৪৪৮ = ২০২৬-০৬-১৬`; মাসের দৈর্ঘ্য ২৯/৩০; `hijriToGregorianYmd` অবৈধ দিন→null; **ঢাকা সূর্যাস্ত:** ডিভাইস TZ নির্বিশেষে একই ফল (TZ-ম্যাট্রিক্স), সূর্যাস্তের আগে/পরে হিজরি দিন, বছর-সীমা overflow; ইংরেজি/বাংলা মধ্যরাতে |
| `tests/special-day-hijri.test.js` | `test/calendar/special_day_test.dart` | `resolveSpecialDayDate`, `resolveSpecialDayInMonth` (recurring ও fixed), `nextHijriOccurrence` (নিজ দিন অন্তর্ভুক্ত, বছর অতিক্রম), `hijriOccurrenceInGregorianMonth`, recurring-এ `date=null` সংরক্ষণ |
| `tests/special-day-bulk-import.test.js` | `test/admin/bulk_import_test.dart` | ১০ সারি শুরু; Enter নিয়ম; ইংরেজি/হিজরি মোড; লাইন-নম্বর সহ "তারিখ দেওয়া হয়নি" ত্রুটি; ডুপ্লিকেট-কী (fixed বনাম recurring); "N যোগ, M আগে থেকেই ছিল" বার্তা |
| `tests/task-amount.test.js` | `test/tasks/task_test.dart` | `addTask` কখনো `amount` রাখে না; `MAX_TASKS=10`; `computeTaskReminderFields` (সব preset, custom, none, তারিখ-ছাড়া null) |
| `tests/tax-reminder.test.js` | `test/tax/tax_reminder_test.dart` | unpaid + সঠিক মিনিট ⇒ fire একবার (`remindedAt`); **paid ⇒ কখনো নয়**; reminder-ছাড়া নয়; `taxDueInfo` overdue/today/soon/ok; paid টগলের পর reminder স্থগিত |

### 40.3 অতিরিক্ত বাধ্যতামূলক টেস্ট
- **Ledger/Balance:** `Σincome−Σexpense`; wallet-ব্যালেন্স সূত্র (opening+tx±transfer±repayment); overdraft-গার্ড edit-এ নিজের পুরনো প্রভাব বাদ; `method==null→cash` প্রদর্শন vs গার্ড-অন্তর্ভুক্তি-নয় `[N7]`।
- **Debt:** `remaining/status/dueInfo`; repayment ceiling; payable overdraft; receivable কখনো ব্লক নয়; undo।
- **Budget & Dashboard:** health-score, insights, safeSpendToday, থ্রেশহোল্ড সীমানা।
- **Reports/Search:** ১১ মাস-তালিকা; ফিল্টার কম্বিনেশন; repayment-বিভাগ বিচ্ছিন্ন।
- **Permission:** ম্যাট্রিক্স §33 — প্রতি (role × action) UI-গেট টেস্ট + **Rules emulator টেস্ট** (viewer লিখতে পারে না; admin অন্য admin বদলাতে পারে না; member অন্যের purchase লিখতে পারে না; অ-সদস্য কিছু পড়তে পারে না; অ-verified ইমেইল আমন্ত্রণ গ্রহণ করতে পারে না; plan contribution append-only; member verify করতে পারে না)।
- **Offline/Sync:** অফলাইন লেখা→`pending++`→অনলাইনে flush→`synced`; push-ব্যর্থ→`error`→retry; login-এ cloud-overwrites-local; no-cloud→push-local; restore preview+confirm; identity-switch-এ আগের ডেটা না-দেখা।
- **Family Bazar sync:** batch atomicity (একটি ব্যর্থ→কিছুই নয়); location best-effort ব্যর্থতায় purchase সফল।
- **Reminder:** ২০s ticker simulate (fake clock) — Task/Tax/Debt once-per-day।
- **Navigation:** back-stack (§10.2–10.3) widget টেস্ট (প্রতি sheet-গভীরতায় এক ধাপ)।
- **Golden:** Dashboard, Timeline, Reports, Khasra print, Family Home — আলো/ডার্ক।

---

## 41. Backup & Restore

| ক্ষমতা | আচরণ |
|---|---|
| **Cloud backup** | সাইন-ইন + autoSync → ব্যক্তিগত ডেটা `users/{uid}`-এ স্বয়ংক্রিয় (§31.1); manual "এখনই সিঙ্ক" |
| **Cloud restore** | Settings → "ক্লাউড থেকে ফিরিয়ে আনুন": তুলনা-প্রিভিউ (লোকাল বনাম ক্লাউড সংখ্যা) → অপেক্ষমাণ পরিবর্তন সতর্কতা → কনফার্ম → লোকাল প্রতিস্থাপন |
| **JSON Export** | সম্পূর্ণ ব্যক্তিগত ডেটা ফাইল (শেয়ার/সেভ); **Khasra অন্তর্ভুক্ত নয়** |
| **CSV Export** | লেনদেন (§28.4) |
| **CSV Import** | লেনদেন-যোগ (§28.4); কিছু মোছে না |
| **JSON Import** | ❌ বর্তমানে নেই — যোগ করা যাবে না |
| **Family ডেটা** | Firestore-ই উৎস (আলাদা ব্যাকআপ নেই) |
| **Clear all** | §28.4 |
- Flutter ফাইল-সেভ/শেয়ার: `path_provider` + `share_plus`; Android scoped storage।

## 42. Data Migration

1. **Web/JS → Flutter ব্যবহারকারী:** একই Firebase প্রজেক্ট, একই `users/{uid}` স্কিমা ⇒ লগইনে ক্লাউড-ডেটা স্বয়ংক্রিয় ডাউনলোড (§28.3); লোকাল ইনস্টল-ডেটা Flutter-এ স্থানান্তর **নেই** (WebView storage আলাদা) — **guest ব্যবহারকারীর ডেটা হারানো এড়াতে** পুরনো APK থেকে "JSON এক্সপোর্ট" করে রাখা বাধ্যতামূলক নির্দেশনা; Flutter-এ JSON ইমপোর্ট নেই বলে guest মাইগ্রেশন `[OPEN D3]` (সম্ভাব্য সমাধান: signed-in ব্যবহারকারীরা ক্লাউড থেকে সম্পূর্ণ ফিরে পায়; guest-দের আগে সাইন-ইন করে সিঙ্ক করার নির্দেশ)।
2. **স্কিমা-সামঞ্জস্য:** অজানা/অনুপস্থিত ফিল্টারে নিরাপদ ডিফল্ট (`applyUserData` যেমন): `expenseCats/incomeCats` ডিফল্ট, `specialDays` legacy স্ট্রিং→অ্যারে (`normalizeSpecialDays`), `tasks[].amount` উপেক্ষা, `method` null→`cash`।
3. **Khasra:** `hisabkhata-khasra-v1:*` ওয়েব-স্টোরেজ মাইগ্রেট হয় না (N8)।
4. **Local DB স্কিমা ভার্সনিং:** Isar স্কিমা-ভার্সন + migration কলব্যাক; ক্লাউড ডকে `schemaVersion` যোগ **নয়** (বিদ্যমান ডকে নেই) — সামঞ্জস্য রাখতে আনুষ্ঠানিক ফিল্ড-যোগ ছাড়া।

---

## 43. Flutter Architecture

**সিদ্ধান্ত: Feature-first + Clean-layered (presentation / domain / data) + Repository pattern**, কারণ: (ক) মডিউল ১৫+ ও স্বাধীন; (খ) Family Bazar/Planning/Hijri/Khasra pure-logic ইতিমধ্যে UI-মুক্ত (`*-core.js`) — সরাসরি `domain/`-এ পোর্টযোগ্য; (গ) টেস্টযোগ্যতা; (ঘ) বিশাল ফাইল (বর্তমান `app/02-main-app.js` ~৯৪KB, `family-bazar.js` ~১৯০০ লাইন) এড়ানো।
**স্তর-নির্ভরতা:** `presentation → application(notifiers) → domain ← data`; domain কেবল Dart (Flutter/Firebase-মুক্ত)।
**নিয়ম:** একটি Dart ফাইল সাধারণত ≤ ২০০–৩০০ লাইন (কঠোর সীমা ৪০০); স্ক্রিন → sub-widget ভাঙা; ফর্ম-লজিক controller/notifier-এ।

## 44. Folder Structure

```
lib/
├─ main.dart, app.dart (MaterialApp.router, theme, locale)
├─ core/
│  ├─ config/ (app_config.dart: primaryAdminUid/email, firebase_options)
│  ├─ theme/ (tokens.dart, light.dart, dark.dart, typography.dart)
│  ├─ format/ (bn_format.dart: digits, grouping, ৳, dates)
│  ├─ calendar/ (hijri_ummalqura.dart, uq_table.dart, dhaka_sunset.dart, bangla_date.dart, special_day_resolver.dart)
│  ├─ money/ (round2.dart, parse_num.dart)
│  ├─ errors/ (app_exception.dart, friendly_error.dart)
│  ├─ routing/ (app_router.dart, back_stack.dart)
│  └─ utils/ (ids.dart: uid/FNV hash36, debounce.dart, clock.dart)
├─ shared/ (widgets: money_text, empty_state, confirm_dialog, undo_banner, sheet_scaffold, charts/…)
├─ data/
│  ├─ local/ (isar_db.dart, collections/*.dart, daos/*.dart, prefs_store.dart, secure_store.dart)
│  ├─ remote/ (firebase_auth_gateway.dart, firestore_gateway.dart, user_doc_remote.dart, admin_content_remote.dart,
│  │            family_remote.dart, plan_remote.dart, invitation_remote.dart)
│  ├─ sync/ (cloud_sync_engine.dart, pending_tracker.dart, connectivity_watcher.dart)
│  └─ mappers/ (json ↔ domain)
├─ features/
│  ├─ auth/ {domain,data,application,presentation}
│  ├─ shell/ (header, bottom_nav, hamburger, panel_origin)
│  ├─ dashboard/ (health_score.dart, insights.dart, stats.dart, widgets/)
│  ├─ ledger/ (transactions, categories, accounts, transfers, balance_engine.dart, tx_form/)
│  ├─ timeline/  ├─ budget/  ├─ debts/  ├─ reports/  ├─ search/
│  ├─ calendar/ (month_grid, day_details, special_days/)
│  ├─ tasks/ (reminder_presets.dart, task_form/, quick_add/)   ├─ tax/
│  ├─ reminders/ (reminder_engine.dart, local_notifications.dart, banner)
│  ├─ notifications/ (center, read_state)
│  ├─ admin/ (notices, daily, special_days+bulk_import, admin_tasks, faq)
│  ├─ khasra/ (domain/khasra_calc.dart, enter_nav.dart, storage, pdf_builder.dart, print, presentation/)
│  ├─ family_bazar/ {domain(permissions, purchase_validator, stats_deltas, price_analysis, budget_status), data, application, presentation/{home,bazar,reports,family,more,sheets/,search}}
│  ├─ family_planning/ {domain(plan_rules, plan_totals, transitions, validators), data(plan_repo), application, presentation/{home,list,detail,create,approval,verify,contribute,expenses,history,complete}}
│  ├─ family_members/ (members, invitations, profile)
│  ├─ products/ (product_sheet, price_history, location_compare)
│  ├─ family_legacy/ (personal members + bazar items)
│  └─ settings/ (account, appearance, money, backup_csv_json, pin_lock, audit_log, about)
└─ l10n/ (app_bn.arb, app_en.arb)
test/ (mirror of lib/), integration_test/, firebase/ (firestore.rules, rules tests)
```

## 45. State Management Recommendation

**Riverpod (`flutter_riverpod` + `riverpod_annotation`)**। কারণ: compile-safe DI, `family`/`select` দিয়ে সংকীর্ণ rebuild, `StreamProvider` দিয়ে Firestore listener-এর সহজ জীবনচক্র (autoDispose = পরিবার-মডিউল বন্ধ হলে unsubscribe), টেস্টে override।
- **ব্যক্তিগত ডেটা:** `PersonalDataNotifier` (AsyncNotifier) — Isar DAO থেকে লোড; প্রতি মিউটেশন → DAO লেখা → `pendingChanges++` → `SyncEngine` সিগন্যাল।
- **ডিরাইভড:** `dashboardStatsProvider`, `balancesProvider`, `reportsProvider(range)` — memoized pure ফাংশন।
- **Identity:** `identityProvider` (guest|uid) বদলালে সব ব্যক্তিগত provider invalidate (আগে খালি, পরে লোড — §28.1)।
- **Family:** `activeFamilyIdProvider`, `familyStreamProvider`, `membersStreamProvider`, `plansStreamProvider`, `invitationsStreamProvider`; on-demand `FutureProvider.family` (purchases(month), aggregates, products)।
- **Navigation/back-stack:** `SheetStackNotifier` (Family Bazar) + `PanelOriginNotifier`।
- ট্রান্সিয়েন্ট ফর্ম-স্টেট: ফর্ম-লেভেল `StateNotifier`/`useState`-সমতুল্য; `flutter_hooks` ঐচ্ছিক।

## 46. Repository Pattern

```
abstract interface class TransactionRepository { Stream<List<Transaction>> watchAll(); Future<void> upsert(Transaction); Future<Transaction?> remove(String id) /*for undo*/; ... }
Impl: IsarTransactionRepository (Local-first). SyncEngine আলাদা: PersonalSnapshotAssembler (লোকাল সব → users/{uid} JSON) ও PersonalSnapshotApplier (ক্লাউড JSON → লোকাল)।
FamilyRepository / PurchaseRepository / PlanRepository / InvitationRepository / AdminContentRepository / AuthRepository / KhasraRepository(local only) / PrefsRepository
```
- Domain শুধু interface দেখে; Firebase/Isar শুধু `data/`-এ।
- Purchase লেখা `PurchaseRepository.save(old,new)` ভেতরে `planPurchaseChange` → একটি `WriteBatch`।
- Plan মিউটেশন `PlanRepository.mutate(familyId, planId, (plan)=>plan')` ভেতরে `runTransaction` (§24.11)।
- একটি `Clock`/`IdGenerator` ইনজেক্ট (টেস্টে নির্ধারক)।

## 47. Local Database Strategy

- **Isar** collections: `TransactionC, DebtC(+embedded repayments), TransferC, TaskC, TaxC, UserAccountC, CategoryC, SpecialDayC, AuditLogC, LegacyMemberC, BazarItemC, KhasraDocC, KeyValueC(profileName, budget, categoryBudgets, accountOpening, read/dismiss/completed ids)`। প্রতিটি `identity` ফিল্ডে পার্টিশন (guest|uid) + ইনডেক্স।
- **Snapshot ↔ Collections:** push-এ সব collection একটি JSON-এ সংকলন (বিদ্যমান `users/{uid}` আকৃতি); pull/restore-এ প্রতিস্থাপন (transaction-এ atomic)।
- **ব্যাকআপ প্ল্যান B:** Isar-এর প্যাকেজ-সমস্যায় `hive_ce` — একই repository interface তাই বদলযোগ্য।
- **`SharedPreferences`:** theme, autoSync, activeFamilyId, FB-prefs (বাজার/এলাকা সাজেশন), onboarding-ফ্ল্যাগ। **কখনো আর্থিক ডেটা নয়।**
- **Secure:** PIN hash/salt।
- **Isar-বহির্ভূত:** Firestore-ক্যাশ SDK-নিয়ন্ত্রিত।
- **ট্রানজ্যাকশন:** মাল্টি-collection মিউটেশন (যেমন ক্যাটাগরি migrate) একটি Isar write-txn।

## 48. Firestore Structure

```
users/{uid}                              — ব্যক্তিগত পূর্ণ ডেটা (একক ডক; updatedAt)
notices/{id}            { title, content, published, createdAt, updatedAt }
dailyMessages/{id}      { title, content, createdAt, updatedAt }
adminSpecialDays/{id}   { title, description, dateType, date, hijri, recurrence, hijriMonth, hijriDay, createdAt }
adminTasks/{id}         { title, description, category, dueDate, time, repeat, reminderDate, reminderTime, published, createdAt }
faq/{id}                { question, answer, createdAt }
families/{fid}          { name, ownerId, memberUids[], photoURL, settings, lastRemovedUid, createdAt, updatedAt }
  members/{uid}         { uid, name, phone, relation, role, status, permissions{7}, inviteId, photoURL, joinedAt, updatedAt }
  categories/{id}       { name, icon, group, createdAt, updatedAt }
  products/{pid}        { name, categoryId, category, unit, aliases[], archived, createdAt, updatedAt }
  budgets/current       { monthlyAmount, updatedAt, updatedBy }
  purchases/{purchaseId}{ memberId, memberName, date, month, market, location, note, trackPrice, items[], total, createdAt, updatedAt }
  priceHistory/{purchaseId_itemId}  { productId, productName, memberId, price, unit, date, month, purchaseId }
  locations/{pid_locKey_unitHash}   { productId, productName, location, market, price, unit, date, memberId, purchaseId, itemId }
  memberMonthly/{uid_YYYY-MM}         { memberId, month, total, count, days{date:amount} }
  memberCategoryMonthly/{uid_YYYY-MM} { memberId, month, categories{catId:{name,total}} }
  memberOtherMonthly/{uid_YYYY-MM}    { memberId, month, total }
  plans/{planId}        { …plan fields…, contributions[], expenses[], auditLog[] }
invitations/{id}        { familyId, familyName, invitedEmail, invitedBy, relation, role, permissions, phone, status, createdAt, expiresAt, respondedAt }
```
- **ইনডেক্স:** `families` `memberUids array-contains`; `invitations` `(invitedEmail)`, `(invitedBy, familyId)`; `purchases` `(month, memberId)` সাজানো client-side (বিদ্যমান আচরণ) — composite index লাগলে কনসোল-লিংক অনুযায়ী যোগ।
- বিদ্যমান ডেটা-আকৃতি **অপরিবর্তিত** — Flutter ও পুরনো ক্লায়েন্ট একসাথে চলতে পারবে।

## 49. Firestore Security Rules Requirements

- বিদ্যমান `firestore.rules` **অক্ষত ফাইল হিসেবে** রাখা; সংশোধন শুধু আলাদা অনুমোদিত change-request হলে।
- **Rules-টেস্ট ম্যাট্রিক্স (emulator):** প্রতি `match` ব্লকের জন্য: অনুমোদিত + নিষিদ্ধ উদাহরণ — `users/{uid}` (অন্য uid ❌), অ্যাডমিন কালেকশন (non-admin write ❌, signed-out read ❌), `families` create (ownerId/memberUids শর্ত), update তিন ধরন (admin metadata, self-join, member-removal), member create (owner-bootstrap বনাম invite-based; email_verified; role/permissions মিল), member update/delete শাখা, invitations create/update/delete, categories/products/budgets, purchases (read own/perm, create/update/delete শর্ত), priceHistory/locations/aggregates (uid_-প্রিফিক্স), `plans` সব update-শাখা (approve, resubmit, active-edit, contribution-append, verify, expense-append, status-change) ও delete।
- `affectedKeys().hasOnly(...)` তালিকাসমূহ Flutter ক্লায়েন্টের write-payload-এর সাথে **অক্ষরে অক্ষরে মেলাতে** হবে (অতিরিক্ত ফিল্ড লিখলে deny) — যেমন plan contribution-append-এ শুধু `contributions` ও `auditLog` বদলাতে পারে।
- Plan-এ `status` বদলের একই-document-এ `lastModified*` ইত্যাদি অনুমোদিত তালিকার বাইরে লেখা নিষিদ্ধ।

## 50. Edge Cases

| # | কেস | প্রত্যাশিত |
|---|---|---|
| E1 | ১০টি টাস্ক পূর্ণ, নতুন যোগ | নীরবে no-op; "যোগ" বোতাম লুকানো |
| E2 | `receivedAmount > claimedAmount` | status `approved`, credit = received |
| E3 | partial verify করে লক্ষ্য কমে যায় | `target_achieved → active` |
| E4 | দুই admin একসাথে verify | transaction retry; দুটিই রেকর্ডে |
| E5 | পরিবার থেকে সদস্য সরানো | পুরনো purchase/aggregate অক্ষত; চলতি পরিবার-মোটে বাদ |
| E6 | সদস্য সরানোর পর সে আবার আমন্ত্রিত | নতুন member ডক; আগের ইতিহাস `memberId` দিয়ে মেলে |
| E7 | আমন্ত্রণের মেয়াদ ৭ দিন পার | ইনকামিং তালিকা থেকে বাদ; rules-এ expiresAt যাচাই |
| E8 | Family purchase edit-এ মাস বদলে যায় | পুরনো মাসের aggregate −, নতুন মাসে + (statDeltas) |
| E9 | Purchase delete, লিঙ্কড লেনদেন ব্যবহারকারী আগেই মুছে দিয়েছে | no-op (existing==null) |
| E10 | ব্যক্তিগত লিঙ্কড লেনদেন হাতে সম্পাদনা | পরের sync পুনরায় ওভাররাইট `[N]` |
| E11 | অফলাইনে Family purchase | SDK queue; লিঙ্কড লেনদেন লোকালে তাৎক্ষণিক; পরে সংযোগে batch commit; ব্যর্থ হলে দুই পাশে অসঙ্গতি সম্ভব (বিদ্যমান) |
| E12 | Hijri সীমার বাইরের তারিখ | "—"; recurring resolve null → দিবস দেখায় না |
| E13 | সূর্যাস্ত গণনা `cosH` সীমা-বাহির (অসম্ভব ঢাকায়) | null → সাধারণ তারিখে fallback |
| E14 | ৩১ ডিসেম্বর সূর্যাস্ত-পরে | হিজরি = ১ জানুয়ারির, বছর overflow |
| E15 | ক্যাটাগরি মুছে migrate | সব লেনদেন নতুন key; budget/categoryBudgets-এ পুরনো key পরিষ্কার `[VERIFY]` |
| E16 | ডায়নামিক অ্যাকাউন্ট ব্যবহৃত, মোছা | ব্লক; Deactivate অপশন |
| E17 | একই নামের পণ্য ভিন্ন কেস/স্পেস | `nameKey`-এ এক পণ্য |
| E18 | Khasra: বাংলা অঙ্ক, কমা, `10%` ছাড় | সঠিক গণনা; ছাড়>মোট হলে clamp |
| E19 | Khasra: শেষ সারির desc খালি, Enter | কিছু হয় না |
| E20 | Login-এ ক্লাউডে ডক নেই, লোকালে আছে | লোকাল push |
| E21 | দুই ডিভাইসে অফলাইন সম্পাদনা | last-write-wins (ডকুমেন্টেড সীমা) |
| E22 | Guest → Google সাইন-ইন | guest ডেটা `guest` কী-তেই; uid-ডেটা আলাদা; নতুন uid ক্লাউডে ডক না থাকলে **uid-লোকাল** (গেস্ট নয়) পুশ হয় — guest→uid স্বয়ংক্রিয় মার্জ **নেই** `[VERIFY]` |
| E23 | অ্যাডমিন FAQ seed দুইবার | `/faq` খালি থাকলেই seed (ইডেমপোটেন্ট) |
| E24 | Plan viewer-এ UI বোতাম | লুকানো; rules deny |
| E25 | Android back Family sheet-stack | এক ধাপ পেছন |

## 51. Acceptance Criteria (সামগ্রিক)

1. §8-এর সব ফিচার (F01–F29) Flutter-এ বিদ্যমান আচরণে কার্যকর; কোনো ফিচার অনুপস্থিত নেই।
2. §40.2-এর সব পোর্টেড টেস্ট পাস; §49 rules-টেস্ট পাস।
3. WebView/`webview_flutter`/`flutter_inappwebview` নির্ভরতা **শূন্য**।
4. অফলাইনে (বিমান-মোড) সমস্ত ব্যক্তিগত মডিউল পূর্ণ কার্যকর; পুনঃসংযোগে স্বয়ংক্রিয় sync।
5. ১,০০,০০০ লেনদেন সিড করলে Dashboard খুলতে ≤ ১s, সার্চ ≤ ৫০০ms।
6. বিদ্যমান `users/{uid}` ডেটা লোড করে সব স্ক্রিনে সঠিক দেখায় (ফরওয়ার্ড/ব্যাকওয়ার্ড কম্প্যাটিবল)।
7. Family Planning ১০,০০০/৮,০০০ উদাহরণ UI-তেও সংগৃহীত **৮,০০০** দেখায়।
8. Hijri: ঢাকা সূর্যাস্তের আগে/পরে "আজকের" হিজরি তারিখ ভিন্ন; ইংরেজি/বাংলা অপরিবর্তিত; ডিভাইস TZ বদলে ফল বদলায় না।
9. Back: Family Bazar-এ ≥৩ স্তর sheet এক ধাপে ফেরে; Dashboard-এ লাফ নয়।
10. কোনো Dart ফাইল ৪০০ লাইনের বেশি নয় (জেনারেটেড বাদে)।

## 52. Feature-by-Feature Definition of Done

প্রতি ফিচার "Done" যখন: (১) §ফিচার-অংশের Functional/Business/Data/Permission/Offline/Sync/Error/Acceptance সব বাস্তবায়িত; (২) domain unit-টেস্ট ≥৯০% ও পোর্টেড JS-কেস পাস; (৩) widget টেস্ট (validation বার্তা, empty/error/loading, role-গেট); (৪) বাংলা অঙ্ক/ফরম্যাট যাচাই; (৫) TalkBack লেবেল; (৬) back-stack টেস্ট; (৭) অফলাইন টেস্ট; (৮) rules-সংশ্লিষ্ট হলে emulator টেস্ট; (৯) ফাইল-সাইজ নিয়ম; (১০) PR-এ বিদ্যমান-আচরণ-মিল চেকলিস্ট (§55) টিক।

## 53. Future Compatibility

- **iOS:** সব প্যাকেজ iOS-সমর্থিত বাছাই (`flutter_local_notifications` iOS permission/`UNUserNotificationCenter`, `google_sign_in` iOS, Isar iOS); Cupertino-সামঞ্জস্য — `adaptive` widget; iOS back-swipe = Navigator pop (একই stack)।
- **Tablet/Desktop:** লেআউট max-width; পরে।
- **ভবিষ্যৎ ফিচার ফ্ল্যাগ-মুক্ত** — নতুন ফিচার এই PRD-র আওতার বাইরে।
- ক্লাউড-স্কিমা ফরওয়ার্ড-কম্প্যাট: অজানা ফিল্ড উপেক্ষা ও সংরক্ষণ (round-trip-এ হারানো নয়) — `fromJson`-এ `extras` মানচিত্র রাখা যায়।

## 54. Migration Strategy: Web/JS → Flutter/Dart

**ধাপ (পরামর্শ):**
1. **Core পোর্ট (UI-মুক্ত, test-first):** `bn_format`, `parseNum/round2`, Hijri+UQ_TABLE, Bangla date, balance engine, debt/tax helpers, reminder presets, Khasra calc, FBCore, FPCore → Dart + পোর্টেড টেস্ট সবুজ।
2. **Data স্তর:** Isar স্কিমা, `users/{uid}` assembler/applier, SyncEngine, Auth gateway।
3. **Shell + Ledger:** Header/BottomNav/Dashboard/লেনদেন/Timeline/ক্যাটাগরি/অ্যাকাউন্ট/ট্রান্সফার/বাজেট।
4. **Debt, Reports, Search, Settings(+PIN, CSV, audit)।**
5. **Calendar + Special days + Admin + Notifications/Reminders + Tasks + Tax।**
6. **Khasra (editor, history, print, PDF)।**
7. **Family Bazar (members→purchases→aggregates→reports→products/prices→search→budget→ledger-sync)।**
8. **Family Planning (rules-test সহ)।**
9. **Hardening:** performance, a11y, goldens, rules emulator, বিদ্যমান-ডেটা কম্প্যাট টেস্ট।
**প্রতি ধাপে** "বিদ্যমান আচরণ মিলিয়ে দেখো" — সোর্স JS ফাইল পাশে খুলে।
**ঝুঁকি:** FNV ID পার্থক্য (ডুপ্লিকেট পণ্য), UQ_TABLE কপি-ভুল, Bangla PDF শেপিং, background reminder নির্ভরযোগ্যতা (Android Doze/exact alarm), Firestore offline + plan transaction।
**Open Decisions:** `D1` repeat স্বয়ংক্রিয় পুনঃনির্ধারণ চালু হবে কি; `D2` Khasra ক্লাউড/ব্যাকআপে যাবে কি; `D3` guest-ডেটা পুরনো APK→Flutter পথ; `D4` Plan-এ paused/cancelled UI; `D5` লিঙ্কড লেনদেন `method` সেট হবে কি (N7)। **মালিকের উত্তর না পেলে বর্তমান আচরণই চূড়ান্ত।**

---

## 55. Final Complete Feature Checklist

প্রতি ফিচারের জন্য নয়টি টিক (বর্তমান PRD-র নির্দিষ্ট অনুচ্ছেদ-সূত্র সহ): `[x]` = এই PRD-তে নথিভুক্ত।

| ফিচার | Feature | Data model | Permission | Offline | Firebase | UI flow | Business rules | Testing | Acceptance |
|---|---|---|---|---|---|---|---|---|---|
| F01 Dashboard (§11) | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] |
| F02 Income/Expense Ledger (§12) | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] |
| F03 Categories (§12.5) | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] |
| F04 Balance (§12.6) | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] |
| F05 Transfers (§12.7) | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] |
| F06 Dynamic Accounts (§12.8) | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] |
| F07 Budget (§13) | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] |
| F08 Timeline (§11.8) | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] |
| F09 Debt/Due (§14) | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] |
| F10 Reports (§15) | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] |
| F11 Search (§16) | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] |
| F12 Calendar (§17) | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] |
| F13 Hijri Umm al-Qura (§18) | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] |
| F14 Special Days + Bulk (§19) | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] |
| F15 Tasks (§20) | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] |
| F16 Tax (§21) | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] |
| F17 Khasra Khata (§22) | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] |
| F18 Family Bazar (§23) | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] |
| F19 Family Planning (§24) | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] |
| F20 Members/Roles/Invitations (§25) | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] |
| F21 Product & Price (§26) | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] |
| F22 Notifications/Reminders (§27, §20.5) | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] |
| F23 Auth + PIN (§28) | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] |
| F24 Settings (§28.4) | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] |
| F25 Cloud Backup/Sync (§30–31, §41) | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] |
| F26 Admin Panel (§19.4) | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] |
| F27 Family Spending (§23.9) | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] |
| F28 Personal↔Bazar Sync (§23.8) | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] |
| F29 Legacy Family List (§25.6) | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] | [x] |

**ফিচার-অংশের কাঠামো সম্পর্কে নোট:** প্রতিটি ফিচার-অনুচ্ছেদে Functional Requirements, Business Rules, Data, Permission, Offline, Sync, Error Cases ও Acceptance যেখানে আলাদা শিরোনামে আছে সেখানে সরাসরি; ছোট ফিচারে "Spec" সারিতে সংক্ষেপে একত্রিত। সম্পূর্ণ ম্যাট্রিক্স §33, মডেল §32, Firebase §30/§48/§49, টেস্ট §40।

### সর্বশেষ নিরীক্ষা (Self-audit)
- **যোগ করা হয়নি:** নতুন feed, JSON import, বায়োমেট্রিক, task-amount, Plan Settings, ইংরেজি-UI সুইচ, ক্লাউড-Khasra, repeat-পুনঃনির্ধারণ।
- **বাদ দেওয়া হয়নি:** সব `[N1–N14]` অসঙ্গতি আচরণ হিসেবে সংরক্ষিত বা `[OPEN]` চিহ্নিত।
- **`[VERIFY]` চিহ্নিত আইটেম:** বাস্তবায়নের আগে সংশ্লিষ্ট JS লাইন একবার মিলিয়ে নিন (E15, E22 ইত্যাদি)।
