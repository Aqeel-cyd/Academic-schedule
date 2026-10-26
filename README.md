# 📅 Schedule Tracker

A cross-platform app (Android + Web) that helps students keep track of **quizzes, laboratory sessions, lab report submission deadlines and assignments**, personalised for each student's lab group. Admins create and manage the schedule; students can only view it.

🔗 **Live demo:** https://schedule-tr.web.app

---

## ✨ Features

- 🔐 **Google Sign-In** with Firebase Authentication
- 🪪 **Student profile**: student ID and lab group saved on first login
- 🎯 **Personalised schedule**: each student sees only the events for their lab group (or events for everyone)
- 🗂 **Four event types**: Quiz, Lab, Lab report submission, Assignment, each colour-coded with filter chips
- ⏳ **Countdown** on every upcoming event
- 🛡 **Admin panel**: add, edit and delete events (admins only)
- 🔒 **Secure by design**: write access is enforced with Firestore Security Rules, not just hidden buttons
- 🔔 **Local reminders** on Android (1 day and 1 hour before each event)
- 🎨 **Animated UI**: gradient background, floating shapes, glass-style login card, staggered card animations

## 🛠 Tech stack

| Area | Technology |
|---|---|
| Framework | Flutter (Dart) |
| Auth | Firebase Authentication (Google) |
| Database | Cloud Firestore |
| Hosting | Firebase Hosting |
| Notifications | flutter_local_notifications |
| Animations | flutter_animate |
| Editor | VS Code |

Everything runs on free tiers.

## 📸 Screenshots

<!-- Add your screenshots to a "screenshots" folder and update the paths below -->
| Login | Home | Admin panel |
|---|---|---|
| ![Login](screenshots/login.png) | ![Home](screenshots/home.png) | ![Admin](screenshots/admin.png) |

## 🗄 Data model

```
users/{uid}    name, email, studentId, section (lab group), role
events/{id}    type, title, section ("ALL" or a lab group), dateTime, notes, createdBy
admins/{uid}   a document here makes that user an admin
```

## 🔒 Security rules (summary)

- Signed-in users can **read** events.
- Only users listed in `admins` can **create, edit or delete** events.
- Students can read and edit only their own profile, and cannot change their role.
- Admins are added manually in the Firebase console.

## 🚀 Getting started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- A Firebase project (Spark / free plan)
- Node.js, plus `firebase-tools` and `flutterfire_cli`

### Setup

```bash
git clone https://github.com/Aqeel-cyd/Academic-schedule.git
cd Academic-schedule
flutter pub get
```

1. Create a Firebase project and enable **Authentication → Google** and **Firestore Database**.
2. Connect the app to your project:
   ```bash
   firebase login
   flutterfire configure
   ```
3. Publish Firestore security rules that match the summary above.
4. Add your Android **SHA-1** fingerprint in Firebase project settings (needed for Google Sign-In on Android).
5. Make yourself an admin: in Firestore create `admins/{your-uid}` with a field `active: true`.

### Run

```bash
flutter run -d chrome     # web
flutter run               # Android device or emulator
```

### Build

```bash
flutter build apk --release                       # Android APK
flutter build web && firebase deploy --only hosting   # Web
```

## 🗺 Roadmap

- [ ] Push notifications for new or changed events (Firebase Cloud Messaging)
- [ ] Admin announcements sent to specific lab groups
- [ ] iOS build
- [ ] Calendar view

## 👤 Author

**Mohamed Aqeel**
GitHub: [@Aqeel-cyd](https://github.com/Aqeel-cyd)

---

*Built with Flutter and Firebase.*# 📅 Schedule Tracker

A cross-platform app (Android + Web) that helps students keep track of **quizzes, laboratory sessions, lab report submission deadlines and assignments**, personalised for each student's lab group. Admins create and manage the schedule; students can only view it.

🔗 **Live demo:** https://schedule-tr.web.app

---

## ✨ Features

- 🔐 **Google Sign-In** with Firebase Authentication
- 🪪 **Student profile**: student ID and lab group saved on first login
- 🎯 **Personalised schedule**: each student sees only the events for their lab group (or events for everyone)
- 🗂 **Four event types**: Quiz, Lab, Lab report submission, Assignment, each colour-coded with filter chips
- ⏳ **Countdown** on every upcoming event
- 🛡 **Admin panel**: add, edit and delete events (admins only)
- 🔒 **Secure by design**: write access is enforced with Firestore Security Rules, not just hidden buttons
- 🔔 **Local reminders** on Android (1 day and 1 hour before each event)
- 🎨 **Animated UI**: gradient background, floating shapes, glass-style login card, staggered card animations

## 🛠 Tech stack

| Area | Technology |
|---|---|
| Framework | Flutter (Dart) |
| Auth | Firebase Authentication (Google) |
| Database | Cloud Firestore |
| Hosting | Firebase Hosting |
| Notifications | flutter_local_notifications |
| Animations | flutter_animate |
| Editor | VS Code |

Everything runs on free tiers.



## 🗄 Data model

```
users/{uid}    name, email, studentId, section (lab group), role
events/{id}    type, title, section ("ALL" or a lab group), dateTime, notes, createdBy
admins/{uid}   a document here makes that user an admin
```

## 🔒 Security rules (summary)

- Signed-in users can **read** events.
- Only users listed in `admins` can **create, edit or delete** events.
- Students can read and edit only their own profile, and cannot change their role.
- Admins are added manually in the Firebase console.

## 🚀 Getting started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- A Firebase project (Spark / free plan)
- Node.js, plus `firebase-tools` and `flutterfire_cli`

### Setup

```bash
git clone https://github.com/Aqeel-cyd/Academic-schedule.git
cd Academic-schedule
flutter pub get
```

1. Create a Firebase project and enable **Authentication → Google** and **Firestore Database**.
2. Connect the app to your project:
   ```bash
   firebase login
   flutterfire configure
   ```
3. Publish Firestore security rules that match the summary above.
4. Add your Android **SHA-1** fingerprint in Firebase project settings (needed for Google Sign-In on Android).
5. Make yourself an admin: in Firestore create `admins/{your-uid}` with a field `active: true`.

### Run

```bash
flutter run -d chrome     # web
flutter run               # Android device or emulator
```

### Build

```bash
flutter build apk --release                       # Android APK
flutter build web && firebase deploy --only hosting   # Web
```

## 🗺 Roadmap

- [ ] Push notifications for new or changed events (Firebase Cloud Messaging)
- [ ] Admin announcements sent to specific lab groups
- [ ] iOS build
- [ ] Calendar view

## 👤 Author

**Mohamed Aqeel**
GitHub: [@Aqeel-cyd](https://github.com/Aqeel-cyd)

---

*Built with Flutter and Firebase.*
