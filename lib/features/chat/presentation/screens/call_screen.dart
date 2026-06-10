// ignore_for_file: document_ignores

import 'dart:async';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/utils/responsive.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/features/people/data/models/person_entry.dart';
import 'package:two_space_app/features/people/data/services/call_history_service.dart';
import 'package:two_space_app/features/people/presentation/widgets/person_avatar.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({
    required this.room,
    super.key,
    this.isVideo = false,
    this.displayName,
    this.avatarUrl,
    this.person,
  });

  final String room;
  final bool isVideo;
  final String? displayName;
  final String? avatarUrl;
  final PersonEntry? person;

  @override
  State<CallScreen> createState() => _CallScreenState();
}

enum _CallStage { connecting, ringing, connected }

class _CallScreenState extends State<CallScreen> {
  final CallHistoryService _history = CallHistoryService.instance;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _statusTimer;
  Timer? _durationTicker;
  CameraController? _cameraController;
  List<CameraDescription> _availableCameras = const [];
  late final DateTime _startedAt;

  _CallStage _stage = _CallStage.connecting;
  bool _recorded = false;
  bool _muted = false;
  bool _speaker = true;
  bool _cameraEnabled = true;
  bool _frontCamera = true;
  bool _cameraInitializing = false;
  PermissionStatus _cameraPermission = PermissionStatus.denied;
  String? _cameraError;

