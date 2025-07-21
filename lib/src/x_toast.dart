part of x_overlay;

TransitionBuilder defaultToastTransitionBuilder =
    (
      BuildContext context,
      Animation<double> animation,
      bool visible,
      Widget child,
    ) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 28, vertical: 56),
          decoration: BoxDecoration(color: Colors.transparent),
          clipBehavior: Clip.antiAlias,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: Offset(0, 2), // 从上方滑入
                  end: Offset(0, 0),
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
            child: child,
          ),
        ),
      );
    };

class ToastCompanion {
  final Lock _lock = Lock();

  Widget Function(BuildContext context, dynamic argument) _builder =
      (context, argument) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text("${argument}", style: TextStyle(color: Colors.white)),
        );
      };

  void configuration({
    required Widget Function(BuildContext context, dynamic argument) builder,
  }) {
    _builder = builder;
  }

  void showToast({required String text, Duration? duration}) {
    show(
      child: Builder(builder: (context) => _builder(context, text)),
      duration:
          duration ??
          Duration(milliseconds: max(750, min(2000, text.length * 50))),
    );
  }

  void show({
    required Widget child,
    Duration? duration,
    TransitionBuilder? transitionBuilder,
    Duration? showAnimationDuration,
    Duration? hideAnimationDuration,
    bool? dismissOutside,
    bool? dismissBackpress,
    bool? isAbsorbPointer,
    Color? backgroundColor,
  }) async {
    await _lock.synchronized(() async {
      final overlayEntry = XOverlayEntry();
      overlayEntry.show(
        child: child,
        transitionBuilder: transitionBuilder ?? defaultToastTransitionBuilder,
        showAnimationDuration:
            showAnimationDuration ?? const Duration(milliseconds: 200),
        hideAnimationDuration:
            hideAnimationDuration ?? const Duration(milliseconds: 200),
        dismissOutside: dismissOutside ?? false,
        dismissBackpress: dismissBackpress ?? false,
        isAbsorbPointer: isAbsorbPointer ?? false,
        backgroundColor: backgroundColor ?? Colors.transparent,
      );
      await Future.delayed(duration ?? Duration(seconds: 1));

      await overlayEntry.dismiss();
    });
  }
}
