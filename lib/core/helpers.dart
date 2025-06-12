import 'dart:async';

import 'package:flutter/foundation.dart';

// This class converts a Stream into a ChangeNotifier,
// allowing GoRouter to listen for changes and re-evaluate redirects.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners(); // Notify listeners immediately on creation to handle initial state
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
