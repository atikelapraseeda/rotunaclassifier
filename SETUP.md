# Rotula Classifier - Setup Guide

## Prerequisites
- Flutter SDK 3.9.2 or higher
- A free Gemini API key

## Getting Your Gemini API Key

1. Visit [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Click "Create API Key" or "Get API Key"
3. Copy your API key (it will look like: `AIza...`)
4. Keep this key secure!

## Installation Steps

### 1. Add Your API Key

Open `lib/main.dart` and replace:
```dart
const String GEMINI_API_KEY = 'YOUR_GEMINI_API_KEY_HERE';
```

With your actual API key:
```dart
const String GEMINI_API_KEY = '';
```

**⚠️ Security Warning:** Never commit your API key to version control. Consider using environment variables or a local configuration file that's in `.gitignore`.

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run the App

```bash
flutter run
```

## How It Works

1. **Pick an Image**: Select an image from your gallery or take a photo
2. **AI Analysis**: The app sends the image to Google's Gemini AI
3. **Results**: 
   - If it's a plant: Shows the plant name and medical uses
   - If it's not a plant: Shows "Unknown Object"

## Features

- ✅ Real-time plant detection using Gemini AI
- ✅ Displays plant name and medical uses
- ✅ "Unknown Object" detection for non-plants
- ✅ Works offline after initialization
- ✅ Beautiful Material 3 UI
- ✅ Dark mode support
- ✅ Camera and gallery image support

## Troubleshooting

### "Failed to initialize Gemini"
- Check if your API key is correct
- Ensure you have internet connection
- Make sure your API key has the required permissions

### "Permission denied"
- Android/iOS may require permission grants for camera and photos
- Check app settings and grant necessary permissions

### No response from Gemini
- Check your internet connection
- Verify the API key is valid
- Make sure the Gemini API is enabled in your Google Cloud project

## API Key Best Practices

1. **Use Environment Variables**:
   ```dart
   const String GEMINI_API_KEY = String.fromEnvironment('GEMINI_API_KEY');
   ```

2. **Add to .gitignore**:
   ```
   lib/config/api_keys.dart
   ```

3. **Use GitHub Secrets** (if using GitHub Actions):
   ```yaml
   - name: Build
     env:
       GEMINI_API_KEY: ${{ secrets.GEMINI_API_KEY }}
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── config/
│   └── api_keys.dart        # API configuration
├── screens/
│   └── results_screen.dart  # Results display screen
├── services/
│   └── gemini_classifier.dart # Gemini AI integration
└── models/
    └── plant_data.dart       # (Legacy) Plant database
```

## Dependencies

- `image_picker`: ^1.1.2 - Image selection from gallery/camera
- `permission_handler`: ^11.4.4 - Permission management
- `google_generative_ai`: ^0.4.4 - Gemini AI API

## License

This project is open source and available under the MIT License.
