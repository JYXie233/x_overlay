part of x_overlay;

typedef TransitionBuilder =
    Widget Function(
      BuildContext context,
      Animation<double> aniamtion,
      Widget child,
    );

BuildContext? _findBuildContext() {
  try {
    final rootElement = WidgetsBinding.instance.rootElement;
    if (rootElement != null) {
      NavigatorState? navigator = _findStateForChildren(rootElement);
      if (navigator != null && navigator.mounted) {
        return navigator.context;
      }
    }
  } catch (_) {}
  return null;
}

OverlayState? _findOverlayState() {
  try {
    final rootElement = WidgetsBinding.instance.rootElement;
    if (rootElement != null) {
      NavigatorState? navigator = _findStateForChildren(rootElement);
      if (navigator != null && navigator.mounted) {
        return navigator.overlay;
      }
    }
  } catch (_) {}
  return null;
}

T? _findStateForChildren<T extends State>(Element element) {
  if (element is StatefulElement && element.state is T) {
    return element.state as T;
  }
  T? target;
  element.visitChildElements((e) => target ??= _findStateForChildren(e));
  return target;
}
