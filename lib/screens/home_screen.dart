import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:two_space_app/services/chat_matrix_service.dart';
import 'package:two_space_app/models/chat.dart';
import 'package:two_space_app/screens/chat_screen.dart';
import 'package:two_space_app/screens/group_settings_screen.dart';
import 'package:two_space_app/widgets/user_avatar.dart';
import 'package:two_space_app/services/auth_service.dart';
import 'package:two_space_app/utils/responsive.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ChatMatrixService _chat = ChatMatrixService();
  List<Map<String, dynamic>> _rooms = [];
  String? _selectedRoomId;
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
          'roomId': id,
          'name': meta['name'] ?? id,
          'avatar': meta['avatar'],
        });
      }
      
      if (mounted) {
        setState(() {
          _rooms = out;
          if (_rooms.isNotEmpty && _selectedRoomId == null) {
            _selectedRoomId = _rooms.first['roomId'] as String?;
          }
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _rooms = [
            {'roomId': '!example1:matrix.org', 'name': 'General'},
            {'roomId': '!example2:matrix.org', 'name': 'Development'},
            {'roomId': '!example3:matrix.org', 'name': 'Random'},
          ];
          if (_rooms.isNotEmpty && _selectedRoomId == null) {
            _selectedRoomId = _rooms.first['roomId'] as String?;
          }
          _loading = false;
        });
      }
    }
  }

  Widget _buildRoomList() {
    final filteredRooms = _rooms.where((room) {
      final name = (room['name'] as String? ?? '').toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    return Container(
      color: const Color(0xFF151718), // Element-like dark background
      child: Column(
        children: [
          Container(
             width: double.infinity,
             color: Colors.redAccent,
             padding: const EdgeInsets.symmetric(vertical: 4),
             child: const Text('Offline Mode', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Filter rooms...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                isDense: true,
                filled: true,
                fillColor: const Color(0xFF21262C),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredRooms.length,
                    itemBuilder: (context, index) {
                      final r = filteredRooms[index];
                      final id = r['roomId'] as String;
                      final name = r['name'] as String? ?? id;
                      final selected = _selectedRoomId == id;
                      return ListTile(
                        selected: selected,
                        selectedTileColor: Colors.grey.withOpacity(0.2),
                        title: Text(name, style: const TextStyle(color: Colors.white)),
                        leading: UserAvatar(
                          avatarUrl: r['avatar'] as String?,
                          name: name,
                          radius: 18,
                        ),
                        onTap: () {
                          setState(() {
                            _selectedRoomId = id;
                          });
                          // Close drawer on mobile after selection
                          if (Responsive.isMobile(context)) {
                            Navigator.pop(context);
                          }
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
    final isWide = Responsive.isDesktop(context);
    final selectedRoom = _rooms.firstWhere(
      (r) => r['roomId'] == _selectedRoomId,
      orElse: () => _rooms.isNotEmpty ? _rooms.first : {},
    );
    final chatName = selectedRoom['name'] as String? ?? 'Select a room';

    return Scaffold(
      appBar: isWide ? null : AppBar(
        title: Text(chatName),
        backgroundColor: const Color(0xFF1D2227),
      ),
      drawer: isWide ? null : Drawer(child: _buildRoomList()),
      body: Row(
        children: [
          if (isWide)
            SizedBox(
              width: 300,
              child: _buildRoomList(),
            ),
          Expanded(
            child: _selectedRoomId == null
                ? const Center(child: Text('Select a room to start chatting'))
                : ChatScreen(
                    key: ValueKey(_selectedRoomId!),
                    chat: Chat(
                      id: _selectedRoomId!,
                      name: chatName,
                      members: [],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
