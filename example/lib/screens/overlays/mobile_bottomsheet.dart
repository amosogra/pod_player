import 'package:flutter/foundation.dart';
import 'package:pod_player/pod_player.dart';

import 'dart:async';

import 'package:flutter/material.dart';

class MobileBottomSheet extends StatelessWidget {
  final String tag;

  const MobileBottomSheet({
    Key? key,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PodGetXVideoController>(
      tag: tag,
      builder: (podCtr) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (podCtr.vimeoOrVideoUrls.isNotEmpty)
            _bottomSheetTiles(
              title: podCtr.podPlayerLabels.quality,
              icon: Icons.video_settings_rounded,
              subText: '${podCtr.vimeoPlayingVideoQuality}p',
              onTap: () {
                Navigator.of(context).pop();
                Timer(const Duration(milliseconds: 100), () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => VideoQualitySelectorMob(
                      tag: tag,
                      onTap: null,
                    ),
                  );
                });
                // await Future.delayed(
                //   const Duration(milliseconds: 100),
                // );
              },
            ),
          _bottomSheetTiles(
            title: podCtr.podPlayerLabels.loopVideo,
            icon: Icons.loop_rounded,
            subText: podCtr.isLooping ? podCtr.podPlayerLabels.optionEnabled : podCtr.podPlayerLabels.optionDisabled,
            onTap: () {
              Navigator.of(context).pop();
              podCtr.toggleLooping();
            },
          ),
          _bottomSheetTiles(
            title: podCtr.podPlayerLabels.playbackSpeed,
            icon: Icons.slow_motion_video_rounded,
            subText: podCtr.currentPaybackSpeed,
            onTap: () {
              Navigator.of(context).pop();
              Timer(const Duration(milliseconds: 100), () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => VideoPlaybackSelectorMob(
                    tag: tag,
                    onTap: null,
                  ),
                );
              });
            },
          ),
        ],
      ),
    );
  }

  ListTile _bottomSheetTiles({
    required String title,
    required IconData icon,
    String? subText,
    void Function()? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      onTap: onTap,
      title: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Text(
              title,
            ),
            if (subText != null) const SizedBox(width: 6),
            if (subText != null)
              const SizedBox(
                height: 4,
                width: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            if (subText != null) const SizedBox(width: 6),
            if (subText != null)
              Text(
                subText,
                style: const TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}

class VideoQualitySelectorMob extends StatelessWidget {
  final void Function()? onTap;
  final String tag;

  const VideoQualitySelectorMob({
    Key? key,
    required this.onTap,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final podCtr = Get.find<PodGetXVideoController>(tag: tag);
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: podCtr.vimeoOrVideoUrls
            .map(
              (e) => ListTile(
                title: Text('${e.quality}p'),
                onTap: () {
                  onTap != null ? onTap!() : Navigator.of(context).pop();

                  podCtr.changeVideoQuality(e.quality);
                },
              ),
            )
            .toList(),
      ),
    );
  }
}

class VideoPlaybackSelectorMob extends StatelessWidget {
  final void Function()? onTap;
  final String tag;

  const VideoPlaybackSelectorMob({
    Key? key,
    required this.onTap,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final podCtr = Get.find<PodGetXVideoController>(tag: tag);
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: podCtr.videoPlaybackSpeeds
            .map(
              (e) => ListTile(
                title: Text(e),
                onTap: () {
                  onTap != null ? onTap!() : Navigator.of(context).pop();
                  podCtr.setVideoPlayBack(e);
                },
              ),
            )
            .toList(),
      ),
    );
  }
}

class MobileOverlayBottomControlles extends StatelessWidget {
  final String tag;

  const MobileOverlayBottomControlles({
    Key? key,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const durationTextStyle = TextStyle(color: Colors.white70);
    const itemColor = Colors.white;

    return GetBuilder<PodGetXVideoController>(
      tag: tag,
      id: 'full-screen',
      builder: (podCtr) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const SizedBox(width: 12),
              GetBuilder<PodGetXVideoController>(
                tag: tag,
                id: 'video-progress',
                builder: (podCtr) {
                  return Row(
                    children: [
                      Text(
                        podCtr.calculateVideoDuration(podCtr.videoPosition),
                        style: const TextStyle(color: itemColor),
                      ),
                      const Text(
                        ' / ',
                        style: durationTextStyle,
                      ),
                      Text(
                        podCtr.calculateVideoDuration(podCtr.videoDuration),
                        style: durationTextStyle,
                      ),
                    ],
                  );
                },
              ),
              const Spacer(),
              MaterialIconButton(
                toolTipMesg: podCtr.isFullScreen
                    ? podCtr.podPlayerLabels.exitFullScreen ?? 'Exit full screen${kIsWeb ? ' (f)' : ''}'
                    : podCtr.podPlayerLabels.fullscreen ?? 'Fullscreen${kIsWeb ? ' (f)' : ''}',
                color: itemColor,
                onPressed: () {
                  if (podCtr.isOverlayVisible) {
                    if (podCtr.isFullScreen) {
                      podCtr.disableFullScreen(context, tag);
                    } else {
                      podCtr.enableFullScreen(tag);
                    }
                  } else {
                    podCtr.toggleVideoOverlay();
                  }
                },
                child: Icon(
                  podCtr.isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                ),
              ),
            ],
          ),
          GetBuilder<PodGetXVideoController>(
            tag: tag,
            id: 'overlay',
            builder: (podCtr) {
              if (podCtr.isFullScreen) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                  child: Visibility(
                    visible: podCtr.isOverlayVisible,
                    child: PodProgressBar(
                      tag: tag,
                      alignment: Alignment.topCenter,
                      podProgressBarConfig: podCtr.podProgressBarConfig,
                    ),
                  ),
                );
              }
              return PodProgressBar(
                tag: tag,
                alignment: Alignment.bottomCenter,
                podProgressBarConfig: podCtr.podProgressBarConfig,
              );
            },
          ),
        ],
      ),
    );
  }
}

