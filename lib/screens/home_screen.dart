import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:two_space_app/services/chat_matrix_service.dart';
import 'package:two_space_app/models/chat.dart';
import 'package:two_space_app/screens/chat_screen.dart';
import 'package:two_space_app/widgets/user_avatar.dart';
import 'package:two_space_app/widgets/screen_background.dart';
import 'package:two_space_app/widgets/glass_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ChatMatrixService _chat = ChatMatrixService();
  List<Map<String, dynamic>> _rooms = [];
  bool _loading = true;

  String _searchQuery = '';

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
          'id': id,
          'name': meta['name'] ?? id,
          'avatar': meta['avatar'],
          'lastMessage': '...',
          'time': DateTime.now(),
        });
      }
      if (mounted) setState(() => _rooms = out);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: const Text('Сообщения'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
               onTap: () => Navigator.pushNamed(context, '/profile'),
               child: const UserAvatar(radius: 18),
            ),
          )
        ],
      ),
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            children: [
               Expanded(
                 child: _loading 
                   ? const Center(child: CircularProgressIndicator())
                   : _buildChatList(),
               ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatList() {
    final rooms = _filteredRooms;
    if (rooms.isEmpty) return const Center(child: Text('Нет чатов', style: TextStyle(color: Colors.white70)));
    
    return ListView.builder(
      padding: const EdgeInsets.all(8), 
      itemCount: rooms.length,
      itemBuilder: (c, i) {
        final r = rooms[i];
        final id = r['id'] as String;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: GlassCard( 
            onTap: () => _openChat(id),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                UserAvatar(
                  avatarUrl: r['avatar'],
                  name: r['name'],
                  radius: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r['name'], 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                        maxLines: 1, overflow: TextOverflow.ellipsis
                      ),
                      const SizedBox(height: 4),
                      Text(
                        r['lastMessage'], 
                        style: const TextStyle(fontSize: 14, color: Colors.white70),
                        maxLines: 1, overflow: TextOverflow.ellipsis
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                     const Text('12:00', style: TextStyle(fontSize: 12, color: Colors.white54)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openChat(String id) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(chat: Chat(id: id, name: id, members: []))));
  }
}
