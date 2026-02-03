import 'package:flutter/material.dart';
import 'package:two_space_app/widgets/screen_background.dart';
import 'package:two_space_app/widgets/glass_card.dart';
import 'package:two_space_app/widgets/app_logo.dart';
import 'package:two_space_app/screens/call_screen.dart';

enum CallType { incoming, outgoing, missed, video }

class CallRecord {
  final String id;
  final String name;
  final String? avatarUrl;
  final CallType type;
  final DateTime time;
  final Duration? duration;
  final bool isVideo;

  const CallRecord({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.type,
    required this.time,
    this.duration,
    this.isVideo = false,
  });
}

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  String _searchQuery = '';
  CallType? _filterType;
  final _searchController = TextEditingController();

  // Fake call records
  final List<CallRecord> _calls = [
    CallRecord(
      id: '1',
      name: 'Александр Петров',
      type: CallType.incoming,
      time: DateTime.now().subtract(const Duration(minutes: 15)),
      duration: const Duration(minutes: 5, seconds: 32),
    ),
    CallRecord(
      id: '2',
      name: 'Мария Иванова',
      type: CallType.outgoing,
      time: DateTime.now().subtract(const Duration(hours: 1)),
      duration: const Duration(minutes: 12, seconds: 45),
      isVideo: true,
    ),
    CallRecord(
      id: '3',
      name: 'Дмитрий Сидоров',
      type: CallType.missed,
      time: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    CallRecord(
      id: '4',
      name: 'Илон Маск',
      type: CallType.incoming,
      time: DateTime.now().subtract(const Duration(hours: 3)),
      duration: const Duration(minutes: 8, seconds: 15),
      isVideo: true,
    ),
    CallRecord(
      id: '5',
      name: 'Сергей Николаев',
      type: CallType.outgoing,
      time: DateTime.now().subtract(const Duration(hours: 5)),
      duration: const Duration(minutes: 2, seconds: 10),
    ),
    CallRecord(
      id: '6',
      name: 'Анна Федорова',
      type: CallType.missed,
      time: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    CallRecord(
      id: '7',
      name: 'Павел Морозов',
      type: CallType.incoming,
      time: DateTime.now().subtract(const Duration(days: 1)),
      duration: const Duration(minutes: 25, seconds: 0),
    ),
    CallRecord(
      id: '8',
      name: 'Ольга Волкова',
      type: CallType.outgoing,
      time: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      duration: const Duration(minutes: 45, seconds: 20),
      isVideo: true,
    ),
    CallRecord(
      id: '9',
      name: 'Игорь Соколов',
      type: CallType.missed,
      time: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
    ),
    CallRecord(
      id: '10',
      name: 'Наталья Попова',
      type: CallType.incoming,
      time: DateTime.now().subtract(const Duration(days: 2)),
      duration: const Duration(minutes: 3, seconds: 55),
    ),
    CallRecord(
      id: '11',
      name: 'Артемий Лебедев',
      type: CallType.outgoing,
      time: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
      duration: const Duration(hours: 1, minutes: 15),
      isVideo: true,
    ),
    CallRecord(
      id: '12',
      name: 'Виктория Козлова',
      type: CallType.missed,
      time: DateTime.now().subtract(const Duration(days: 3)),
    ),
    CallRecord(
      id: '13',
      name: 'Роман Новиков',
      type: CallType.incoming,
      time: DateTime.now().subtract(const Duration(days: 3, hours: 10)),
      duration: const Duration(minutes: 18, seconds: 30),
    ),
    CallRecord(
      id: '14',
      name: 'Екатерина Смирнова',
      type: CallType.outgoing,
      time: DateTime.now().subtract(const Duration(days: 4)),
      duration: const Duration(minutes: 7, seconds: 12),
      isVideo: true,
    ),
    CallRecord(
      id: '15',
      name: 'Роман Кузнецов',
      type: CallType.missed,
      time: DateTime.now().subtract(const Duration(days: 5)),
    ),
    CallRecord(
      id: '16',
      name: 'Татьяна Орлова',
      type: CallType.incoming,
      time: DateTime.now().subtract(const Duration(days: 6)),
      duration: const Duration(minutes: 35, seconds: 8),
    ),
    CallRecord(
      id: '17',
      name: 'Владимир Белов',
      type: CallType.outgoing,
      time: DateTime.now().subtract(const Duration(days: 7)),
      duration: const Duration(minutes: 22, seconds: 45),
    ),
    CallRecord(
      id: '18',
      name: 'Светлана Медведева',
      type: CallType.missed,
      time: DateTime.now().subtract(const Duration(days: 7, hours: 12)),
    ),
    CallRecord(
      id: '19',
      name: 'Алексей Гусев',
      type: CallType.incoming,
      time: DateTime.now().subtract(const Duration(days: 10)),
      duration: const Duration(minutes: 55, seconds: 0),
      isVideo: true,
    ),
    CallRecord(
      id: '20',
      name: 'Юлия Титова',
      type: CallType.outgoing,
      time: DateTime.now().subtract(const Duration(days: 14)),
      duration: const Duration(minutes: 10, seconds: 30),
    ),
  ];

  List<CallRecord> get _filteredCalls {
    return _calls.where((call) {
      // Filter by type
      if (_filterType != null && call.type != _filterType) {
        return false;
      }
      // Filter by search
      if (_searchQuery.isNotEmpty) {
        return call.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }
      return true;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} мин. назад';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} ч. назад';
    } else if (diff.inDays == 1) {
      return 'Вчера';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} дн. назад';
    } else {
      return '${time.day}.${time.month.toString().padLeft(2, '0')}';
    }
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  IconData _getCallIcon(CallType type) {
    switch (type) {
      case CallType.incoming:
        return Icons.call_received;
      case CallType.outgoing:
        return Icons.call_made;
      case CallType.missed:
        return Icons.call_missed;
      case CallType.video:
        return Icons.videocam;
    }
  }

  Color _getCallColor(CallType type) {
    switch (type) {
      case CallType.incoming:
        return Colors.green;
      case CallType.outgoing:
        return Colors.blue;
      case CallType.missed:
        return Colors.red;
      case CallType.video:
        return Colors.purple;
    }
  }

  String _getCallTypeLabel(CallType type) {
    switch (type) {
      case CallType.incoming:
        return 'Входящий';
      case CallType.outgoing:
        return 'Исходящий';
      case CallType.missed:
        return 'Пропущенный';
      case CallType.video:
        return 'Видеозвонок';
    }
  }

  void _makeCall(CallRecord call, bool isVideo) {
    final roomName = 'call_${call.id}_${DateTime.now().millisecondsSinceEpoch}';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          room: roomName,
          isVideo: isVideo,
          displayName: call.name,
          avatarUrl: call.avatarUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredCalls = _filteredCalls;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with TwoSpace logo
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const AppLogo(large: false),
                    const SizedBox(width: 8),
                    Text(
                      'Звонки',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Поиск по имени...',
                      hintStyle: TextStyle(color: Colors.white.withAlpha(120)),
                      prefixIcon: const Icon(Icons.search, color: Colors.white70),
                      border: InputBorder.none,
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white70),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildFilterChip(null, 'Все'),
                    const SizedBox(width: 8),
                    _buildFilterChip(CallType.incoming, 'Входящие'),
                    const SizedBox(width: 8),
                    _buildFilterChip(CallType.outgoing, 'Исходящие'),
                    const SizedBox(width: 8),
                    _buildFilterChip(CallType.missed, 'Пропущенные'),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Calls list
              Expanded(
                child: filteredCalls.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.call_outlined,
                              size: 64,
                              color: Colors.white.withAlpha(100),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty || _filterType != null
                                  ? 'Ничего не найдено'
                                  : 'Нет звонков',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withAlpha(150),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
                        itemCount: filteredCalls.length,
                        itemBuilder: (c, i) {
                          final call = filteredCalls[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: GlassCard(
                              onTap: () => _showCallOptions(call),
                              child: ListTile(
                                leading: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: theme.colorScheme.primary.withAlpha(100),
                                      child: Text(
                                        call.name.isNotEmpty 
                                            ? call.name[0].toUpperCase() 
                                            : '?',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    if (call.isVideo)
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: Colors.purple,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 1.5),
                                          ),
                                          child: const Icon(
                                            Icons.videocam,
                                            color: Colors.white,
                                            size: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                title: Text(
                                  call.name,
                                  style: TextStyle(
                                    color: call.type == CallType.missed 
                                        ? Colors.redAccent 
                                        : Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Row(
                                  children: [
                                    Icon(
                                      _getCallIcon(call.type),
                                      size: 14,
                                      color: _getCallColor(call.type),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      call.duration != null 
                                          ? '${_getCallTypeLabel(call.type)} • ${_formatDuration(call.duration)}'
                                          : _getCallTypeLabel(call.type),
                                      style: TextStyle(
                                        color: Colors.white.withAlpha(150),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _formatTime(call.time),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withAlpha(120),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () => _makeCall(call, false),
                                          child: Icon(
                                            Icons.call,
                                            color: Colors.green.withAlpha(200),
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        GestureDetector(
                                          onTap: () => _makeCall(call, true),
                                          child: Icon(
                                            Icons.videocam,
                                            color: Colors.blue.withAlpha(200),
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(CallType? type, String label) {
    final isSelected = _filterType == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterType = selected ? type : null);
      },
      backgroundColor: Colors.white.withAlpha(20),
      selectedColor: Theme.of(context).colorScheme.primary.withAlpha(150),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white.withAlpha(180),
      ),
      checkmarkColor: Colors.white,
      side: BorderSide.none,
    );
  }

  void _showCallOptions(CallRecord call) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(100),
                child: Text(call.name[0]),
              ),
              title: Text(call.name),
              subtitle: Text('${_getCallTypeLabel(call.type)} • ${_formatTime(call.time)}'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.call, color: Colors.green),
              title: const Text('Голосовой звонок'),
              onTap: () {
                Navigator.pop(context);
                _makeCall(call, false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: Colors.blue),
              title: const Text('Видеозвонок'),
              onTap: () {
                Navigator.pop(context);
                _makeCall(call, true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Написать сообщение'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Сообщение для: ${call.name}')),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
