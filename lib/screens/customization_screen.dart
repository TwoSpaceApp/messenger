import 'package:flutter/material.dart';
import 'package:two_space_app/services/settings_service.dart';
import 'package:two_space_app/config/ui_tokens.dart';
import 'package:two_space_app/config/theme_options.dart';
import 'package:two_space_app/widgets/screen_background.dart';
import 'package:two_space_app/widgets/app_logo.dart';

class CustomizationScreen extends StatefulWidget {
  const CustomizationScreen({super.key});

  @override
  State<CustomizationScreen> createState() => _CustomizationScreenState();
}

class _CustomizationScreenState extends State<CustomizationScreen> with SingleTickerProviderStateMixin {
  late int _selectedColor;
  late TabController _tabController;
  double _fontSize = 14.0;
  bool _compactMode = false;
  
  // Floating circles settings
  late bool _enableFloatingCircles;
  late double _floatingCirclesSpeed;
  late double _floatingCirclesOpacity;
  late bool _enableParallax;

  final List<Map<String, dynamic>> _choices = ThemeOptions.colors;

  @override
  void initState() {
    super.initState();
    _selectedColor = SettingsService.themeNotifier.value.primaryColorValue;
    _tabController = TabController(length: 3, vsync: this);
    
    // Load floating circles settings
    final settings = SettingsService.themeNotifier.value;
    _enableFloatingCircles = settings.enableFloatingCircles;
    _floatingCirclesSpeed = settings.floatingCirclesSpeed;
    _floatingCirclesOpacity = settings.floatingCirclesOpacity;
    _enableParallax = settings.enableParallax;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Available font choices. Note: fonts must exist on device or be bundled in pubspec.yaml to take effect.
  final List<String> _fontChoices = ThemeOptions.fonts;
  late String _selectedFont = SettingsService.themeNotifier.value.fontFamily;
  late int _selectedWeight = SettingsService.themeNotifier.value.fontWeight;

  FontWeight _resolveFontWeight(int w) {
    if (w >= 900) return FontWeight.w900;
    if (w >= 800) return FontWeight.w800;
    if (w >= 700) return FontWeight.w700;
    if (w >= 600) return FontWeight.w600;
    if (w >= 500) return FontWeight.w500;
    if (w >= 400) return FontWeight.w400;
    if (w >= 300) return FontWeight.w300;
    return FontWeight.w400;
  }

  Future<void> _select(int value) async {
    setState(() => _selectedColor = value);
    await SettingsService.setPrimaryColor(value);
    // If Pale Violet selected, enable the special light-mode flag; otherwise disable it
    if (value == 0xFFE8D7FF) {
      await SettingsService.setPaleVioletMode(true);
    } else {
      await SettingsService.setPaleVioletMode(false);
    }
  }

  Future<void> _setFont(String font) async {
    setState(() => _selectedFont = font);
    await SettingsService.setFont(font);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const AppLogo(large: false),
                    const SizedBox(width: 8),
                    Text(
                      'Кастомизация',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Tab bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  indicatorColor: theme.colorScheme.primary,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [
                    Tab(icon: Icon(Icons.palette), text: 'Цвета'),
                    Tab(icon: Icon(Icons.font_download), text: 'Шрифты'),
                    Tab(icon: Icon(Icons.tune), text: 'Эффекты'),
                  ],
                ),
              ),
              
              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildColorTab(),
                    _buildFontTab(),
                    _buildEffectsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            color: Colors.white.withAlpha(20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(UITokens.corner)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.palette, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 12),
                      const Text(
                        'Выберите цветовую тему',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Выбранная тема применится ко всему приложению',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withAlpha(150),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _choices.length,
            itemBuilder: (context, index) {
              final item = _choices[index];
              final v = item['value'] as int;
              final name = item['name'] as String;
              final selected = v == _selectedColor;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(UITokens.cornerSm),
                  gradient: selected
                      ? LinearGradient(
                          colors: [Color(v), Color(v).withAlpha(200)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: selected ? null : Colors.white.withAlpha(20),
                  border: Border.all(
                    color: selected ? Color(v) : Colors.white.withAlpha(50),
                    width: selected ? 2 : 1,
                  ),
                  boxShadow: selected
                      ? [BoxShadow(color: Color(v).withAlpha(80), blurRadius: 8, offset: const Offset(0, 4))]
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(UITokens.cornerSm),
                    onTap: () => _select(v),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Color(v),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withAlpha(100), width: 2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              name,
                              style: TextStyle(
                                color: selected ? Colors.white : Colors.white.withAlpha(200),
                                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (selected)
                            const Icon(Icons.check_circle, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFontTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            color: Colors.white.withAlpha(20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(UITokens.corner)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.font_download, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 12),
                      const Text(
                        'Настройки шрифта',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Выберите семейство шрифта и его параметры',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withAlpha(150),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Шрифт приложения',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withAlpha(200),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _fontChoices.map((f) {
              final sel = f == _selectedFont;
              final previewSize = f == 'Press Start 2P' ? 12.0 : 16.0;
              return ChoiceChip(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                avatar: sel ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Aa', style: TextStyle(fontFamily: f, fontWeight: _resolveFontWeight(600), fontSize: previewSize)),
                    const SizedBox(width: 8),
                    Text(f, style: TextStyle(fontFamily: f, fontWeight: _resolveFontWeight(_selectedWeight), fontSize: previewSize)),
                  ],
                ),
                selected: sel,
                selectedColor: Theme.of(context).colorScheme.primary.withAlpha(150),
                backgroundColor: Colors.white.withAlpha(20),
                labelStyle: TextStyle(color: sel ? Colors.white : Colors.white.withAlpha(180)),
                onSelected: (_) {
                  _setFont(f);
                  setState(() => _selectedFont = f);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text(
            'Толщина шрифта',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withAlpha(200),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 1,
            color: Colors.white.withAlpha(15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(UITokens.corner)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: StatefulBuilder(builder: (c, setLocal) {
                return Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.format_size, size: 20, color: Colors.white70),
                        Expanded(
                          child: Slider(
                            min: 300,
                            max: 900,
                            divisions: 6,
                            value: _selectedWeight.toDouble().clamp(300, 900),
                            label: '$_selectedWeight',
                            onChanged: (v) {
                              setLocal(() => _selectedWeight = v.round());
                              setState(() {});
                            },
                            onChangeEnd: (v) async {
                              await SettingsService.setFontWeight(v.round());
                            },
                          ),
                        ),
                        Container(
                          width: 48,
                          alignment: Alignment.center,
                          child: Text(
                            '$_selectedWeight',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Предпросмотр: Пример текста',
                      style: TextStyle(
                        fontFamily: _selectedFont,
                        fontWeight: _resolveFontWeight(_selectedWeight),
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEffectsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Floating Circles Section
          Card(
            elevation: 2,
            color: Colors.white.withAlpha(20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(UITokens.corner)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.blur_circular, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 12),
                      const Text(
                        'Плавающие круги',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Анимированные круги на фоне приложения',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withAlpha(150),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          Card(
            elevation: 1,
            color: Colors.white.withAlpha(15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(UITokens.corner)),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.blur_on, color: Colors.white70),
                  title: const Text('Включить круги', style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    _enableFloatingCircles ? 'Круги отображаются' : 'Круги скрыты',
                    style: TextStyle(color: Colors.white.withAlpha(150)),
                  ),
                  value: _enableFloatingCircles,
                  onChanged: (v) async {
                    setState(() => _enableFloatingCircles = v);
                    await SettingsService.updateTheme(enableFloatingCircles: v);
                  },
                ),
                const Divider(height: 1, color: Colors.white24),
                SwitchListTile(
                  secondary: const Icon(Icons.sensors, color: Colors.white70),
                  title: const Text('Параллакс-эффект', style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    _enableParallax ? 'Реагируют на наклон телефона' : 'Статичное движение',
                    style: TextStyle(color: Colors.white.withAlpha(150)),
                  ),
                  value: _enableParallax,
                  onChanged: _enableFloatingCircles ? (v) async {
                    setState(() => _enableParallax = v);
                    await SettingsService.updateTheme(enableParallax: v);
                  } : null,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          Card(
            elevation: 1,
            color: Colors.white.withAlpha(15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(UITokens.corner)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.speed, color: Colors.white70, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Скорость движения',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      Text(
                        '${(_floatingCirclesSpeed * 100).round()}%',
                        style: TextStyle(color: Colors.white.withAlpha(180)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    min: 0.2,
                    max: 2.0,
                    divisions: 18,
                    value: _floatingCirclesSpeed,
                    label: '${(_floatingCirclesSpeed * 100).round()}%',
                    onChanged: _enableFloatingCircles ? (v) {
                      setState(() => _floatingCirclesSpeed = v);
                    } : null,
                    onChangeEnd: (v) async {
                      await SettingsService.updateTheme(floatingCirclesSpeed: v);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Медленно', style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(120))),
                      Text('Быстро', style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(120))),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Card(
            elevation: 1,
            color: Colors.white.withAlpha(15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(UITokens.corner)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.opacity, color: Colors.white70, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Яркость',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      Text(
                        '${(_floatingCirclesOpacity * 100).round()}%',
                        style: TextStyle(color: Colors.white.withAlpha(180)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    value: _floatingCirclesOpacity,
                    label: '${(_floatingCirclesOpacity * 100).round()}%',
                    onChanged: _enableFloatingCircles ? (v) {
                      setState(() => _floatingCirclesOpacity = v);
                    } : null,
                    onChangeEnd: (v) async {
                      await SettingsService.updateTheme(floatingCirclesOpacity: v);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Тусклые', style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(120))),
                      Text('Яркие', style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(120))),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Other UI settings
          Card(
            elevation: 2,
            color: Colors.white.withAlpha(20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(UITokens.corner)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tune, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 12),
                      const Text(
                        'Дополнительные настройки',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          Card(
            elevation: 1,
            color: Colors.white.withAlpha(15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(UITokens.corner)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.text_fields, color: Colors.white70),
                  title: const Text('Размер текста', style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    '${_fontSize.toStringAsFixed(0)} pt',
                    style: TextStyle(color: Colors.white.withAlpha(150)),
                  ),
                  trailing: SizedBox(
                    width: 120,
                    child: Slider(
                      min: 12.0,
                      max: 20.0,
                      divisions: 8,
                      value: _fontSize,
                      onChanged: (v) => setState(() => _fontSize = v),
                    ),
                  ),
                ),
                const Divider(height: 1, color: Colors.white24),
                SwitchListTile(
                  secondary: const Icon(Icons.compress, color: Colors.white70),
                  title: const Text('Компактный режим', style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    'Уменьшить отступы и размеры',
                    style: TextStyle(color: Colors.white.withAlpha(150)),
                  ),
                  value: _compactMode,
                  onChanged: (v) => setState(() => _compactMode = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
