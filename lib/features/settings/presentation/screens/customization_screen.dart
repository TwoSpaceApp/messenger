// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:go_router/go_router.dart';
import 'package:two_space_app/core/config/app_colors.dart';
import 'package:two_space_app/core/config/theme_builder.dart';
import 'package:two_space_app/core/config/theme_options.dart';
import 'package:two_space_app/core/constants/app_strings.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';
import 'package:two_space_app/core/widgets/section_page_header.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';
import 'package:two_space_app/features/settings/presentation/widgets/settings_showcase.dart';

enum _PreviewSurface { rooms, conversation, settings }

TextStyle? _fontPreviewStyle(
  TextStyle? baseStyle,
  String fontFamily, {
  FontWeight? fontWeight,
}) {
  return AppThemeBuilder.applyFontFamily(
    fontFamily,
    textStyle: (baseStyle ?? const TextStyle()).copyWith(
      fontWeight: fontWeight,
    ),
  );
}

class _ThemePreset {
  const _ThemePreset({
    required this.id,
    required this.color,
    required this.themeMode,
    required this.fontFamily,
    required this.fontWeight,
    required this.enableFloatingCircles,
    required this.backgroundMotionMode,
    required this.enableParallax,
    required this.floatingCirclesSpeed,
    required this.floatingCirclesOpacity,
    required this.compactMode,
    required this.dynamicBubbles,
    required this.bubbleRounding,
    required this.navBarHideTimeoutSeconds,
    required this.textScale,
  });

  final String id;
  final int color;
  final ThemeMode themeMode;
  final String fontFamily;
  final int fontWeight;
  final bool enableFloatingCircles;
  final BackgroundMotionMode backgroundMotionMode;
  final bool enableParallax;
  final double floatingCirclesSpeed;
  final double floatingCirclesOpacity;
  final bool compactMode;
  final bool dynamicBubbles;
  final double bubbleRounding;
  final int navBarHideTimeoutSeconds;
  final double textScale;
}

class CustomizationScreen extends StatefulWidget {
  const CustomizationScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<CustomizationScreen> createState() => _CustomizationScreenState();
}

class _CustomizationScreenState extends State<CustomizationScreen> {
  static const List<_ThemePreset> _presets = [
    _ThemePreset(
      id: 'quietGlass',
      color: 0xFF5263FF,
      themeMode: ThemeMode.system,
      fontFamily: 'Inter',
      fontWeight: 500,
      enableFloatingCircles: true,
      backgroundMotionMode: BackgroundMotionMode.circles,
      enableParallax: true,
      floatingCirclesSpeed: 0.9,
      floatingCirclesOpacity: 0.38,
      compactMode: false,
      dynamicBubbles: true,
      bubbleRounding: 18,
      navBarHideTimeoutSeconds: 3,
      textScale: 1,
    ),
    _ThemePreset(
      id: 'nightSignal',
      color: 0xFF651FFF,
      themeMode: ThemeMode.dark,
      fontFamily: 'Oswald',
      fontWeight: 600,
      enableFloatingCircles: true,
      backgroundMotionMode: BackgroundMotionMode.circles,
      enableParallax: true,
      floatingCirclesSpeed: 1.2,
      floatingCirclesOpacity: 0.62,
      compactMode: true,
      dynamicBubbles: true,
      bubbleRounding: 16,
      navBarHideTimeoutSeconds: 2,
      textScale: 0.96,
    ),
    _ThemePreset(
      id: 'editorial',
      color: 0xFF5C6B73,
      themeMode: ThemeMode.light,
      fontFamily: 'OpenSans',
      fontWeight: 400,
      enableFloatingCircles: true,
      backgroundMotionMode: BackgroundMotionMode.waves,
      enableParallax: false,
      floatingCirclesSpeed: 0.6,
      floatingCirclesOpacity: 0.24,
      compactMode: false,
      dynamicBubbles: false,
      bubbleRounding: 14,
      navBarHideTimeoutSeconds: 4,
      textScale: 1.02,
    ),
    _ThemePreset(
      id: 'solarFlare',
      color: 0xFFFFB300,
      themeMode: ThemeMode.light,
      fontFamily: 'Roboto',
      fontWeight: 600,
      enableFloatingCircles: true,
      backgroundMotionMode: BackgroundMotionMode.waves,
      enableParallax: true,
      floatingCirclesSpeed: 1.35,
      floatingCirclesOpacity: 0.46,
      compactMode: false,
      dynamicBubbles: true,
      bubbleRounding: 22,
      navBarHideTimeoutSeconds: 3,
      textScale: 1,
    ),
    _ThemePreset(
      id: 'retroPulse',
      color: 0xFFE2558F,
      themeMode: ThemeMode.dark,
      fontFamily: 'Handjet',
      fontWeight: 700,
      enableFloatingCircles: true,
      backgroundMotionMode: BackgroundMotionMode.circles,
      enableParallax: false,
      floatingCirclesSpeed: 1.1,
      floatingCirclesOpacity: 0.42,
      compactMode: true,
      dynamicBubbles: false,
      bubbleRounding: 10,
      navBarHideTimeoutSeconds: 1,
      textScale: 0.92,
    ),
  ];

