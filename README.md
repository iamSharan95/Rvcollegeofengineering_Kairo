# Kairo

Kairo is a minimalist, AI-powered personal assistant and productivity hub designed for executive-level focus. It streamlines your digital life by centralizing your schedule, communications, and knowledge base into a cohesive, design-driven experience.

## ✨ Key Features

### 🏛️ Dashboard
*   **Structured Overview:** A high-level view of your day with personalized greetings.
*   **Today Summary:** Real-time tracking of active tasks and priority items.
*   **Quick Notes:** Rapid-entry system to capture thoughts that automatically sync to your Hub.
*   **Mobility Logic:** Intelligent ride-hailing integration with commute buffers (ETD/ETA) for your next calendar event.

### 🧠 Hub (Knowledge Base)
*   **Transcripts:** View AI-generated summaries and full transcripts of your meetings.
*   **Knowledge:** A dedicated space for personal notes and saved resources from the Stream.
*   **Interactive Detail:** Full-screen views for reading and managing your knowledge assets.

### 📅 Schedule
*   **Google Calendar Sync:** Full integration with your primary Google Calendar.
*   **Dynamic Timeline:** Visual representation of your day including events and commute times.
*   **Event Management:** Add, remove, and manage events with location-aware commute tracking.

### ✉️ Mail
*   **Gmail Integration:** Read and manage your inbox directly within the app.
*   **Smart Compose:** Send emails quickly without leaving the platform.
*   **Intelligent Categorization:** Automatic tagging of travel, meetings, and tech-related communications.

### 🌊 Stream (Explore)
*   **Curated Content:** Latest news and industry releases.
*   **GitHub Trending:** Track rising repositories and save them directly to your Knowledge Hub for later review.

## 🛠️ Tech Stack

*   **Framework:** [Flutter](https://flutter.dev/)
*   **State Management:** [Provider](https://pub.dev/packages/provider)
*   **Authentication:** Firebase Auth & Google Sign-In
*   **APIs:** Google Calendar API, Gmail API
*   **Styling:** Google Fonts (Instrument Serif & Inter), Material 3
*   **Utilities:** `intl` for formatting, `url_launcher` for external links.

## 🚀 Getting Started

### Prerequisites
*   Flutter SDK (3.x or higher)
*   A Google Cloud Project with Gmail and Calendar APIs enabled.
*   Firebase project configured for Android/iOS.

### Setup


### **Configuration:**
    *   Place your `google-services.json` in `android/app/`.
    *   Ensure your `serverClientId` in `lib/main.dart` matches your Google Cloud OAuth 2.0 Client ID.
    *   Update the SHA-1 fingerprint in the Firebase Console for Google Sign-In to work

## 📂 Project Structure

*   `lib/models/`: Data structures for Notes, Emails, Tasks, and Calendar Events.
*   `lib/providers/`: Business logic and state handling for all core features.
*   `lib/screens/`: UI implementation for each main module (Dashboard, Hub, etc.).
*   `lib/services/`: Direct API communication with Google and other external services.

## 📄 License
This project is for personal use and development. Ensure you comply with Google API Terms of Service when deploying.
