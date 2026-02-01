import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:two_space_app/services/chat_matrix_service.dart';
import 'package:two_space_app/models/chat.dart';
import 'package:two_space_app/screens/chat_screen.dart';
import 'package:two_space_app/screens/group_settings_screen.dart';
import 'package:two_space_app/widgets/user_avatar.dart';
import 'package:two_space_app/services/auth_service.dart';
import '../utils/responsive.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ChatMatrixService _chat = ChatMatrixService();
  List<Map<String, dynamic>> _rooms = [];
  String? _selectedRoomId;
  String _selectedRoomName = '';
  bool _loading = true;

  String _searchQuery = '';
  String _searchType = 'all';

  List<Map<String, dynamic>> get _filteredRooms {
    if (_searchQuery.isEmpty) return _rooms;
    return _rooms.where((r) {
      final name = (r['name'] as String?)?.toLowerCase() ?? '';
      return name.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadRooms();
    _setUserContext();
  }

  Future<void> _setUserContext() async {
    try {
      final auth = AuthService();
      final token = await auth.getMatrixTokenForUser();
      if (token == null || token.isEmpty) {
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        return;
      }
    } catch (e) {
      if (!mounted) return;
    }
  }

  Future<void> _loadRooms() async {
    if (!mounted) return;
    setState(() => _loading = true);
    
    try {
      final ids = await _chat.getJoinedRooms();
      final out = <Map<String, dynamic>>[];
      
      for (final id in ids) {
        final meta = await _chat.getRoomNameAndAvatar(id);
        out.add({
          'roomId': id,
          'name': meta['name'] ?? id,
          'avatar': meta['avatar'],
        });
      }
      
      if (mounted) {
        setState(() {
          _rooms = out;
          if (_rooms.isNotEmpty) {
            _selectedRoomId = _rooms.first['roomId'] as String?;
            _selectedRoomName = _rooms.first['name'] as String? ?? '';
          }
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _rooms = [
            {'roomId': '!example1:matrix.org', 'name': 'Общий чат'},
            {'roomId': '!example2:matrix.org', 'name': 'Разработка'},
            {'roomId': '!example3:matrix.org', 'name': 'Тестовый'},
          ];
          if (_rooms.isNotEmpty) {
            _selectedRoomId = _rooms.first['roomId'] as String?;
            _selectedRoomName = _rooms.first['name'] as String? ?? '';
          }
          _loading = false;
        });
      }
    }
  }

  PopupMenuItem<String> _buildFilterMenuItem(String title, String value) {
    return PopupMenuItem(
      value: value,
      child: Text(title),
    );
  }

  Widget _buildLeftColumn(double width) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Поиск',
                isDense: true,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                PopupMenuButton<String>(
                  tooltip: 'Тип поиска',
                  icon: const Icon(Icons.filter_list),
                  onSelected: (v) => setState(() => _searchType = v),
                  itemBuilder: (_) => [
                    _buildFilterMenuItem('Все', 'all'),
                    _buildFilterMenuItem('Сообщения', 'messages'),
                    _buildFilterMenuItem('Медиа', 'media'),
                    _buildFilterMenuItem('Пользователи', 'users'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _filteredRooms.isEmpty
                  ? const Center(child: Text('Нет чатов'))
                  : ListView.builder(
                      itemCount: _filteredRooms.length,
                      itemBuilder: (context, index) {
                        final r = _filteredRooms[index];
                        final id = r['roomId'] as String;
                        final name = r['name'] as String? ?? id;
                        final selected = _selectedRoomId == id;
                        return ListTile(
                          selected: selected,
                          title: Text(name),
                          leading: r['avatar'] != null
                              ? UserAvatar(avatarUrl: r['avatar'] as String?, radius: 20 * Responsive.scaleFor(context))
                              : CircleAvatar(
                                radius: 20 * Responsive.scaleFor(context),
                                child: Text(name.isEmpty ? '?' : name[0].toUpperCase()),
                              ),
                          onTap: () {
                            setState(() {
                              _selectedRoomId = id;
                              _selectedRoomName = name;
                            });
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = Responsive.scaleFor(context);
        final isWide = constraints.maxWidth > 800;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Home',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 24 * scale,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Row(
            children: [
              if (isWide)
                Expanded(
                  flex: 2,
                  child: Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: _buildLeftColumn(300.0),
                  ),
                ),
              Expanded(
                flex: 5,
                child: _buildMainContent(scale),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainContent(double scale) {
    if (_selectedRoomId == null) {
      return const Center(child: Text('Выберите комнату'));
    }
    final chat = Chat(id: _selectedRoomId!, name: _selectedRoomName, members: []);
    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(child: Text(_selectedRoomName, style: Theme.of(context).textTheme.titleLarge)),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => GroupSettingsScreen(roomId: _selectedRoomId!)));
                },
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(child: ChatScreen(key: ValueKey(chat.id), chat: chat)),
      ],
    );
  }
}