  PersonEntry get _person {
    return widget.person ??
        PersonEntry(
          id: widget.room,
          displayName: widget.displayName ?? '',
          avatarUrl: widget.avatarUrl,
          remoteUserId: widget.room,
          isTwoSpaceUser: true,
        );
  }

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    if (widget.isVideo) {
      unawaited(_prepareCamera(requestPermission: true));
    }
    _statusTimer = Timer(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _stage = _CallStage.ringing);
      _statusTimer = Timer(const Duration(seconds: 2), () {
        if (!mounted) return;
        _stopwatch.start();
        _durationTicker = Timer.periodic(const Duration(seconds: 1), (_) {
          if (mounted) setState(() {});
        });
        setState(() => _stage = _CallStage.connected);
      });
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _durationTicker?.cancel();
    _stopwatch.stop();
    unawaited(_disposeCamera());
    // ignore: discarded_futures
    _recordCallIfNeeded();
    super.dispose();
  }

  Future<void> _prepareCamera({required bool requestPermission}) async {
    if (!widget.isVideo || kIsWeb) return;

    final platform = defaultTargetPlatform;
    if (platform != TargetPlatform.android && platform != TargetPlatform.iOS) {
      if (mounted) {
        setState(() {
          _cameraError = 'unsupported';
        });
      }
      return;
    }

    setState(() {
      _cameraInitializing = true;
      _cameraError = null;
    });

    var status = await Permission.camera.status;
    if (requestPermission && !status.isGranted) {
      status = await Permission.camera.request();
    }

    if (!mounted) return;
    if (!status.isGranted) {
      setState(() {
        _cameraPermission = status;
        _cameraInitializing = false;
      });
      return;
    }

    try {
      _availableCameras = await availableCameras();
      if (_availableCameras.isEmpty) {
        setState(() {
          _cameraPermission = status;
          _cameraInitializing = false;
          _cameraError = 'unavailable';
        });
        return;
      }

      final preferredLens = _frontCamera
          ? CameraLensDirection.front
          : CameraLensDirection.back;
      final selectedCamera = _availableCameras.firstWhere(
        (camera) => camera.lensDirection == preferredLens,
        orElse: () => _availableCameras.first,
      );

      await _startCamera(selectedCamera, status);
    } catch (_) {
      if (mounted) {
        setState(() {
          _cameraPermission = status;
          _cameraInitializing = false;
          _cameraError = 'unavailable';
        });
      }
    }
  }

  Future<void> _startCamera(
    CameraDescription description,
    PermissionStatus status,
  ) async {
    await _disposeCamera();

    final controller = CameraController(
      description,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await controller.initialize();

    if (!mounted) {
      await controller.dispose();
      return;
    }

    setState(() {
      _cameraController = controller;
      _cameraPermission = status;
      _cameraInitializing = false;
      _cameraError = null;
    });
  }

  Future<void> _disposeCamera() async {
    final controller = _cameraController;
    _cameraController = null;
    if (controller != null) {
      await controller.dispose();
    }
  }

  Future<void> _toggleCameraEnabled() async {
    final next = !_cameraEnabled;
    setState(() => _cameraEnabled = next);
    if (next && _cameraController == null) {
      await _prepareCamera(requestPermission: true);
    }
  }

  Future<void> _switchCamera() async {
    if (_availableCameras.length < 2) return;
    setState(() => _frontCamera = !_frontCamera);
    await _prepareCamera(requestPermission: false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = _person.displayName.isNotEmpty
        ? _person.displayName
        : l10n.userDefault;
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 390;
    final isTablet = width >= UITokens.tabletBreakpoint;
    final isDesktop = width >= UITokens.desktopBreakpoint;
    final sidePadding = 20.s(context);
    final controlsGap = 18.s(context);
    final contentMaxWidth = isDesktop
        ? 880.0
        : (isTablet ? 720.0 : double.infinity);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ScreenBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(sidePadding),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                      maxWidth: contentMaxWidth,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: _endCall,
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.white,
                                size: 28.s(context),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    widget.isVideo
                                        ? l10n.videoCallLabel
                                        : l10n.voiceCallLabel,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: Colors.white70,
                                          fontSize: 14.s(context),
                                        ),
                                  ),
                                  SizedBox(height: 4.s(context)),
                                  Text(
                                    _statusLabel(l10n),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Colors.white60,
                                          fontSize: 12.s(context),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 48.s(context)),
                          ],
                        ),
                        SizedBox(height: 16.s(context)),
                        _DemoBanner(
                          title: l10n.callsDemoBannerTitle,
                          message: widget.isVideo
                              ? l10n.callsDemoBannerVideoMessage
                              : l10n.callsDemoBannerVoiceMessage,
                        ),
                        SizedBox(height: 22.s(context)),
                        if (widget.isVideo)
                          _VideoPreviewStack(
                            person: _person,
                            cameraEnabled: _cameraEnabled,
                            frontCamera: _frontCamera,
                            controller: _cameraController,
                            initializing: _cameraInitializing,
                            permission: _cameraPermission,
                            errorCode: _cameraError,
                            onRequestPermission: () =>
                                _prepareCamera(requestPermission: true),
                          )
                        else
                          Padding(
                            padding: EdgeInsets.only(top: 12.s(context)),
                            child: PersonAvatar(
                              name: title,
                              avatarUrl: _person.avatarUrl,
                              photoBytes: _person.photoBytes,
                              radius: 56.s(context),
                              showOnline: _person.isOnline,
                            ),
                          ),
                        SizedBox(height: 24.s(context)),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        SizedBox(height: 10.s(context)),
                        Text(
                          _statusDetail(l10n),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                        ),
                        SizedBox(height: 24.s(context)),
                        GlassCard(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.s(context),
                            vertical: 16.s(context),
                          ),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: (isCompact ? 10 : (isTablet ? 14 : 18)).s(
                              context,
                            ),
                            runSpacing: 14.s(context),
                            children: [
                              _CallActionButton(
                                icon: _muted
                                    ? Icons.mic_off_rounded
                                    : Icons.mic_none_rounded,
                                active: _muted,
                                label: l10n.callsMuteAction,
                                compact: isCompact,
                                onTap: () => setState(() => _muted = !_muted),
                              ),
                              _CallActionButton(
                                icon: _speaker
                                    ? Icons.volume_up_rounded
                                    : Icons.hearing_rounded,
                                active: _speaker,
                                label: l10n.callsSpeakerAction,
                                compact: isCompact,
                                onTap: () =>
                                    setState(() => _speaker = !_speaker),
                              ),
                              if (widget.isVideo)
                                _CallActionButton(
                                  icon: _cameraEnabled
                                      ? Icons.videocam_outlined
                                      : Icons.videocam_off_outlined,
                                  active: _cameraEnabled,
                                  label: l10n.callsCameraAction,
                                  compact: isCompact,
                                  onTap: _toggleCameraEnabled,
                                ),
                              if (widget.isVideo)
                                _CallActionButton(
                                  icon: Icons.cameraswitch_outlined,
                                  label: l10n.callsSwitchCameraAction,
                                  compact: isCompact,
                                  onTap: _switchCamera,
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: controlsGap),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            minimumSize: Size(double.infinity, 56.s(context)),
                          ),
                          onPressed: _endCall,
                          icon: const Icon(Icons.call_end_rounded),
                          label: Text(l10n.callsEndAction),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n) {
    switch (_stage) {
      case _CallStage.connecting:
        return l10n.callsConnectingLabel;
      case _CallStage.ringing:
        return l10n.callsRingingLabel;
      case _CallStage.connected:
        return _formatDuration(_stopwatch.elapsed);
    }
  }

  String _statusDetail(AppLocalizations l10n) {
    switch (_stage) {
      case _CallStage.connecting:
        return l10n.callsConnectingDetail;
      case _CallStage.ringing:
        return l10n.callsRingingDetail;
      case _CallStage.connected:
        return widget.isVideo
            ? l10n.callsVideoSecureDetail
            : l10n.callsVoiceSecureDetail;
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${duration.inMinutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _endCall() async {
    await _recordCallIfNeeded();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _recordCallIfNeeded() async {
    if (_recorded) return;
    _recorded = true;
    final connected = _stage == _CallStage.connected;
    await _history.recordOutgoingCall(
      person: _person,
      isVideo: widget.isVideo,
      startedAt: _startedAt,
      duration: connected ? _stopwatch.elapsed : Duration.zero,
      connected: connected,
    );
  }
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.symmetric(
        horizontal: 14.s(context),
        vertical: 12.s(context),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34.s(context),
            height: 34.s(context),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12.s(context)),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Colors.amber,
            ),
          ),
          SizedBox(width: 12.s(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.s(context)),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CallActionButton extends StatelessWidget {
  const _CallActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkResponse(
          onTap: onTap,
          radius: 28.s(context),
          child: Container(
            width: 52.s(context),
            height: 52.s(context),
            decoration: BoxDecoration(
              color: active
                  ? Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.28)
                  : Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 22.s(context)),
          ),
        ),
        SizedBox(height: 6.s(context)),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: compact ? 2 : 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class _VideoPreviewStack extends StatelessWidget {
  const _VideoPreviewStack({
    required this.person,
    required this.cameraEnabled,
    required this.frontCamera,
    required this.controller,
    required this.initializing,
    required this.permission,
    required this.onRequestPermission,
    this.errorCode,
  });

  final PersonEntry person;
  final bool cameraEnabled;
  final bool frontCamera;
  final CameraController? controller;
  final bool initializing;
  final PermissionStatus permission;
  final String? errorCode;
  final Future<void> Function() onRequestPermission;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    final isCompact = width < 390;
    final isTablet = width >= UITokens.tabletBreakpoint;
    final isDesktop = width >= UITokens.desktopBreakpoint;
    final previewHeight = isDesktop
        ? math.min(height * 0.48, 420).toDouble()
        : isTablet
        ? math.min(height * 0.44, 380).toDouble()
        : (height < 760 ? 260.s(context) : 320.s(context));

    return SizedBox(
      height: previewHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32.s(context)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.75),
                    Colors.black.withValues(alpha: 0.5),
                  ],
                ),
              ),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32.s(context)),
                  child: _buildMainPreview(context, l10n),
                ),
              ),
            ),
          ),
          Positioned(
            right: 16.s(context),
            bottom: 16.s(context),
            child: Container(
              width: isDesktop
                  ? 150.s(context)
                  : (isTablet
                        ? 132.s(context)
                        : (isCompact ? 96.s(context) : 120.s(context))),
              height: isDesktop
                  ? 210.s(context)
                  : (isTablet
                        ? 196.s(context)
                        : (isCompact ? 144.s(context) : 180.s(context))),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.s(context)),
                color: Colors.black.withValues(alpha: 0.35),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Center(
                child:
                    cameraEnabled &&
                        controller != null &&
                        controller!.value.isInitialized
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(24.s(context)),
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..rotateY(frontCamera ? 3.1415926535897932 : 0),
                          child: AspectRatio(
                            aspectRatio: controller!.value.aspectRatio,
                            child: CameraPreview(controller!),
                          ),
                        ),
                      )
                    : Icon(
                        Icons.videocam_off_outlined,
                        color: Colors.white70,
                        size: 32.s(context),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainPreview(BuildContext context, AppLocalizations l10n) {
    if (!cameraEnabled) {
      return _buildFallbackCard(
        context,
        icon: Icons.videocam_off_outlined,
        title: l10n.callsCameraAction,
        subtitle: l10n.callsCameraOffMessage,
      );
    }

    if (initializing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (permission.isDenied || permission.isRestricted) {
      return _buildPermissionCard(
        context,
        l10n.callsCameraPermissionMessage,
        l10n.callsCameraPermissionAction,
      );
    }

    if (permission.isPermanentlyDenied) {
      return _buildPermissionCard(
        context,
        l10n.callsCameraPermissionSettingsMessage,
        l10n.openSettingsButton,
        openSettings: true,
      );
    }

    if (controller != null && controller!.value.isInitialized) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..rotateY(frontCamera ? 3.1415926535897932 : 0),
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller!.value.previewSize?.height ?? 1,
                height: controller!.value.previewSize?.width ?? 1,
                child: CameraPreview(controller!),
              ),
            ),
          ),
          Positioned(
            left: 18.s(context),
            top: 18.s(context),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10.s(context),
                vertical: 6.s(context),
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(UITokens.cornerPill),
              ),
              child: Text(
                frontCamera
                    ? l10n.callsFrontCameraLabel
                    : l10n.callsRearCameraLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return _buildFallbackCard(
      context,
      icon: Icons.camera_alt_outlined,
      title: l10n.callsCameraUnavailableTitle,
      subtitle: errorCode == 'unsupported'
          ? l10n.callsCameraUnsupportedMessage
          : l10n.callsCameraUnavailableMessage,
    );
  }

  Widget _buildPermissionCard(
    BuildContext context,
    String message,
    String actionLabel, {
    bool openSettings = false,
  }) {
    return Padding(
      padding: EdgeInsets.all(20.s(context)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            color: Colors.white,
            size: 40.s(context),
          ),
          SizedBox(height: 12.s(context)),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              height: 1.45,
            ),
          ),
          SizedBox(height: 14.s(context)),
          FilledButton(
            onPressed: () async {
              if (openSettings) {
                await openAppSettings();
                return;
              }
              await onRequestPermission();
            },
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.75),
            Colors.black.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(20.s(context)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PersonAvatar(
                name: person.displayName,
                avatarUrl: person.avatarUrl,
                photoBytes: person.photoBytes,
                radius: 44.s(context),
                showOnline: person.isOnline,
              ),
              SizedBox(height: 16.s(context)),
              Icon(icon, color: Colors.white, size: 30.s(context)),
              SizedBox(height: 12.s(context)),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 6.s(context)),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
