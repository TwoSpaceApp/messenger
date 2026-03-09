import 'dart:async';

import 'package:flutter/material.dart';
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
  late final DateTime _startedAt;

  _CallStage _stage = _CallStage.connecting;
  bool _recorded = false;
  bool _muted = false;
  bool _speaker = true;
  bool _cameraEnabled = true;
  bool _frontCamera = true;

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
    _recordCallIfNeeded();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = _person.displayName.isNotEmpty
      ? _person.displayName
      : l10n.userDefault;
    final isCompact = MediaQuery.sizeOf(context).width < 390;
    final sidePadding = 20.s(context);
    final controlsGap = 18.s(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ScreenBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(sidePadding),
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
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
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
                const Spacer(),
                if (widget.isVideo)
                  _VideoPreviewStack(
                    person: _person,
                    cameraEnabled: _cameraEnabled,
                    frontCamera: _frontCamera,
                  )
                else
                  PersonAvatar(
                    name: title,
                    avatarUrl: _person.avatarUrl,
                    photoBytes: _person.photoBytes,
                    radius: 56.s(context),
                    showOnline: _person.isOnline,
                  ),
                SizedBox(height: 24.s(context)),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                SizedBox(height: 10.s(context)),
                Text(
                  _statusDetail(l10n),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                ),
                const Spacer(),
                GlassCard(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.s(context),
                    vertical: 16.s(context),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: isCompact ? 10.s(context) : 18.s(context),
                    runSpacing: 14.s(context),
                    children: [
                      _CallActionButton(
                        icon: _muted ? Icons.mic_off_rounded : Icons.mic_none_rounded,
                        active: _muted,
                        label: l10n.callsMuteAction,
                        compact: isCompact,
                        onTap: () => setState(() => _muted = !_muted),
                      ),
                      _CallActionButton(
                        icon: _speaker ? Icons.volume_up_rounded : Icons.hearing_rounded,
                        active: _speaker,
                        label: l10n.callsSpeakerAction,
                        compact: isCompact,
                        onTap: () => setState(() => _speaker = !_speaker),
                      ),
                      if (widget.isVideo)
                        _CallActionButton(
                          icon: _cameraEnabled
                              ? Icons.videocam_outlined
                              : Icons.videocam_off_outlined,
                          active: _cameraEnabled,
                          label: l10n.callsCameraAction,
                          compact: isCompact,
                          onTap: () => setState(() => _cameraEnabled = !_cameraEnabled),
                        ),
                      if (widget.isVideo)
                        _CallActionButton(
                          icon: Icons.cameraswitch_outlined,
                          label: l10n.callsSwitchCameraAction,
                          compact: isCompact,
                          onTap: () => setState(() => _frontCamera = !_frontCamera),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: controlsGap),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    minimumSize: Size.fromHeight(56.s(context)),
                  ),
                  onPressed: _endCall,
                  icon: const Icon(Icons.call_end_rounded),
                  label: Text(l10n.callsEndAction),
                ),
              ],
            ),
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
    _recordCallIfNeeded();
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
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.28)
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
  });

  final PersonEntry person;
  final bool cameraEnabled;
  final bool frontCamera;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 390;
    final previewHeight = MediaQuery.sizeOf(context).height < 760
        ? 260.s(context)
        : 320.s(context);

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
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.75),
                    Colors.black.withValues(alpha: 0.5),
                  ],
                ),
              ),
              child: Center(
                child: PersonAvatar(
                  name: person.displayName,
                  avatarUrl: person.avatarUrl,
                  photoBytes: person.photoBytes,
                  radius: 48.s(context),
                  showOnline: person.isOnline,
                ),
              ),
            ),
          ),
          Positioned(
            right: 16.s(context),
            bottom: 16.s(context),
            child: Container(
              width: isCompact ? 96.s(context) : 120.s(context),
              height: isCompact ? 144.s(context) : 180.s(context),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.s(context)),
                color: Colors.black.withValues(alpha: 0.35),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Center(
                child: cameraEnabled
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            frontCamera
                                ? Icons.face_retouching_natural
                                : Icons.camera_rear_outlined,
                            color: Colors.white,
                            size: 32.s(context),
                          ),
                          SizedBox(height: 8.s(context)),
                        ],
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
}
