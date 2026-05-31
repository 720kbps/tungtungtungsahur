# Zynyo Inbox (Team Tung)

<img width="1400" height="1800" alt="image" src="https://github.com/user-attachments/assets/1bfb2417-2e13-4083-a4b3-3817935bb857" />

Developed for the **Inter-Actief Hackathon 2026**.

### Team Members:
* **Daniel Frutos Rodriguez**
* **Tim van Beek**
* **Matthias van der Most**
* **Bogdan Mocanu**

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
