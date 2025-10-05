## Settings

A Flutter/Dart singleton manager for in-app settings with automatic type detection, supporting
primitives, collections, maps, JSON, and optional custom storage delegates.

## Features

- Singleton manager for app-wide settings.
- Supports **primitive types**: `int`, `double`, `String`, `bool`, `null`.
- Supports **collections**: `List<int>`, `List<double>`, `List<String>`, `List<bool>`.
- Supports **maps and JSON** with nested structures.
- Automatic **DataType detection** for stored values.
- Optional **custom storage delegate** for local or remote persistence.
- Operations:
    - `get` — retrieve a value with type safety.
    - `set` — store a value.
    - `increment` — increment numeric values.
    - `arrayUnion` — add elements to a list without duplicates.
    - `arrayRemove` — remove elements from a list.
- Handles **empty lists and maps** gracefully.
- Built-in **logging support** for debugging.
- Deep string parsing for numeric and boolean detection.

## Installation:

Add this to your pubspec.yaml:
dependencies:

```base
in_app_settings: ^1.0.0
```

or,

```shell
flutter pub add in_app_settings
```

Then run:

```shell
flutter pub get
```

## Examples:
```dart
import 'package:flutter/material.dart';
import 'package:in_app_settings/in_app_analytics.dart';

/// Example delegate storing settings in memory.
class MySettingsDelegate implements SettingsDelegate {
  final Map<String, dynamic> _store = {};

  @override
  bool backup(SettingsWriteRequest request) {
    _store[request.path] = request.value;
    return true;
  }

  @override
  Object? cache(SettingsReadRequest request) {
    return _store[request.path];
  }

  @override
  Future<void> clean(Iterable<String> keys) async => _store.clear();

  @override
  Future<SettingsBackupResponse> get() async {
    // GET FROM REMOTE
    return SettingsBackupResponse.ok(_store);
  }

  @override
  Future<void> set(SettingsWriteRequest request) async {
    // SAVE TO REMOTE
    _store[request.path] = request.value;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Settings
  await Settings.init(showLogs: true, delegate: MySettingsDelegate());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Settings Example',
      home: Scaffold(
        appBar: AppBar(title: const Text('Settings Example')),
        body: const SettingsDemo(),
      ),
    );
  }
}

class SettingsDemo extends StatefulWidget {
  const SettingsDemo({super.key});

  @override
  State<SettingsDemo> createState() => _SettingsDemoState();
}

class _SettingsDemoState extends State<SettingsDemo> {
  @override
  Widget build(BuildContext context) {
    final counter = Settings.get('counter', 0);
    final items = Settings.get('items', <String>[]);
    final user = Settings.get('user', {'name': 'Guest'});

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Counter: $counter'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Settings.increment('counter', 1);
              setState(() {});
            },
            child: const Text('Increment Counter'),
          ),
          const SizedBox(height: 16),
          Text('Items: ${items.join(', ')}'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Settings.arrayUnion('items', ['apple', 'banana']);
              setState(() {});
            },
            child: const Text('Add Items'),
          ),
          ElevatedButton(
            onPressed: () {
              Settings.arrayRemove('items', ['banana']);
              setState(() {});
            },
            child: const Text('Remove Banana'),
          ),
          const SizedBox(height: 16),
          Text('User: ${user['name']}'),
          ElevatedButton(
            onPressed: () {
              Settings.set('user', {'name': 'Alice'});
              setState(() {});
            },
            child: const Text('Set User Name to Alice'),
          ),
        ],
      ),
    );
  }
}
```

## License:

MIT License
