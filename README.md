# Zynyo Inbox (Team Tung)

<img width="1400" height="1800" alt="image" src="https://github.com/user-attachments/assets/1bfb2417-2e13-4083-a4b3-3817935bb857" />

Developed for the **Inter-Actief Hackathon 2026**.

### Team Members:
* **Daniel Frutos Rodriguez**
* **Tim van Beek**
* **Matthias van der Most**
* **Bogdan Mocanu**

## About Zynyo Inbox
**Zynyo Inbox** is a sleek and modern document management application developed during the **Inter-Actief Hackathon 2026**. Built with Flutter, it provides a seamless interface for users to manage, view, and sign documents powered by the Zynyo API.

### Key Features
- **Modern Dashboard:** A clean, high-fidelity inbox to track pending, signed, and rejected documents.
- **Secure Signing:** Integrated webview for secure, on-the-go document signing.
- **PDF Viewer:** Built-in previewer for signed documents.
- **Hackathon Stats Tracker:** A dedicated section to monitor the "essential" metrics of a coding marathon—from energy drinks to crashouts.


## Setup Instructions

1. **Secrets Configuration**
   Ensure `secrets.json` is located in the root directory (outside the `zynzynzynsahur` folder).

2. **Installation**
   ```bash
   flutter pub get
   ```

3. **Running the App**
   ```bash
   flutter run --dart-define-from-file=../secrets.json
   ```

4. **Building for Release**
   To generate a release APK:
   ```bash
   flutter build apk --dart-define-from-file=../secrets.json
   ```
