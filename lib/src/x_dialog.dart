part of x_overlay;

class XDialogCompanion extends _XNavigatorObserver {
  final Lock _lock = Lock();

  XDialogCompanion() : super(observerMixin: null);

  Future<T?> show<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
    TraversalEdgeBehavior? traversalEdgeBehavior,
    bool? requestFocus,
    AnimationStyle? animationStyle,
  }) async {
    return await _lock.synchronized(() async {
      BuildContext context = _findBuildContext()!;
      return await showDialog(
        context: context,
        builder: builder,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
        barrierLabel: barrierLabel,
        useSafeArea: useSafeArea,
        useRootNavigator: useRootNavigator,
        routeSettings: routeSettings,
        anchorPoint: anchorPoint,
        traversalEdgeBehavior: traversalEdgeBehavior,
        requestFocus: requestFocus,
        animationStyle: animationStyle,
      );
    });
  }

  /// 直接显示弹窗，不排队
  Future<T?> showWithoutQueue<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
    TraversalEdgeBehavior? traversalEdgeBehavior,
    bool? requestFocus,
    AnimationStyle? animationStyle,
  }) async {
    BuildContext context = _findBuildContext()!;
    return showDialog(
      context: context,
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      anchorPoint: anchorPoint,
      traversalEdgeBehavior: traversalEdgeBehavior,
      requestFocus: requestFocus,
      animationStyle: animationStyle,
    );
  }
}
