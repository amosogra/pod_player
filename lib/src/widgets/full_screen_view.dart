part of 'package:pod_player/src/pod_player.dart';

class FullScreenView extends StatefulWidget with GetItStatefulWidgetMixin {
  final String tag;
  FullScreenView({
    Key? key,
    required this.tag,
  }) : super(key: key);

  @override
  State<FullScreenView> createState() => _FullScreenViewState();
}

class _FullScreenViewState extends State<FullScreenView> with TickerProviderStateMixin, GetItStateMixin {
  late PodGetXVideoController _podCtr;
  @override
  void initState() {
    _podCtr = Get.find<PodGetXVideoController>(tag: widget.tag);
    _podCtr.fullScreenContext = context;
    _podCtr.keyboardFocusWeb?.removeListener(_podCtr.keyboadListner);

    super.initState();
  }

  @override
  void dispose() {
    _podCtr.keyboardFocusWeb?.requestFocus();
    _podCtr.keyboardFocusWeb?.addListener(_podCtr.keyboadListner);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showSidePanel = watchX((PodManager x) => x.setShowSidePanelStateCommand);
    const circularProgressIndicator = CircularProgressIndicator(
      backgroundColor: Colors.black87,
      color: Colors.white,
      strokeWidth: 2,
    );
    return WillPopScope(
      onWillPop: () async {
        if (kIsWeb) {
          _podCtr.disableFullScreen(
            context,
            widget.tag,
            enablePop: false,
          );
        }
        if (!kIsWeb) _podCtr.disableFullScreen(context, widget.tag);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GetBuilder<PodGetXVideoController>(
          tag: widget.tag,
          id: 'side-panel',
          builder: (_podCtr) {
            if (kDebugMode) {
              print('************setShowSidePanelStateCommand=$showSidePanel************');
            }
            return Center(
              child: Row(
                children: [
                  Expanded(
                    flex: showSidePanel ? 7 : 1,
                    child: ColoredBox(
                      color: Colors.black,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: _podCtr.videoCtr == null
                              ? circularProgressIndicator
                              : _podCtr.videoCtr!.value.isInitialized
                                  ? Stack(
                                    children: [
                                      _PodCoreVideoPlayer(
                                          tag: widget.tag,
                                          videoPlayerCtr: _podCtr.videoCtr!,
                                          videoAspectRatio: _podCtr.videoCtr?.value.aspectRatio ?? 16 / 9,
                                        ),
                                        _podCtr.logoBuilder?.call(_podCtr) ?? const SizedBox()
                                    ],
                                  )
                                  : circularProgressIndicator,
                        ),
                      ),
                    ),
                  ),
                  if (showSidePanel)
                    Expanded(
                      flex: 3,
                      child: AnimatedSwitcher(
                        duration: const Duration(seconds: 2),
                        reverseDuration: const Duration(seconds: 3),
                        child: _podCtr.sidePanelBuilder?.call(_podCtr) ?? const SizedBox(),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
