# Quick Journal Flutter App

> A cross-platform journaling application built with Flutter and GraphQL.

## 📱 Features

- **User Authentication** - Secure login and registration with JWT tokens
- **Journal Entries** - Create, read, update, and delete journal entries
- **Beautiful UI** - Modern Material Design 3 interface
- **Real-time Sync** - GraphQL integration for instant data updates
- **Secure Storage** - JWT tokens stored securely on device
- **Cross-platform** - Works on Web, iOS, and Android

## 🏗 Architecture

```
lib/
├── config/          # API configuration
├── services/        # GraphQL client, auth service
├── models/          # Data models (User, Entry)
├── providers/       # State management (Provider pattern)
├── screens/         # UI screens
│   ├── auth/        # Login, Register
│   ├── home/        # Entry list
│   └── entry/       # Entry CRUD
├── widgets/         # Reusable UI components
└── main.dart        # App entry point
```

## 🛠 Tech Stack

| Category | Technology |
|----------|-----------|
| **Framework** | Flutter |
| **Language** | Dart |
| **API** | GraphQL |
| **State Management** | Provider |
| **Auth Storage** | flutter_secure_storage |
| **Date Formatting** | intl |

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Running backend API (see `../backend/README.md`)
- Docker Desktop (for running the backend)

### Setup

1. **Install dependencies**:
   ```bash
   cd frontend
   flutter pub get
   ```

2. **Start the backend**:
   ```bash
   cd ..
   docker compose up -d
   ```

3. **Run the app**:

   **For Web**:
   ```bash
   flutter run -d chrome
   ```

   **For iOS Simulator** (macOS only):
   ```bash
   flutter run -d "iPhone 15 Pro"
   ```

   **For Android Emulator**:
   ```bash
   flutter run -d emulator-5554
   ```

## 🌐 Platform Configuration

### Web
- API URL: `http://localhost:8080/api/graphql`
- Works out of the box in Chrome/Firefox/Safari

### iOS Simulator
- API URL: `http://localhost:8080/api/graphql`
- No additional configuration needed

### Android Emulator
- API URL: `http://10.0.2.2:8080/api/graphql`
- Uses special address for host machine
- Configuration in `lib/config/api_config.dart`

### Physical Devices
If running on a physical device, update the API URL in `lib/config/api_config.dart`:
```dart
// Replace with your computer's local IP
return 'http://192.168.1.100:8080/api/graphql';
```

## 📖 Key Concepts

### State Management with Provider

This app uses the **Provider** pattern for state management:

- **AuthProvider**: Manages user authentication state
  - Stores current user
  - Handles login/register/logout
  - Persists JWT token securely

- **EntriesProvider**: Manages journal entries
  - Stores list of entries
  - Handles CRUD operations
  - Optimistic UI updates

Example usage:
```dart
// Access provider
final authProvider = Provider.of<AuthProvider>(context);

// Use data
if (authProvider.isAuthenticated) {
  // User is logged in
  print(authProvider.currentUser.name);
}
```

### GraphQL Integration

The app communicates with the backend using GraphQL:

1. **Client Setup** (`services/graphql_client.dart`):
   - Creates Apollo client
   - Adds JWT token to requests
   - Handles caching

2. **Queries & Mutations** (`services/graphql_queries.dart`):
   - All GraphQL operations defined as strings
   - Type-safe with variables
   - Matches backend schema

3. **Execution** (in providers):
   - Use `client.query()` for reading data
   - Use `client.mutate()` for creating/updating

### Secure Token Storage

JWT tokens are stored using `flutter_secure_storage`:

- **iOS**: Stored in Keychain (encrypted)
- **Android**: Stored in EncryptedSharedPreferences
- **Web**: Stored in browser's secure storage

The token is automatically included in all authenticated requests.

### Navigation

The app uses simple imperative navigation:

```dart
// Navigate to new screen
Navigator.of(context).push(
  MaterialPageRoute(builder: (_) => NewScreen()),
);

// Go back
Navigator.of(context).pop();
```

### Flutter vs React/Next.js

Key differences from React:

| Concept | React/Next.js | Flutter |
|---------|---------------|---------|
| **Components** | JSX Components | Widgets |
| **Styling** | CSS/Tailwind | Widget properties |
| **State** | useState, Context | setState, Provider |
| **Rendering** | Virtual DOM | Widget tree |
| **Layout** | Flexbox/Grid | Column/Row/Stack |
| **Navigation** | react-router | Navigator |

Example comparison:

**React**:
```jsx
<div style={{ padding: 20 }}>
  <h1>{title}</h1>
  <button onClick={handleClick}>Click</button>
</div>
```

**Flutter**:
```dart
Padding(
  padding: EdgeInsets.all(20),
  child: Column(
    children: [
      Text(title, style: TextStyle(fontSize: 24)),
      ElevatedButton(
        onPressed: handleClick,
        child: Text('Click'),
      ),
    ],
  ),
)
```

## 🧪 Testing

To test the app:

1. **Start the backend**:
   ```bash
   docker compose up -d
   ```

2. **Verify API is running**:
   ```bash
   curl http://localhost:8080/api/status
   ```

3. **Run the Flutter app**:
   ```bash
   flutter run -d chrome
   ```

4. **Test the flow**:
   - Register a new account
   - Login with credentials
   - Create a journal entry
   - Edit the entry
   - Delete the entry
   - Logout

## 🐛 Troubleshooting

### "Connection refused" error
- Make sure backend is running: `docker compose ps`
- Check API URL in `lib/config/api_config.dart`
- For Android emulator, use `10.0.2.2` instead of `localhost`

### "Failed to load network image" on iOS
- iOS requires HTTPS by default
- For development, we allow HTTP in Info.plist

### Token not persisting
- Check secure storage permissions
- On web, ensure cookies/storage are enabled

## 📚 Learning Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [GraphQL Flutter](https://pub.dev/packages/graphql_flutter)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)

## 🎯 Next Steps

Potential enhancements:

- [ ] Add entry search functionality
- [ ] Implement entry tags/categories
- [ ] Add rich text editor
- [ ] Implement dark mode
- [ ] Add biometric authentication
- [ ] Offline support with sync
- [ ] Export entries to PDF
- [ ] Add entry attachments (photos)

## 📄 License

This project is part of a learning portfolio.
