part of x_overlay;

class XNavigatorObserver extends _XNavigatorObserver {
  XNavigatorObserver({required super.observerMixin});
}

class _XNavigatorObserver extends NavigatorObserver {
  final XNavigatorObserverMixin? observerMixin;

  Route? _currentRoute;

  _XNavigatorObserver({required this.observerMixin});
  Route? get currentRoute => _currentRoute;
  bool get isDialogShown => _currentRoute is DialogRoute;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    observerMixin?._currentRoute = route;
    observerMixin?.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _currentRoute = previousRoute;
    observerMixin?.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _currentRoute = previousRoute;
    observerMixin?.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _currentRoute = newRoute;
    observerMixin?.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didChangeTop(Route<dynamic> topRoute, Route<dynamic>? previousTopRoute) {
    _currentRoute = topRoute;
    observerMixin?.didChangeTop(topRoute, previousTopRoute);
  }

  @override
  void didStartUserGesture(
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) {
    observerMixin?.didStartUserGesture(route, previousRoute);
  }

  @override
  void didStopUserGesture() {
    observerMixin?.didStopUserGesture();
  }
}

mixin XNavigatorObserverMixin {
  Route? _currentRoute;
  Route? get currentRoute => _currentRoute;
  bool get isDialogShown => _currentRoute is DialogRoute;

  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {}

  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {}

  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {}

  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {}

  void didChangeTop(
    Route<dynamic> topRoute,
    Route<dynamic>? previousTopRoute,
  ) {}

  void didStartUserGesture(
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) {}

  void didStopUserGesture() {}
}
