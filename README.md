# 🎮 Ultimate Guess Game (2-Player Real-Time Multiplayer)

A cross-platform (Web, Android, iOS, Desktop) 2-player guessing game built with **Flutter**, **Riverpod**, and **Supabase Realtime**.

Inspired by the classic *"Heads Up!"* / *"Who Am I?"* party game mechanic: each player picks a secret photo for their opponent, and players ask yes/no questions to guess what photo is on their "head".

---

## 📖 Complete Documentation & AI Guide

For full architecture details, data flows, Supabase schema, and guidelines for AI agents, see:
👉 **[PROJECT_REFERENCE.md](file:///f:/StudioProjects/ropulva/GUESS%20GAME/PROJECT_REFERENCE.md)**

---

## 🚀 Key Features

- **⚡ Instant 6-Digit Room Codes:** Create a room in seconds and share the code.
- **🔄 Real-Time State Sync:** Powered by Supabase Realtime Channels — zero polling.
- **📸 Cross-Platform Photo Uploads:** Select gallery or camera photos across Web, iOS, Android, and Desktop.
- **🎭 Mystery Headband Mechanic:** Your opponent's card is visible to you; your own card is hidden behind an animated mystery gradient.
- **👁️ Host Photo Reveal:** Host can trigger a synchronized round reveal showing both photos at once.
- **🏆 Live Scoreboard & Winner Dialog:** Host awards points and ends the match with a celebratory victory popup.
- **📱 Fully Responsive Design:** Dynamic mobile column layout and wide desktop dual-arena layout.

---

## 🗄️ Backend Setup (Supabase)

1. Create a Supabase project at [supabase.com](https://supabase.com).
2. Run the SQL script found in [`supabase_schema.sql`](file:///f:/StudioProjects/ropulva/GUESS%20GAME/supabase_schema.sql) in the **Supabase SQL Editor**.
3. Add your Supabase credentials to [`lib/core/constants/supabase_constants.dart`](file:///f:/StudioProjects/ropulva/GUESS%20GAME/lib/core/constants/supabase_constants.dart).

---

## 🛠️ How to Run

```bash
# 1. Install dependencies
flutter pub get

# 2. Run analysis
flutter analyze

# 3. Run on Web
flutter run -d chrome

# 4. Run on Android / iOS
flutter run
```
