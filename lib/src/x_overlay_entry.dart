part of x_overlay;

class XOverlayEntry {
  OverlayEntry? _overlayEntry;
  StreamController<bool> _visibleController = StreamController<bool>();
  Duration? _hideAnimationDuration;

  bool get isShown => _overlayEntry != null;

  void show({
    required Widget child,
    required TransitionBuilder transitionBuilder,
    required Duration showAnimationDuration,
    required Duration hideAnimationDuration,
  }) {
    if (_overlayEntry == null) {
      _visibleController = StreamController<bool>();
      final overlayState = _findOverlayState();
      _overlayEntry = OverlayEntry(
        builder: (context) {
          return _XOverlayEntry(
            visibleStream: _visibleController.stream,
            transitionBuilder: transitionBuilder,
            showAnimationDuration: showAnimationDuration,
            hideAnimationDuration: hideAnimationDuration,
            child: child,
          );
        },
      );
      _hideAnimationDuration = hideAnimationDuration;
      overlayState?.insert(_overlayEntry!);
      _visibleController.add(true);
    }
  }

  void dismiss() {
    if (_overlayEntry != null && _overlayEntry!.mounted) {
      _visibleController.add(false);
      _visibleController.close();
      Future.delayed(
        _hideAnimationDuration ?? Duration(milliseconds: 300),
      ).then((_) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      });
    }
  }
}

class _XOverlayEntry extends StatefulWidget {
  final Widget child;
  final TransitionBuilder transitionBuilder;
  final Duration showAnimationDuration;
  final Duration hideAnimationDuration;
  final Stream<bool> visibleStream;

  const _XOverlayEntry({
    required this.transitionBuilder,
    required this.showAnimationDuration,
    required this.hideAnimationDuration,
    required this.child,
    required this.visibleStream,
  });

  @override
  State<StatefulWidget> createState() {
    return _XOverlayEntryState();
  }
}

class _XOverlayEntryState extends State<_XOverlayEntry>
    with TickerProviderStateMixin {
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
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: IgnorePointer(
          child: widget.transitionBuilder(context, animation, widget.child),
        ),
      ),
    );
  }
}
