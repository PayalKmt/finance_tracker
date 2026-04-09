# 💰 Finance Companion — Flutter App

A polished personal finance companion app built with **Flutter** and **BLoC state management**, designed for everyday financial tracking.

---

## ✨ Features

### 🏠 Home Dashboard
- Animated balance card showing total balance, income & expenses
- Quick action buttons (Add Income, Add Expense, Goals, Insights)
- Active goal progress snapshot
- Recent transactions list with swipe-to-delete

### 💸 Transaction Tracking
- Add/edit/delete income & expense transactions
- 9 categories with emoji icons (Food, Transport, Shopping, Entertainment, Health, Utilities, Salary, Investment, Other)
- Real-time search with text query
- Filter chips by type (Income / Expense) and category
- Swipe to delete with dismiss animation
- Date picker for accurate logging

### 🎯 Goals & Challenges
- **Savings Goal** — Track progress towards a target amount
- **No-Spend Challenge** — Commit to a zero-spend window
- **Budget Limiter** — Cap spending in a category
- **Streak Habit** — Day-streak tracking for saving habits
- Progress bar per goal with days remaining
- Update progress inline
- Emoji picker for personalization
- Swipe to delete goals

### 📊 Insights Screen
- Income vs Expense summary cards
- Top spending category highlight
- **Weekly bar chart** (last 7 days spending) via `fl_chart`
- **Category pie chart** (spending breakdown)
- Category-by-category progress bars with percentages

### ⚙️ Settings
- **Dark Mode toggle** (persisted via SharedPreferences)
- Currency display (INR ₹)
- Biometric lock placeholder
- Export Data / Backup placeholders
- Clean grouped settings layout

---

## 🏗️ Architecture

```
lib/
├── main.dart                     # App entry point, BLoC providers
├── blocs/
│   ├── transaction/              # TransactionBloc + Event + State
│   ├── goal/                     # GoalBloc + Event + State
│   └── theme/                    # ThemeBloc + Event + State
├── models/
│   ├── transaction.dart          # Transaction model + enums
│   └── goal.dart                 # Goal model + enums
├── repositories/
│   ├── transaction_repository.dart
│   └── goal_repository.dart
├── screens/
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── app_shell.dart        # Bottom nav shell
│   ├── transactions/
│   │   ├── transactions_screen.dart
│   │   └── add_transaction_screen.dart
│   ├── goals/
│   │   └── goals_screen.dart
│   ├── insights/
│   │   └── insights_screen.dart
│   └── settings/
│       └── settings_screen.dart
├── widgets/
│   └── common/
│       └── common_widgets.dart   # BalanceCard, TransactionTile, etc.
└── utils/
    ├── app_theme.dart            # Light/dark ThemeData
    └── formatters.dart           # Currency, date formatters
```

---

## 🧠 State Management — BLoC

| BLoC | Responsibilities |
|---|---|
| `TransactionBloc` | Load, add, update, delete, filter transactions |
| `GoalBloc` | Load, add, update, delete, update progress |
| `ThemeBloc` | Toggle and persist dark/light mode |

---

## 📦 Dependencies

| Package | Purpose |
|---|---|
| `flutter_bloc` | BLoC state management |
| `equatable` | Value equality for states/events |
| `shared_preferences` | Local persistence |
| `uuid` | Unique IDs for transactions/goals |
| `fl_chart` | Bar & pie charts in Insights |
| `flutter_animate` | Smooth entrance animations |
| `google_fonts` | Plus Jakarta Sans typography |
| `intl` | Currency & date formatting |
| `gap` | Clean spacing widget |
| `collection` | Sorting helpers |

---

## 🚀 Setup & Run

### Prerequisites
- Flutter SDK `>=3.0.0`
- Dart `>=3.0.0`

### Steps

```bash
# Clone or unzip the project
cd finance_companion

# Install dependencies
flutter pub get

# Run on connected device or emulator
flutter run

# Build release APK
flutter build apk --release
```

---

## 💡 Design Decisions & Assumptions

1. **Currency**: Fixed to Indian Rupee (₹) using `en_IN` locale — easily extensible.
2. **Data Persistence**: `SharedPreferences` with JSON serialization. Chosen for simplicity without requiring SQLite setup. Seed data is loaded on first run.
3. **No-Spend Goal**: Tracks intent; actual expense-blocking is a future enhancement.
4. **Offline First**: The app works entirely offline — no network dependency.
5. **Goal Progress**: For savings goals, progress is manually updated by the user (realistic for savings tracking where money moves between accounts).
6. **Animation**: Entrance animations are kept subtle and purposeful using `flutter_animate` — not decorative.
7. **Theme**: Persisted via `SharedPreferences` so user preference survives app restarts.

---

## 📱 Screens Preview

| Home | Transactions | Goals | Insights | Settings |
|---|---|---|---|---|
| Balance, Quick Actions, Goals, Recent | Filter, Search, Swipe Delete | Active/Completed, Progress | Charts, Category Breakdown | Dark Mode, Preferences |

---

*Built as a mobile developer internship assignment — focused on product thinking, clean BLoC architecture, and polished mobile UX.*
