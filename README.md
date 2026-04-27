# MicroStep

**MicroStep** is a comprehensive self‑improvement Flutter application that helps users build better habits, manage their digital clutter, and master new knowledge through AI‑powered learning and spaced repetition.

## ✨ Key Features

### Learn – Flashcards & Folders
- Create **Regular** and **SRS‑based** learning cards
- Organize cards into **Folders** and **Sets** (Quizlet‑like hierarchy)
- Study with interactive **flashcards** (flip, mark as known/unknown)
- Spaced Repetition System (SRS) with **AI‑generated notifications**

### Check – AI‑Powered Knowledge Testing
- Generate **multiple‑choice tests** from your own cards
- **Open‑ended questions** with AI‑evaluated answers
- Powered by **Google Gemini AI** (or mock AI for offline development)

### Declutter – Clean Your Gallery
- Real **gallery access** to review and delete photos
- **Cleaning Mode** with simple gestures: Trash / Keep / Delete
- Progress tracking and session summaries

### Smart Notifications
- Local notifications for daily reminders
- SRS learning notifications with **AI‑generated contextual content**
- Per‑module notification frequency settings (Declutter, Journal, Learn, Progress)

### Spaced Repetition System (SRS)
- SM‑2 algorithm for optimal review scheduling
- AI‑generated notifications during the series duration
- Active series protection – only one SRS series at a time
### Journal 
- Daily and weekly journaling
- To-do lists
- Reminders(daily, calendar)
### Progress tracking and achievement system

## Architecture
- microstep_CC_container/
- ├── Dockerfile              # Docker image build instructions
- ├── docker-compose.yml      # Container orchestration
- ├── build/web/              # Compiled Flutter Web application
- ├── lib/                    # Flutter source code
- ├── assets/                 # Assets (images)
- ├── pubspec.yaml            # Flutter dependencies
- └── README.md               # Documentation

## 🛠 Tech Stack

- **Flutter** – cross‑platform UI framework
- **SQLite** – local database (cards, folders, sets, sessions and etc.)
- **Google Gemini AI** – dynamic test generation & notification content
- **Firebase Cloud Messaging** – push notifications (Android/iOS)
- **photo_manager** – gallery access for declutter feature
- **flutter_local_notifications** – local reminders

> ⚠️ Web platform works with limited SQLite support; use Android/iOS for full experience.

## 📲 Future Plans

- Full SRS study mode with SM‑2 inter‑session scheduling
- Test session caching and statistics
- Editable/removable cards and sets
- Cross‑platform sync (Firestore)
- AI‑powered journaling prompts and insights
- User profile customization (avatar, theme, etc.)
- Multi-language support
- Offline mode with local data storage
- User authentication and authorization (Firebase Auth)
- Push notifications for daily reminders and SRS notifications
- User feedback and support channels
- User activity tracking and analysis
- User progress visualization and achievement system
- User feedback and support channels

---

**MicroStep** – small steps, deep growth. 🌱

## 🚀 Getting Started


## Cloud deployment:
- https://microstep-cc-container.onrender.com/

## Local running
```bash
git clone https://github.com/Sanzharyeraliev/microstep_CC_container.git
cd microstep_CC_container
docker-compose up
Open in your browser: http://localhost:8080

