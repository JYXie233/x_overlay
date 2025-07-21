part of x_overlay;

TransitionBuilder defaultTransitionBuilder =
    (context, animation, visible, child) {
      return ScaleTransition(
        scale: Tween<double>(
          begin: 0.5,
          end: 1,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: child,
      );
    };

class XLoadingCompanion {
  XOverlayEntry? _overlayEntry;
  final StreamController<dynamic> _argumentStreamController =
      StreamController<dynamic>.broadcast();

  late Widget Function(BuildContext context, dynamic argument) _builder;

  void configuration({
    required Widget Function(BuildContext context, dynamic argument) builder,
  }) {
    _builder = builder;
  }

  void show({
    dynamic argument,
    TransitionBuilder? transitionBuilder,
    Duration? showAnimationDuration,
    Duration? hideAnimationDuration,
    bool? dismissOutside,
    bool? dismissBackpress,
    bool? isAbsorbPointer,
    Color? backgroundColor,
  }) {
    if (_overlayEntry == null) {
      _overlayEntry = XOverlayEntry();
      _overlayEntry?.show(
        child: StreamBuilder(
          stream: _argumentStreamController.stream,
          builder: (context, snapshot) => _builder(context, snapshot.data),
        ),
        transitionBuilder: transitionBuilder ?? defaultTransitionBuilder,
        showAnimationDuration:
            showAnimationDuration ?? const Duration(milliseconds: 300),
        hideAnimationDuration:
            hideAnimationDuration ?? const Duration(milliseconds: 300),
        dismissOutside: dismissOutside ?? false,
        dismissBackpress: dismissBackpress ?? false,
        isAbsorbPointer: isAbsorbPointer ?? false,
        backgroundColor: backgroundColor ?? Colors.black38,
      );
    }
  }

  void dismiss() {
    _overlayEntry?.dismiss();
    _overlayEntry = null;
  }
}
