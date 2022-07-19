//part of 'package:pod_player/src/pod_player.dart';

import 'dart:ui';

import 'package:example/screens/overlays/mobile_bottomsheet.dart';
import 'package:example/screens/overlays/widget/animated_play_pause_icon.dart';
import 'package:example/screens/overlays/widget/video_gesture_detector.dart';
import 'package:flutter/material.dart';
import 'package:pod_player/pod_player.dart';

class MobileOverlay extends StatefulWidget with GetItStatefulWidgetMixin {
  final String tag;
  final VoidCallback? onDoubtTap;

  MobileOverlay({
    Key? key,
    this.onDoubtTap,
    required this.tag,
  }) : super(key: key);

  @override
  State<MobileOverlay> createState() => _MobileOverlayState();
}

class _MobileOverlayState extends State<MobileOverlay> with GetItStateMixin {
  bool toggleBookmark = false;

  @override
  Widget build(BuildContext context) {
    const overlayColor = Colors.black38;
    const itemColor = Colors.white;
    final podCtr = Get.find<PodGetXVideoController>(tag: widget.tag);
    final showSidePanel = watchX((PodManager x) => x.setShowSidePanelStateCommand);
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: VideoGestureDetector(
                tag: widget.tag,
                onDoubleTap: _isRtl() ? podCtr.onRightDoubleTap : podCtr.onLeftDoubleTap,
                child: ColoredBox(
                  color: overlayColor,
                  child: _LeftRightDoubleTapBox(
                    tag: widget.tag,
                    isLeft: !_isRtl(),
                  ),
                ),
              ),
            ),
            VideoGestureDetector(
              tag: widget.tag,
              child: ColoredBox(
                color: overlayColor,
                child: SizedBox(
                  height: double.infinity,
                  child: Center(
                    child: AnimatedPlayPauseIcon(tag: widget.tag, size: 42),
                  ),
                ),
              ),
            ),
            Expanded(
              child: VideoGestureDetector(
                tag: widget.tag,
                onDoubleTap: _isRtl() ? podCtr.onLeftDoubleTap : podCtr.onRightDoubleTap,
                child: ColoredBox(
                  color: overlayColor,
                  child: _LeftRightDoubleTapBox(
                    tag: widget.tag,
                    isLeft: _isRtl(),
                  ),
                ),
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IgnorePointer(
                    child: podCtr.videoTitle ?? const SizedBox(),
                  ),
                ),
              ),
              if (podCtr.showSidePanelButton && podCtr.isFullScreen)
                MaterialIconButton(
                  toolTipMesg: "Toggle Side Panel",
                  color: itemColor,
                  onPressed: () {
                    get<PodManager>().setShowSidePanelStateCommand.call(!showSidePanel);
                  },
                  child: Icon(
                    showSidePanel ? Icons.video_library : Icons.video_library_outlined,
                  ),
                ),
              MaterialIconButton(
                toolTipMesg: podCtr.podPlayerLabels.settings,
                color: itemColor,
                onPressed: () {
                  setState(() {
                    toggleBookmark = !toggleBookmark;
                  });
                },
                child: Icon(
                  toggleBookmark ? Icons.bookmark : Icons.bookmark_outline_outlined,
                ),
              ),
              MaterialIconButton(
                toolTipMesg: podCtr.podPlayerLabels.settings,
                color: itemColor,
                onPressed: () {
                  if (podCtr.isOverlayVisible) {
                    _bottomSheet(context);
                  } else {
                    podCtr.toggleVideoOverlay();
                  }
                },
                child: const Icon(
                  Icons.more_vert_rounded,
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: XMobileOverlayBottomControlles(
            tag: widget.tag,
            onDoubtTap: widget.onDoubtTap,
          ),
        ),
      ],
    );
  }

  bool _isRtl() {
    final Locale locale = window.locale;
    final langs = [
      'ar', // Arabic
      'fa', // Farsi
      'he', // Hebrew
      'ps', // Pashto
      'ur', // Urdu
    ];
    for (int i = 0; i < langs.length; i++) {
      final lang = langs[i];
      if (locale.toString().contains(lang)) {
        return true;
      }
    }
    return false;
  }

  void _bottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => MobileBottomSheet(tag: widget.tag),
    );
  }
}

class _LeftRightDoubleTapBox extends StatelessWidget {
  final String tag;
  final bool isLeft;
  const _LeftRightDoubleTapBox({
    Key? key,
    required this.tag,
    required this.isLeft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PodGetXVideoController>(
      tag: tag,
      id: 'double-tap',
      builder: (podCtr) {
        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: podCtr.isLeftDbTapIconVisible && isLeft
                ? 1
                : podCtr.isRightDbTapIconVisible && !isLeft
                    ? 1
                    : 0,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Lottie.asset(
                    isLeft ? 'packages/pod_player/assets/forward_left.json' : 'packages/pod_player/assets/forward_right.json',
                  ),
                  if (isLeft ? podCtr.isLeftDbTapIconVisible : podCtr.isRightDbTapIconVisible)
                    Transform.translate(
                      offset: const Offset(0, 40),
                      child: Text(
                        '${podCtr.isLeftDbTapIconVisible ? podCtr.leftDoubleTapduration : podCtr.rightDubleTapduration} Sec',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
