part of x_overlay;

TransitionBuilder defaultToastTransitionBuilder = (
  BuildContext context,
  Animation<double> animation,
  Widget child,
) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.transparent,
    ),
    clipBehavior: Clip.antiAlias,
    child: SlideTransition(
    position: Tween<Offset>(
      begin: Offset(0, 1), // 从上方滑入
      end: Offset(0, 0),
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
    child: child,
  ),
  );
};

class ToastCompanion {
  final Lock _lock = Lock();

  void show({
    required Widget child,
    required Duration duration,
    TransitionBuilder? transitionBuilder,
  }) async {
    await _lock.synchronized(() async {
      final overlayState = _findOverlayState();
      StreamController<bool> visibleStreamController = StreamController();
      OverlayEntry overlayEntry = OverlayEntry(
        builder: (context) {
          return Material(
            type: MaterialType.transparency,
            child: SafeArea(
              child: IgnorePointer(
                child: _XToast(
                  visibleStream: visibleStreamController.stream,
                  transitionBuilder:
                      transitionBuilder ?? defaultToastTransitionBuilder,
                  child: child,
                ),
              ),
            ),
          );
        },
      );
      visibleStreamController.add(true);
      overlayState?.insert(overlayEntry);
      await Future.delayed(duration);
      visibleStreamController.add(false);
      await Future.delayed(duration);
      overlayEntry.remove();
      visibleStreamController.close();
    });
  }

  void showToast({required String text, Duration? duration}) async {
    show(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          margin: EdgeInsets.symmetric(horizontal: 28, vertical: 56),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(text, style: TextStyle(color: Colors.white)),
        ),
      ),
      duration:
          duration ??
          Duration(milliseconds: max(750, min(2000, text.length * 50))),
    );
  }
}

class _XToast extends StatefulWidget {
  final Stream<bool> visibleStream;
  final Widget child;
  final TransitionBuilder transitionBuilder;
  const _XToast({
    required this.visibleStream,
    required this.child,
    required this.transitionBuilder,
  });

  @override
  createState() => _XToastState();
}

class _XToastState extends State<_XToast> with TickerProviderStateMixin {
  StreamSubscription? streamSubscription;

  late AnimationController animationController = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 300),
  );
  late Animation<double> animation;

  @override
  void initState() {
    streamSubscription = widget.visibleStream.listen(onVisibleChanged);
    animationController.addListener(() {
      setState(() {});
    });
    animation = Tween(begin: 0.0, end: 1.0).animate(animationController);
    super.initState();
  }

  void onVisibleChanged(bool visible) {
    if (visible) {
      animationController.forward();
    } else {
      animationController.reverse();
    }
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.transitionBuilder(context, animation, widget.child);
  }
}
