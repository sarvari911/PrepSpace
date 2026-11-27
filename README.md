# PrepSpace

**Your entire preparation journey, in one space.**

PrepSpace is a personalized academic and career-preparation platform designed to help students organize their learning, track progress, manage resources, and collaborate with peers.

It brings university academics and placement preparation together in one unified workspace.

## Features

- **Dashboard:** Personalized overview of learning progress and preparation activity.
- **Preparation Tracker:** Organize domains, subjects, modules, and topics with customizable progress tracking.
- **Resource Library:** Store and organize study materials, documents, links, and learning resources.
- **Study Spaces:** Create collaborative spaces, connect with peers, and share preparation materials.
- **Profiles:** Manage academic information, coding profiles, and learning identity.
- **Progress Analytics:** Monitor preparation progress, goals, and milestones.

## Technology Stack

- **Frontend:** Flutter, Dart, Material 3
- **State Management:** Riverpod
- **Local Persistence:** SharedPreferences
- **Backend:** Supabase
- **Database:** PostgreSQL
- **Version Control:** Git, GitHub

## Project Structure

The application follows a feature-first architecture with separation between presentation, domain, and data layers.

```text
lib/
├── core/
│   └── theme/
├── features/
│   ├── dashboard/
│   ├── tracker/
│   ├── spaces/
│   ├── resources/
│   ├── profile/
│   └── navigation/
└── main.dart

test/
```

## Getting Started

**Prerequisites:** Flutter SDK, Dart SDK, Android Studio or VS Code.

```bash
git clone https://github.com/sarvari911/PrepSpace.git
cd PrepSpace
flutter pub get
flutter run
```

Run the automated tests:

```bash
flutter test
```

Check code quality:

```bash
flutter analyze
```

## Development Roadmap

PrepSpace is being developed in progressive milestones:

- [x] Batch 1 — Modular application architecture, preparation tracker, local persistence, and dynamic dashboard.
- [ ] Batch 2 — Backend integration, authentication, and cloud synchronization.
- [ ] Batch 3 — Resource library.
- [ ] Batch 4 — Collaborative study spaces.
- [ ] Batch 5 — User profiles and connections.
- [ ] Batch 6 — Notifications, goals, and advanced analytics.
- [ ] Batch 7 — Final testing, optimization, and release preparation.

## Project Vision

PrepSpace aims to make student preparation structured, measurable, collaborative, and personalized — bringing academic learning and career development into one connected ecosystem.

---

**Built with Flutter. Designed for learning.**