class XMobileOverlayBottomControlles extends StatelessWidget {
  final String tag;
  final VoidCallback? onDoubtTap;

  const XMobileOverlayBottomControlles({
    Key? key,
    this.onDoubtTap,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const durationTextStyle = TextStyle(color: Colors.white70);
    const itemColor = Colors.white;

    return GetBuilder<PodGetXVideoController>(
      tag: tag,
      id: 'full-screen',
      builder: (podCtr) => GetBuilder<PodGetXVideoController>(
        tag: tag,
        id: 'video-progress',
        builder: (podCtr) {
          return Row(
            children: [
              MaterialIconButton(
                toolTipMesg: 'Open Doubts',
                color: itemColor,
                onPressed: onDoubtTap,
                child: const Icon(
                  Icons.note,
                ),
              ),
              Text(
                podCtr.calculateVideoDuration(podCtr.videoPosition),
                style: const TextStyle(color: itemColor),
              ),
              Expanded(
                child: Visibility(
                  visible: podCtr.isOverlayVisible,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: PodProgressBar(
                      tag: tag,
                      alignment: Alignment.centerLeft,
                      podProgressBarConfig: podCtr.podProgressBarConfig,
                    ),
                  ),
                ),
              ),
              Text(
                podCtr.calculateVideoDuration(podCtr.videoDuration),
                style: durationTextStyle,
              ),
              MaterialIconButton(
                toolTipMesg: podCtr.isFullScreen
                    ? podCtr.podPlayerLabels.exitFullScreen ?? 'Exit full screen${kIsWeb ? ' (f)' : ''}'
                    : podCtr.podPlayerLabels.fullscreen ?? 'Fullscreen${kIsWeb ? ' (f)' : ''}',
                color: itemColor,
                onPressed: () {
                  if (podCtr.isOverlayVisible) {
                    if (podCtr.isFullScreen) {
                      podCtr.disableFullScreen(context, tag);
                    } else {
                      podCtr.enableFullScreen(tag);
                    }
                  } else {
                    podCtr.toggleVideoOverlay();
                  }
                },
                child: Icon(
                  podCtr.isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
