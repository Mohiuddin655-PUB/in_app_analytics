import 'package:flutter/material.dart';
import 'package:in_app_analytics/in_app_analytics.dart';

class MyAnalyticsDelegate implements AnalyticsDelegate {
  @override
  Future<void> error(AnalyticsError error) async {
    // Send error to server, Firebase Crashlytics, or just log to console
  }

  @override
  Future<void> event(AnalyticsEvent event) async {
    // Send event to analytics service
  }

  @override
  Future<void> log(String name, String? msg, String reason) async {
    // Custom log storage or service
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize analytics
  Analytics.init(
    enabled: true,
    showLogs: true,
    showSuccessLogs: true,
    showLogTime: true,
    delegate: MyAnalyticsDelegate(),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Analytics Demo',
      home: Scaffold(
        appBar: AppBar(title: const Text('Analytics Demo')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: const Text('Log Success'),
                onPressed: () {
                  Analytics.log("UserLogin", "User logged in successfully",
                      msg: "Login success");
                  // ✅ / 👌
                },
              ),
              ElevatedButton(
                child: const Text('Log Error'),
                onPressed: () {
                  Analytics.call(() {
                    throw Exception("Test login failed");
                  });
                },
              ),
              ElevatedButton(
                child: const Text('Track Event'),
                onPressed: () {
                  Analytics.event("Purchase",
                      msg: "Item bought successfully",
                      props: {
                        "item": "Pro Plan",
                        "price": "9.99",
                      });
                  // 🚀 / ⚠️
                },
              ),
              ElevatedButton(
                child: const Text('void Call'),
                onPressed: () async {
                  Analytics.call(() {
                    throw UnsupportedError("Testing purpose!");
                  });
                },
              ),
              ElevatedButton(
                child: const Text('Future<Value> Call'),
                onPressed: () async {
                  final data = await Analytics.execute(() {
                    throw UnsupportedError("Testing purpose!");
                  });
                  print(data);
                },
              ),
              StreamBuilder(
                stream: Analytics.stream<String>(() {
                  throw UnsupportedError("Testing purpose!");
                }),
                builder: (context, snapshot) {
                  return Text(snapshot.data ?? "Not found!");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
