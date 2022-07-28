part of 'pod_getx_video_controller.dart';

class _PodUiController extends _PodGesturesController {
  bool isLive = false;
  bool showSidePanelButton = false;
  bool alwaysShowProgressBar = true;
  PodProgressBarConfig podProgressBarConfig = const PodProgressBarConfig();
  Widget Function(OverLayOptions options)? overlayBuilder;
  Widget Function(PodGetXVideoController podGetController)? sidePanelBuilder;
  Widget? videoTitle;
  DecorationImage? videoThumbnail;

  ///video player labels
  PodPlayerLabels podPlayerLabels = const PodPlayerLabels();
}
