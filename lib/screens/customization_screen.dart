import 'package:flutter/material.dart';
import 'package:two_space_app/services/settings_service.dart';
import 'package:two_space_app/config/ui_tokens.dart';
import 'package:two_space_app/config/theme_options.dart';

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

  final List<Map<String, dynamic>> _choices = ThemeOptions.colors;

  @override
  void initState() {
    super.initState();
    _selectedColor = SettingsService.themeNotifier.value.primaryColorValue;
    _tabController = TabController(length: 3, vsync: this);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Кастомизация'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.palette), text: 'Цвета'),
            Tab(icon: Icon(Icons.font_download), text: 'Шрифты'),
            Tab(icon: Icon(Icons.tune), text: 'Прочее'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildColorTab(),
          _buildFontTab(),
          _buildOtherTab(),
        ],
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
                      Text(
                        'Выберите цветовую тему',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Выбранная тема применится ко всему приложению',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withAlpha((0.6 * 255).round()),
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
                  color: selected ? null : Theme.of(context).colorScheme.surface,
                  border: Border.all(
                    color: selected ? Color(v) : Theme.of(context).dividerColor,
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
                                color: selected ? Colors.white : Theme.of(context).colorScheme.onSurface,
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
                      Text(
                        'Настройки шрифта',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Выберите семейство шрифта и его параметры',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withAlpha((0.6 * 255).round()),
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Шрифт приложения', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _fontChoices.map((f) {
              final sel = f == _selectedFont;
              final previewSize = f == 'Press Start 2P' ? 12.0 : 16.0;
              return ChoiceChip(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                avatar: sel ? const Icon(Icons.check, size: 18) : null,
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
                onSelected: (_) {
                  _setFont(f);
                  setState(() => _selectedFont = f);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('Толщина шрифта', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(UITokens.corner)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: StatefulBuilder(builder: (c, setLocal) {
                return Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.format_size, size: 20),
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
                          child: Text('$_selectedWeight', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
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

  Widget _buildOtherTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(UITokens.corner)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.settings, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        'Дополнительные настройки',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Настройте отображение и поведение интерфейса',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withAlpha((0.6 * 255).round()),
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(UITokens.corner)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.text_fields),
                  title: const Text('Размер текста'),
                  subtitle: Text('${_fontSize.toStringAsFixed(0)} pt'),
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
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.compress),
                  title: const Text('Компактный режим'),
                  subtitle: const Text('Уменьшить отступы и размеры элементов'),
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
