part of x_overlay;

TransitionBuilder defaultTransitionBuilder = (context, animation, child) {
  return ScaleTransition(
    scale: Tween<double>(
      begin: 0.5, 
      end: 1,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
    child: child,
  );
};

class XLoadingCompanion {
  OverlayEntry? _overlayEntry;
  late Widget Function(BuildContext context, dynamic argument) _builder;
  late StreamController<bool> _visibleController;
  late StreamController<dynamic> _argumentController;
  late TransitionBuilder _transitionBuilder;
  void configuration({
    required Widget Function(BuildContext context, dynamic argument) builder,
    TransitionBuilder? transitionBuilder,
  }) {
    _builder = builder;
    _transitionBuilder = transitionBuilder ?? defaultTransitionBuilder;
  }

  void show({dynamic argument}) async {
    if (_overlayEntry != null && _overlayEntry!.mounted) {
      _argumentController.add(argument);
    } else {
      _argumentController = StreamController<dynamic>();
      _visibleController = StreamController<bool>();
      final overlayState = _findOverlayState();
      _overlayEntry = OverlayEntry(
        builder: (context) {
          return _XLoading(
            visibleStream: _visibleController.stream,
            argumentStream: _argumentController.stream,
            builder: _builder,
            transitionBuilder: _transitionBuilder,
          );
        },
      );
      _visibleController.add(true);
      overlayState?.insert(_overlayEntry!);
    }
  }

  void hide() {
    if (_overlayEntry != null && _overlayEntry!.mounted) {
      _visibleController.add(false);
      _visibleController.close();
      _argumentController.close();
      Future.delayed(Duration(milliseconds: 300)).then((_) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      });
    }
  }
}

class _XLoading extends StatefulWidget {
  final Stream<bool> visibleStream;
  final Stream<dynamic> argumentStream;
  final Widget Function(BuildContext context, dynamic argument) builder;
  final TransitionBuilder transitionBuilder;
  const _XLoading({
    required this.visibleStream,
    required this.argumentStream,
    required this.builder,
    required this.transitionBuilder,
  });
  @override
  State<StatefulWidget> createState() {
    return _XLoadingState();
  }
}

class _XLoadingState extends State<_XLoading> with TickerProviderStateMixin {
  StreamSubscription? argumentSubscription;
  StreamSubscription? visibleSubscription;
  dynamic argument;

  late AnimationController animationController = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 300),
  );
  late Animation<double> animation;

  @override
  void initState() {
    argumentSubscription = widget.argumentStream.listen(onArgumentData);
    visibleSubscription = widget.visibleStream.listen(onVisibleData);
    animationController.addListener(() {
      setState(() {});
    });
    animation = Tween(begin: 0.0, end: 1.0).animate(animationController);
    super.initState();
  }

  void onArgumentData(dynamic argument) {
    setState(() {
      this.argument = argument;
    });
  }

  void onVisibleData(bool visible) {
    if (visible) {
      animationController.forward();
    } else {
      animationController.reverse();
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    argumentSubscription?.cancel();
    visibleSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.builder(context, argument);
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: GestureDetector(
          child: widget.transitionBuilder(context, animation, child),
        ),
      ),
    );
  }
}
