part of x_overlay;

class XOverlayEntry {
  OverlayEntry? _overlayEntry;
  StreamController<bool> _visibleController = StreamController<bool>();
  Duration? _hideAnimationDuration;

  bool get isShown => _overlayEntry != null;

  void Function()? onDismissed;

  /// [isAbsorbPointer] 拦截事件，为true时，[dismissOutside] 无效
  void show({
    required Widget child,
    required TransitionBuilder transitionBuilder,
    required Duration showAnimationDuration,
    required Duration hideAnimationDuration,
    required bool dismissOutside,
    required bool dismissBackpress,
    required bool isAbsorbPointer,
    required Color backgroundColor,
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
            dismissOutside: dismissOutside,
            dismissBackpress: dismissBackpress,
            isAbsorbPointer: isAbsorbPointer,
            backgroundColor: backgroundColor,
            dismiss: () {
              dismiss();
            },
            child: child,
          );
        },
      );
      _hideAnimationDuration = hideAnimationDuration;
      overlayState?.insert(_overlayEntry!);
      _visibleController.add(true);
    }
  }

  Future dismiss() async {
    if (_overlayEntry != null && _overlayEntry!.mounted) {
      onDismissed?.call();
      _visibleController.add(false);
      _visibleController.close();
      await Future.delayed(
        _hideAnimationDuration ?? Duration(milliseconds: 300),
      );
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }
}

class _XOverlayEntry extends StatefulWidget {
  final Widget child;
  final TransitionBuilder transitionBuilder;
  final Duration showAnimationDuration;
  final Duration hideAnimationDuration;
  final Stream<bool> visibleStream;
  final bool dismissOutside;
  final bool dismissBackpress;
  final bool isAbsorbPointer;
  final void Function() dismiss;
  final Color backgroundColor;
  const _XOverlayEntry({
    required this.transitionBuilder,
    required this.showAnimationDuration,
    required this.hideAnimationDuration,
    required this.child,
    required this.visibleStream,
    required this.dismissOutside,
    required this.dismissBackpress,
    required this.isAbsorbPointer,
    required this.dismiss,
    required this.backgroundColor,
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
  bool _visible = true;
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
    _visible = visible;
    setState(() {});
    if (visible) {
      animationController.duration = widget.showAnimationDuration;
      animationController.forward();
    } else {
      animationController.duration = widget.hideAnimationDuration;
      animationController.reverse();
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Material(
      type: widget.backgroundColor == Colors.transparent
          ? MaterialType.transparency
          : MaterialType.canvas,
      color: widget.backgroundColor,
      child: PopScope(
        canPop: widget.dismissBackpress,
        onPopInvokedWithResult: (value, result) {
          if (widget.dismissBackpress) {
            widget.dismiss();
          }
        },
        child: GestureDetector(
          onTap: () {
            if (widget.dismissBackpress) {
              widget.dismiss();
            }
          },
          child: SafeArea(
            child: IgnorePointer(
              child: widget.transitionBuilder(
                context,
                animation,
                _visible,
                widget.child,
              ),
            ),
          ),
        ),
      ),
    );
    if (widget.isAbsorbPointer) {
      return AbsorbPointer(absorbing: true, child: child);
    } else {
      return child;
    }
  }
}