  final List<Map<String, dynamic>> _colorChoices = ThemeOptions.colors;
  final List<String> _fontChoices = ThemeOptions.fonts;

  late int _selectedColor;
  late String _selectedFont;
  late int _selectedWeight;
  late double _fontSize;
  late ThemeMode _selectedThemeMode;
  late bool _compactMode;
  late bool _dynamicBubbles;
  late double _bubbleRounding;
  late int _navBarHideTimeoutSeconds;
  late bool _enableFloatingCircles;
  late BackgroundMotionMode _backgroundMotionMode;
  late double _floatingCirclesSpeed;
  late double _floatingCirclesOpacity;
  late bool _enableParallax;

  _PreviewSurface _previewSurface = _PreviewSurface.rooms;

  @override
  void initState() {
    super.initState();
    final settings = SettingsService.themeNotifier.value;
    _selectedColor = settings.primaryColorValue;
    _selectedFont = settings.fontFamily;
    _selectedWeight = SettingsService.normalizeFontWeight(settings.fontWeight);
    _fontSize = (SettingsService.textScaleNotifier.value * 14).clamp(12, 20);
    _selectedThemeMode = SettingsService.themeModeNotifier.value;
    _compactMode = settings.compactMode;
    _dynamicBubbles = settings.dynamicBubbles;
    _bubbleRounding = settings.bubbleRounding;
    _navBarHideTimeoutSeconds = settings.navBarHideTimeoutSeconds;
    _enableFloatingCircles = settings.enableFloatingCircles;
    _backgroundMotionMode = settings.backgroundMotionMode;
    _floatingCirclesSpeed = settings.floatingCirclesSpeed;
    _floatingCirclesOpacity = settings.floatingCirclesOpacity;
    _enableParallax = settings.enableParallax;
  }

  FontWeight _resolveFontWeight(int weight) {
    switch (SettingsService.normalizeFontWeight(weight)) {
      case 300:
        return FontWeight.w300;
      case 400:
        return FontWeight.w400;
      case 500:
        return FontWeight.w500;
      case 600:
        return FontWeight.w600;
      case 700:
        return FontWeight.w700;
      case 800:
        return FontWeight.w800;
      case 900:
        return FontWeight.w900;
      default:
        return FontWeight.w400;
    }
  }

  ThemeData _previewTheme() {
    final tempSettings = SettingsService.themeNotifier.value.copyWith(
      primaryColorValue: _selectedColor,
      fontFamily: _selectedFont,
      fontWeight: _selectedWeight,
      compactMode: _compactMode,
      dynamicBubbles: _dynamicBubbles,
      bubbleRounding: _bubbleRounding,
      navBarHideTimeoutSeconds: _navBarHideTimeoutSeconds,
      enableFloatingCircles: _enableFloatingCircles,
      backgroundMotionMode: _backgroundMotionMode,
      floatingCirclesSpeed: _floatingCirclesSpeed,
      floatingCirclesOpacity: _floatingCirclesOpacity,
      enableParallax: _enableParallax,
    );

    final brightness = switch (_selectedThemeMode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => Theme.of(context).brightness,
    };

    return AppThemeBuilder.buildMaterial(
      tempSettings,
      _selectedColor == 0xFFE8D7FF,
      brightnessOverride: brightness,
    );
  }

  Future<void> _applyThemeUpdate({
    int? color,
    String? fontFamily,
    int? fontWeight,
    ThemeMode? themeMode,
    bool? compactMode,
    bool? dynamicBubbles,
    double? bubbleRounding,
    int? navBarHideTimeoutSeconds,
    bool? enableFloatingCircles,
    BackgroundMotionMode? backgroundMotionMode,
    double? floatingCirclesSpeed,
    double? floatingCirclesOpacity,
    bool? enableParallax,
    double? textScale,
  }) async {
    await SettingsService.updateTheme(
      primaryColorValue: color,
      fontFamily: fontFamily,
      fontWeight: fontWeight,
      compactMode: compactMode,
      dynamicBubbles: dynamicBubbles,
      bubbleRounding: bubbleRounding,
      navBarHideTimeoutSeconds: navBarHideTimeoutSeconds,
      enableFloatingCircles: enableFloatingCircles,
      backgroundMotionMode: backgroundMotionMode,
      floatingCirclesSpeed: floatingCirclesSpeed,
      floatingCirclesOpacity: floatingCirclesOpacity,
      enableParallax: enableParallax,
    );
    if (themeMode != null) {
      await SettingsService.setThemeMode(themeMode);
    }
    if (textScale != null) {
      await SettingsService.setTextScale(textScale);
    }
    if (color != null) {
      await SettingsService.setPaleVioletMode(color == 0xFFE8D7FF);
    }
  }

  Future<void> _applyPreset(_ThemePreset preset) async {
    setState(() {
      _selectedColor = preset.color;
      _selectedFont = preset.fontFamily;
      _selectedWeight = preset.fontWeight;
      _fontSize = (preset.textScale * 14).clamp(12, 20);
      _selectedThemeMode = preset.themeMode;
      _compactMode = preset.compactMode;
      _dynamicBubbles = preset.dynamicBubbles;
      _bubbleRounding = preset.bubbleRounding;
      _navBarHideTimeoutSeconds = preset.navBarHideTimeoutSeconds;
      _enableFloatingCircles = preset.enableFloatingCircles;
      _backgroundMotionMode = preset.backgroundMotionMode;
      _floatingCirclesSpeed = preset.floatingCirclesSpeed;
      _floatingCirclesOpacity = preset.floatingCirclesOpacity;
      _enableParallax = preset.enableParallax;
    });

    await _applyThemeUpdate(
      color: preset.color,
      fontFamily: preset.fontFamily,
      fontWeight: preset.fontWeight,
      themeMode: preset.themeMode,
      compactMode: preset.compactMode,
      dynamicBubbles: preset.dynamicBubbles,
      bubbleRounding: preset.bubbleRounding,
      navBarHideTimeoutSeconds: preset.navBarHideTimeoutSeconds,
      enableFloatingCircles: preset.enableFloatingCircles,
      backgroundMotionMode: preset.backgroundMotionMode,
      floatingCirclesSpeed: preset.floatingCirclesSpeed,
      floatingCirclesOpacity: preset.floatingCirclesOpacity,
      enableParallax: preset.enableParallax,
      textScale: preset.textScale,
    );
  }

  void _closeScreen() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppStrings.routeHome);
  }

  bool _isLightColor(int color) {
    return const {
      0xFF03A9F4,
      0xFF8BC34A,
      0xFFE8D7FF,
      0xFFFFB300,
      0xFF00C7B1,
    }.contains(color);
  }

  String _colorLabel(AppLocalizations l10n, int color) {
    switch (color) {
      case 0xFF651FFF:
        return l10n.themeColorAegisViolet;
      case 0xFF5263FF:
        return l10n.themeColorIndigoSignal;
      case 0xFF7C4DFF:
        return l10n.themeColorAmethyst;
      case 0xFFE2558F:
        return l10n.themeColorRosePulse;
      case 0xFFFFB300:
        return l10n.themeColorSolarAmber;
      case 0xFFE8D7FF:
        return l10n.themeColorPaleViolet;
      case 0xFFFF7043:
        return l10n.themeColorSignalCoral;
      case 0xFF15B097:
        return l10n.themeColorMintRelay;
      case 0xFF03A9F4:
        return l10n.themeColorCyanAir;
      case 0xFF8BC34A:
        return l10n.themeColorLimeCurrent;
      case 0xFF5C6B73:
        return l10n.themeColorSlateMono;
      case 0xFF00C7B1:
        return l10n.themeColorAuroraMint;
      default:
        return l10n.colorThemeLabel;
    }
  }

  String _themeModeLabel(AppLocalizations l10n, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.themeLight;
      case ThemeMode.dark:
        return l10n.themeDark;
      case ThemeMode.system:
        return l10n.themeSystem;
    }
  }

  String _presetTitle(AppLocalizations l10n, String id) {
    switch (id) {
      case 'quietGlass':
        return l10n.presetQuietGlass;
      case 'nightSignal':
        return l10n.presetNightSignal;
      case 'editorial':
        return l10n.presetEditorial;
      case 'solarFlare':
        return l10n.presetSolarFlare;
      case 'retroPulse':
        return l10n.presetRetroPulse;
      default:
        return l10n.customizationTitle;
    }
  }

  String _presetSubtitle(AppLocalizations l10n, String id) {
    switch (id) {
      case 'quietGlass':
        return l10n.presetQuietGlassSubtitle;
      case 'nightSignal':
        return l10n.presetNightSignalSubtitle;
      case 'editorial':
        return l10n.presetEditorialSubtitle;
      case 'solarFlare':
        return l10n.presetSolarFlareSubtitle;
      case 'retroPulse':
        return l10n.presetRetroPulseSubtitle;
      default:
        return l10n.themeAppliesEverywhere;
    }
  }

  String _previewSurfaceLabel(AppLocalizations l10n, _PreviewSurface surface) {
    switch (surface) {
      case _PreviewSurface.rooms:
        return l10n.previewRoomsLabel;
      case _PreviewSurface.conversation:
        return l10n.previewConversationLabel;
      case _PreviewSurface.settings:
        return l10n.previewSettingsLabel;
    }
  }

  Widget _buildPreviewSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: _PreviewSurface.values.map((surface) {
        final selected = _previewSurface == surface;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: surface == _PreviewSurface.settings ? 0 : 8,
            ),
            child: _SegmentChoiceCard(
              label: _previewSurfaceLabel(l10n, surface),
              icon: switch (surface) {
                _PreviewSurface.rooms => Icons.view_list_rounded,
                _PreviewSurface.conversation => Icons.chat_bubble_rounded,
                _PreviewSurface.settings => Icons.tune_rounded,
              },
              selected: selected,
              onTap: () {
                setState(() => _previewSurface = surface);
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMotionModeSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: _SegmentChoiceCard(
            label: l10n.motionModeCircles,
            caption: l10n.motionModeCirclesSubtitle,
            icon: Icons.blur_on_rounded,
            selected: _backgroundMotionMode == BackgroundMotionMode.circles,
            onTap: _enableFloatingCircles
                ? () async {
                    setState(() {
                      _backgroundMotionMode = BackgroundMotionMode.circles;
                    });
                    await _applyThemeUpdate(
                      backgroundMotionMode: BackgroundMotionMode.circles,
                    );
                  }
                : null,
          ),
        ),
        const SizedBox(width: UITokens.spaceSmMd),
        Expanded(
          child: _SegmentChoiceCard(
            label: l10n.motionModeWaves,
            caption: l10n.motionModeWavesSubtitle,
            icon: Icons.water_rounded,
            selected: _backgroundMotionMode == BackgroundMotionMode.waves,
            onTap: _enableFloatingCircles
                ? () async {
                    setState(() {
                      _backgroundMotionMode = BackgroundMotionMode.waves;
                    });
                    await _applyThemeUpdate(
                      backgroundMotionMode: BackgroundMotionMode.waves,
                    );
                  }
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewShell(BuildContext context) {
    final previewTheme = _previewTheme();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPreviewSelector(context),
        const SizedBox(height: UITokens.spaceMdLg),
        ClipRRect(
          borderRadius: BorderRadius.circular(UITokens.cornerXL),
          child: Theme(
            data: previewTheme,
            child: Container(
              height: 328,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    previewTheme.colorScheme.surface,
                    previewTheme.colorScheme.surfaceContainer.withValues(
                      alpha: 0.9,
                    ),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: AnimatedSwitcher(
                duration: UITokens.durationMd,
                child: SizedBox.expand(
                  child: switch (_previewSurface) {
                    _PreviewSurface.rooms => _PreviewRoomsCard(
                      key: const ValueKey('rooms'),
                      bubbleRounding: _bubbleRounding,
                      compactMode: _compactMode,
                    ),
                    _PreviewSurface.conversation => _PreviewConversationCard(
                      key: const ValueKey('conversation'),
                      bubbleRounding: _bubbleRounding,
                      dynamicBubbles: _dynamicBubbles,
                      compactMode: _compactMode,
                    ),
                    _PreviewSurface.settings => _PreviewSettingsCard(
                      key: const ValueKey('settings'),
                      compactMode: _compactMode,
                    ),
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: widget.embedded
          ? SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  MediaQuery.of(context).padding.bottom + 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionPageHeader(
                      title: l10n.customizationTitle,
                      subtitle: l10n.customizationHeroSubtitle,
                      leading: IconButton(
                        onPressed: _closeScreen,
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                    ),
                    const SizedBox(height: UITokens.space),
                    _buildScreenBody(context, theme, l10n),
                  ],
                ),
              ),
            )
          : ScreenBackground(
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    12,
                    16,
                    MediaQuery.of(context).padding.bottom + 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: _closeScreen,
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const SizedBox(width: UITokens.spaceXS),
                          Expanded(
                            child: Text(
                              l10n.customizationTitle,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: UITokens.space),
                      _buildScreenBody(context, theme, l10n),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildScreenBody(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsHeroCard(
          icon: Icons.auto_awesome_rounded,
          title: l10n.customizationHeroTitle,
          subtitle: l10n.customizationHeroSubtitle,
          child: _buildPreviewShell(context),
        ),
        const SizedBox(height: UITokens.space2XL),
        SettingsSectionHeader(
          title: l10n.stylePresetsTitle,
          subtitle: l10n.stylePresetsSubtitle,
        ),
        const SizedBox(height: UITokens.spaceMdSm),
        SizedBox(
          height: 204,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _presets.length,
            separatorBuilder: (_, __) => const SizedBox(width: UITokens.space),
            itemBuilder: (context, index) {
              final preset = _presets[index];
              final selected =
                  preset.color == _selectedColor &&
                  preset.themeMode == _selectedThemeMode &&
                  preset.fontFamily == _selectedFont &&
                  preset.fontWeight == _selectedWeight &&
                  preset.backgroundMotionMode == _backgroundMotionMode;
              return _PresetCard(
                title: _presetTitle(l10n, preset.id),
                subtitle: _presetSubtitle(l10n, preset.id),
                color: Color(preset.color),
                fontFamily: preset.fontFamily,
                themeModeLabel: _themeModeLabel(l10n, preset.themeMode),
                selected: selected,
                onTap: () => _applyPreset(preset),
              );
            },
          ),
        ),
        const SizedBox(height: UITokens.space2XL),
        SettingsSectionHeader(
          title: l10n.moodSectionTitle,
          subtitle: l10n.moodSectionSubtitle,
        ),
        const SizedBox(height: UITokens.spaceMdSm),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth < 380 ? 1 : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _colorChoices.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisExtent: 112,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final colorValue = _colorChoices[index]['value'] as int;
                final selected = colorValue == _selectedColor;
                return _ColorChoiceCard(
                  label: _colorLabel(l10n, colorValue),
                  toneLabel: _isLightColor(colorValue)
                      ? l10n.themeLight
                      : l10n.themeDark,
                  color: Color(colorValue),
                  selected: selected,
                  onTap: () async {
                    setState(() => _selectedColor = colorValue);
                    await _applyThemeUpdate(color: colorValue);
                  },
                );
              },
            );
          },
        ),
        const SizedBox(height: UITokens.space2XL),
        SettingsSectionHeader(
          title: l10n.typeSectionTitle,
          subtitle: l10n.typeSectionSubtitle,
        ),
        const SizedBox(height: UITokens.spaceMdSm),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _fontChoices.map((font) {
            final selected = font == _selectedFont;
            return _FontChoiceCard(
              fontFamily: font,
              selected: selected,
              previewWeight: _resolveFontWeight(_selectedWeight),
              onTap: () async {
                setState(() => _selectedFont = font);
                await _applyThemeUpdate(fontFamily: font);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: UITokens.spaceMdSm),
        GlassCard(
          child: Column(
            children: [
              _SliderSettingTile(
                title: l10n.fontWeightLabel,
                valueLabel: '$_selectedWeight',
                icon: Icons.format_bold_rounded,
                min: 300,
                max: 900,
                divisions: 6,
                value: _selectedWeight.toDouble(),
                onChanged: (value) {
                  setState(() => _selectedWeight = value.round());
                },
                onChangeEnd: (value) async {
                  await _applyThemeUpdate(fontWeight: value.round());
                },
              ),
              const SizedBox(height: UITokens.spaceSmMd),
              _SliderSettingTile(
                title: l10n.textSizeLabel,
                valueLabel: '${_fontSize.toStringAsFixed(0)} pt',
                icon: Icons.format_size_rounded,
                min: 12,
                max: 20,
                divisions: 8,
                value: _fontSize,
                onChanged: (value) {
                  setState(() => _fontSize = value);
                },
                onChangeEnd: (value) async {
                  await _applyThemeUpdate(textScale: value / 14);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: UITokens.space2XL),
        SettingsSectionHeader(
          title: l10n.motionSectionTitle,
          subtitle: l10n.motionSectionSubtitle,
        ),
        const SizedBox(height: UITokens.spaceMdSm),
        GlassCard(
          child: Column(
            children: [
              SwitchListTile(
                value: _enableFloatingCircles,
                onChanged: (value) async {
                  setState(() => _enableFloatingCircles = value);
                  await _applyThemeUpdate(enableFloatingCircles: value);
                },
                secondary: const Icon(Icons.blur_on_rounded),
                title: Text(l10n.backgroundMotionToggleLabel),
                subtitle: Text(
                  _enableFloatingCircles
                      ? l10n.backgroundMotionOnSubtitle
                      : l10n.backgroundMotionOffSubtitle,
                ),
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(height: UITokens.borderThin),
              SwitchListTile(
                value: _enableParallax,
                onChanged: _enableFloatingCircles
                    ? (value) async {
                        setState(() => _enableParallax = value);
                        await _applyThemeUpdate(enableParallax: value);
                      }
                    : null,
                secondary: const Icon(Icons.sensors_rounded),
                title: Text(l10n.parallaxEffect),
                subtitle: Text(
                  _enableParallax ? l10n.reactOnTilt : l10n.staticMotion,
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        const SizedBox(height: UITokens.spaceMdSm),
        _buildMotionModeSelector(context),
        const SizedBox(height: UITokens.spaceMdSm),
        GlassCard(
          child: Column(
            children: [
              _SliderSettingTile(
                title: l10n.circlesSpeedLabel,
                valueLabel: '${(_floatingCirclesSpeed * 100).round()}%',
                icon: Icons.speed_rounded,
                min: 0.2,
                max: 2,
                divisions: 18,
                value: _floatingCirclesSpeed,
                enabled: _enableFloatingCircles,
                onChanged: (value) {
                  setState(() => _floatingCirclesSpeed = value);
                },
                onChangeEnd: (value) async {
                  await _applyThemeUpdate(
                    floatingCirclesSpeed: value,
                  );
                },
                startLabel: l10n.speedSlow,
                endLabel: l10n.speedFast,
              ),
              const SizedBox(height: UITokens.spaceSmMd),
              _SliderSettingTile(
                title: l10n.brightnessLabel,
                valueLabel: '${(_floatingCirclesOpacity * 100).round()}%',
                icon: Icons.blur_circular_rounded,
                min: 0.1,
                max: 1,
                divisions: 9,
                value: _floatingCirclesOpacity,
                enabled: _enableFloatingCircles,
                onChanged: (value) {
                  setState(() => _floatingCirclesOpacity = value);
                },
                onChangeEnd: (value) async {
                  await _applyThemeUpdate(
                    floatingCirclesOpacity: value,
                  );
                },
                startLabel: l10n.dimOpacity,
                endLabel: l10n.brightOpacity,
              ),
            ],
          ),
        ),
        const SizedBox(height: UITokens.space2XL),
        SettingsSectionHeader(
          title: l10n.densitySectionTitle,
          subtitle: l10n.densitySectionSubtitle,
        ),
        const SizedBox(height: UITokens.spaceMdSm),
        GlassCard(
          child: Column(
            children: [
              SwitchListTile(
                value: _compactMode,
                onChanged: (value) async {
                  setState(() => _compactMode = value);
                  await _applyThemeUpdate(compactMode: value);
                },
                secondary: const Icon(Icons.compress_rounded),
                title: Text(l10n.compactModeLabel),
                subtitle: Text(l10n.compactMode),
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(height: UITokens.borderThin),
              SwitchListTile(
                value: _dynamicBubbles,
                onChanged: (value) async {
                  setState(() => _dynamicBubbles = value);
                  await _applyThemeUpdate(dynamicBubbles: value);
                },
                secondary: const Icon(Icons.forum_rounded),
                title: Text(l10n.dynamicBubblesLabel),
                subtitle: Text(l10n.dynamicBubblesSubtitle),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        const SizedBox(height: UITokens.spaceMdSm),
        GlassCard(
          child: Column(
            children: [
              _SliderSettingTile(
                title: l10n.bubbleRoundingLabel,
                valueLabel: _bubbleRounding.toStringAsFixed(0),
                icon: Icons.rounded_corner_rounded,
                min: 8,
                max: 28,
                divisions: 10,
                value: _bubbleRounding,
                onChanged: (value) {
                  setState(() => _bubbleRounding = value);
                },
                onChangeEnd: (value) async {
                  await _applyThemeUpdate(bubbleRounding: value);
                },
                startLabel: l10n.bubbleRoundingCompact,
                endLabel: l10n.bubbleRoundingSoft,
              ),
              const SizedBox(height: UITokens.spaceSmMd),
              _SliderSettingTile(
                title: l10n.navBarTimeoutLabel,
                valueLabel: l10n.navBarTimeoutValue(_navBarHideTimeoutSeconds),
                icon: Icons.timer_outlined,
                min: 1,
                max: 6,
                divisions: 5,
                value: _navBarHideTimeoutSeconds.toDouble(),
                onChanged: (value) {
                  setState(() {
                    _navBarHideTimeoutSeconds = value.round();
                  });
                },
                onChangeEnd: (value) async {
                  await _applyThemeUpdate(
                    navBarHideTimeoutSeconds: value.round(),
                  );
                },
                startLabel: l10n.navBarTimeoutShort,
                endLabel: l10n.navBarTimeoutLong,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PresetCard extends StatelessWidget {
  const _PresetCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.fontFamily,
    required this.themeModeLabel,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Color color;
  final String fontFamily;
  final String themeModeLabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 224,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(UITokens.cornerXL),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(UITokens.cornerXL),
              border: Border.all(
                color: selected
                    ? color.withValues(alpha: 0.95)
                    : theme.colorScheme.outline.withValues(alpha: 0.14),
                width: selected ? 2 : 1,
              ),
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.16),
                  theme.colorScheme.surface.withValues(alpha: 0.92),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.18),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(UITokens.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              UITokens.cornerXLg,
                            ),
                            gradient: LinearGradient(
                              colors: [
                                color.withValues(alpha: 0.86),
                                color.withValues(alpha: 0.28),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: UITokens.spaceSmMd),
                      Container(
                        width: 64,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            UITokens.cornerXLg,
                          ),
                          color: theme.colorScheme.surface.withValues(
                            alpha: 0.76,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: UITokens.spaceXSm,
                            ),
                            child: Text(
                              'Аа',
                              style: _fontPreviewStyle(
                                theme.textTheme.titleLarge,
                                fontFamily,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: UITokens.spaceMdSm),
                  Text(
                    themeModeLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: UITokens.spaceSm),
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: UITokens.spaceXS),
                  Expanded(
                    child: Text(
                      subtitle,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.subtitleText(context),
                        height: 1.28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorChoiceCard extends StatelessWidget {
  const _ColorChoiceCard({
    required this.label,
    required this.toneLabel,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String toneLabel;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UITokens.corner2XLg),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(UITokens.corner2XLg),
            border: Border.all(
              color: selected
                  ? color.withValues(alpha: 0.95)
                  : theme.colorScheme.outline.withValues(alpha: 0.16),
              width: selected ? 2 : 1,
            ),
            color: theme.colorScheme.surface.withValues(alpha: 0.68),
          ),
          child: Padding(
            padding: const EdgeInsets.all(UITokens.spaceMd),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: UITokens.space2XS),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [color, color.withValues(alpha: 0.44)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.18),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: UITokens.space),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: UITokens.spaceSm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(
                            UITokens.cornerPill,
                          ),
                        ),
                        child: Text(
                          toneLabel,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: UITokens.spaceSm),
                if (selected) Icon(Icons.check_circle_rounded, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FontChoiceCard extends StatelessWidget {
  const _FontChoiceCard({
    required this.fontFamily,
    required this.selected,
    required this.previewWeight,
    required this.onTap,
  });

  final String fontFamily;
  final bool selected;
  final FontWeight previewWeight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 156,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(UITokens.corner2XLg),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(UITokens.corner2XLg),
              border: Border.all(
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.16),
                width: selected ? 2 : 1,
              ),
              color: theme.colorScheme.surface.withValues(alpha: 0.72),
            ),
            child: Padding(
              padding: const EdgeInsets.all(UITokens.spaceMdSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Аа',
                    style: _fontPreviewStyle(
                      theme.textTheme.headlineSmall,
                      fontFamily,
                      fontWeight: previewWeight,
                    ),
                  ),
                  const SizedBox(height: UITokens.spaceSm),
                  Text(
                    fontFamily,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _fontPreviewStyle(
                      theme.textTheme.titleSmall,
                      fontFamily,
                      fontWeight: previewWeight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SegmentChoiceCard extends StatelessWidget {
  const _SegmentChoiceCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.caption,
  });

  final String label;
  final String? caption;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UITokens.cornerXLg),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(UITokens.cornerXLg),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.16),
              width: selected ? 2 : 1,
            ),
            color: selected
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.72)
                : theme.colorScheme.surface.withValues(alpha: 0.68),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? theme.colorScheme.primary
                    : AppColors.subtitleText(context),
              ),
              const SizedBox(height: UITokens.spaceSm),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (caption != null) ...[
                const SizedBox(height: UITokens.space3XS),
                Text(
                  caption!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.subtitleText(context),
                    height: 1.25,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SliderSettingTile extends StatelessWidget {
  const _SliderSettingTile({
    required this.title,
    required this.valueLabel,
    required this.icon,
    required this.min,
    required this.max,
    required this.divisions,
    required this.value,
    required this.onChanged,
    required this.onChangeEnd,
    this.enabled = true,
    this.startLabel,
    this.endLabel,
  });

  final String title;
  final String valueLabel;
  final IconData icon;
  final double min;
  final double max;
  final int divisions;
  final double value;
  final bool enabled;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;
  final String? startLabel;
  final String? endLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.subtitleText(context)),
            const SizedBox(width: UITokens.spaceSm),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              valueLabel,
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.subtitleText(context),
              ),
            ),
          ],
        ),
        Slider(
          min: min,
          max: max,
          divisions: divisions,
          value: value.clamp(min, max),
          onChanged: enabled ? onChanged : null,
          onChangeEnd: enabled ? onChangeEnd : null,
        ),
        if (startLabel != null || endLabel != null)
          Row(
            children: [
              if (startLabel != null)
                Text(
                  startLabel!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.hintText(context),
                  ),
                ),
              const Spacer(),
              if (endLabel != null)
                Text(
                  endLabel!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.hintText(context),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _PreviewRoomsCard extends StatelessWidget {
  const _PreviewRoomsCard({
    required this.bubbleRounding,
    required this.compactMode,
    super.key,
  });

  final double bubbleRounding;
  final bool compactMode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final rooms =
        <
          ({
            String title,
            String subtitle,
            String time,
            int unread,
            bool muted,
          })
        >[
          (
            title: l10n.previewRoomDesignSync,
            subtitle: l10n.previewRoomDesignSyncSubtitle,
            time: '08:14',
            unread: 3,
            muted: false,
          ),
          (
            title: l10n.previewRoomReleaseCheck,
            subtitle: l10n.previewRoomReleaseCheckSubtitle,
            time: '09:07',
            unread: 1,
            muted: true,
          ),
          (
            title: l10n.previewRoomAlphaOps,
            subtitle: l10n.previewRoomAlphaOpsSubtitle,
            time: '09:41',
            unread: 0,
            muted: false,
          ),
        ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        UITokens.spaceMd,
        UITokens.spaceMd,
        UITokens.spaceMd,
        UITokens.spaceMdSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.previewRoomsTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: UITokens.spaceXS),
          Text(
            l10n.previewRoomsSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.subtitleText(context),
            ),
          ),
          const SizedBox(height: UITokens.spaceMdSm),
          Expanded(
            child: Column(
              children: rooms.map((room) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(bottom: room == rooms.last ? 0 : 9),
                    padding: EdgeInsets.all(compactMode ? 12 : 14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(
                        bubbleRounding.clamp(12, 24),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          foregroundColor: theme.colorScheme.primary,
                          child: Text(
                            room.title.isNotEmpty ? room.title[0] : '?',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: UITokens.space),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                room.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: UITokens.space3XS),
                              Text(
                                room.subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.subtitleText(context),
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: UITokens.spaceSm),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(room.time, style: theme.textTheme.labelSmall),
                            const SizedBox(height: UITokens.spaceSm),
                            if (room.unread > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(
                                    UITokens.cornerPill,
                                  ),
                                ),
                                child: Text(
                                  '${room.unread}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            else
                              Icon(
                                room.muted
                                    ? Icons.notifications_off_rounded
                                    : Icons.done_all_rounded,
                                size: 16,
                                color: room.muted
                                    ? AppColors.hintText(context)
                                    : AppColors.onlineStatus(context),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewConversationCard extends StatelessWidget {
  const _PreviewConversationCard({
    required this.bubbleRounding,
    required this.dynamicBubbles,
    required this.compactMode,
    super.key,
  });

  final double bubbleRounding;
  final bool dynamicBubbles;
  final bool compactMode;

  BorderRadius _bubbleRadius(bool ownBubble) {
    final radius = Radius.circular(bubbleRounding.clamp(8, 28));
    final tighter = Radius.circular((bubbleRounding * 0.55).clamp(6, 18));
    if (!dynamicBubbles) {
      return BorderRadius.all(radius);
    }
    return ownBubble
        ? BorderRadius.only(
            topLeft: radius,
            topRight: radius,
            bottomLeft: radius,
            bottomRight: tighter,
          )
        : BorderRadius.only(
            topLeft: radius,
            topRight: radius,
            bottomLeft: tighter,
            bottomRight: radius,
          );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final messagePadding = compactMode ? 12.0 : 14.0;
    final messageGap = compactMode ? 8.0 : 10.0;
    final maxWidth = compactMode ? 214.0 : 236.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        UITokens.spaceMd,
        UITokens.spaceMd,
        UITokens.spaceMd,
        UITokens.spaceMdSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.previewConversationTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: UITokens.spaceXS),
          Text(
            l10n.previewConversationSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.subtitleText(context),
            ),
          ),
          const SizedBox(height: UITokens.spaceMd),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              padding: EdgeInsets.all(messagePadding),
              decoration: BoxDecoration(
                color: AppColors.otherBubble(context),
                borderRadius: _bubbleRadius(false),
              ),
              child: Text(
                l10n.previewIncomingMessage,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
          SizedBox(height: messageGap),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              padding: EdgeInsets.all(messagePadding),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.82),
                  ],
                ),
                borderRadius: _bubbleRadius(true),
              ),
              child: Text(
                l10n.previewOutgoingMessage,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
          SizedBox(height: messageGap),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth - 16),
              padding: EdgeInsets.all(messagePadding),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: _bubbleRadius(false),
              ),
              child: Text(
                l10n.previewTypingStatus,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.subtitleText(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewSettingsCard extends StatelessWidget {
  const _PreviewSettingsCard({required this.compactMode, super.key});

  final bool compactMode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    Widget tile(IconData icon, String title, String subtitle) {
      return Container(
        margin: EdgeInsets.only(bottom: compactMode ? 8 : 10),
        padding: EdgeInsets.all(compactMode ? 12 : 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.68),
          borderRadius: BorderRadius.circular(UITokens.cornerXLg),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(UITokens.cornerMd),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: UITokens.space),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: UITokens.space3XS),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.subtitleText(context),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        UITokens.spaceMd,
        UITokens.spaceMd,
        UITokens.spaceMd,
        UITokens.spaceMdSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.previewSettingsTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: UITokens.spaceXS),
          Text(
            l10n.previewSettingsSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.subtitleText(context),
            ),
          ),
          const SizedBox(height: UITokens.spaceMdSm),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: tile(
                    Icons.palette_outlined,
                    l10n.appearanceSection,
                    l10n.previewSettingsAppearanceSubtitle,
                  ),
                ),
                Expanded(
                  child: tile(
                    Icons.notifications_outlined,
                    l10n.notificationsSection,
                    l10n.previewSettingsNotificationsSubtitle,
                  ),
                ),
                Expanded(
                  child: tile(
                    Icons.lock_outline_rounded,
                    l10n.privacyLabel,
                    l10n.previewSettingsPrivacySubtitle,
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
