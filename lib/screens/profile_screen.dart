import 'package:flutter/material.dart';
import 'package:two_space_app/services/chat_service.dart';
import 'package:two_space_app/services/chat_backend_factory.dart';
import 'package:two_space_app/services/settings_service.dart';
import 'package:two_space_app/services/navigation_service.dart';
import 'package:two_space_app/config/ui_tokens.dart';
import 'package:two_space_app/widgets/user_avatar.dart';
import 'package:two_space_app/screens/call_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:two_space_app/services/chat_matrix_service.dart'; // Import ChatMatrixService
import 'package:two_space_app/services/auth_service.dart'; // Import AuthService
import 'package:two_space_app/screens/edit_profile_screen.dart'; // Import EditProfileScreen
import 'package:two_space_app/services/native_throat_service.dart'; // Import NativeThroatService
import 'dart:convert';

// Social media data structure
class SocialMediaPlatform {
  final String name;
  final IconData icon;
  final String? baseUrl; // Base URL if it's a profile link, e.g., "https://twitter.com/"
  final String key; // Key to look up in user data

  const SocialMediaPlatform({
    required this.name,
    required this.icon,
    this.baseUrl,
    required this.key,
  });
}

const List<SocialMediaPlatform> _socialMediaPlatforms = [
  SocialMediaPlatform(name: 'Spotify', icon: Icons.music_note, baseUrl: 'https://open.spotify.com/user/', key: 'spotify'),
  SocialMediaPlatform(name: 'X (Twitter)', icon: Icons.alternate_email, baseUrl: 'https://x.com/', key: 'x'),
  SocialMediaPlatform(name: 'Bandcamp', icon: Icons.album, baseUrl: 'https://bandcamp.com/', key: 'bandcamp'),
  SocialMediaPlatform(name: 'Instagram', icon: Icons.camera_alt, baseUrl: 'https://instagram.com/', key: 'instagram'),
  SocialMediaPlatform(name: 'Pinterest', icon: Icons.push_pin, baseUrl: 'https://pinterest.com/', key: 'pinterest'),
  SocialMediaPlatform(name: 'Facebook', icon: Icons.facebook, baseUrl: 'https://facebook.com/', key: 'facebook'),
  SocialMediaPlatform(name: 'VK', icon: Icons.people, baseUrl: 'https://vk.com/', key: 'vk'),
  SocialMediaPlatform(name: 'GitHub', icon: Icons.code, baseUrl: 'https://github.com/', key: 'github'),
  SocialMediaPlatform(name: 'GitLab', icon: Icons.code, baseUrl: 'https://gitlab.com/', key: 'gitlab'),
  SocialMediaPlatform(name: 'Reddit', icon: Icons.public, baseUrl: 'https://reddit.com/user/', key: 'reddit'), // Added Reddit
];

class ProfileScreen extends StatefulWidget {
  final String userId;
  final String? initialName;
  final String? initialAvatar;

  const ProfileScreen({super.key, required this.userId, this.initialName, this.initialAvatar});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  bool _loading = true;
  bool _actionLoading = false;
  bool _isMe = false;
  final ChatMatrixService _matrixService = ChatMatrixService();
  final AuthService _authService = AuthService();
  final NativeThroatService _nativeThroatService = NativeThroatService();
  Map<String, dynamic>? _nowPlaying;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadNowPlaying();
  }

  Future<void> _loadUser() async {
    try {
      final userInfo = await _matrixService.getUserInfo(widget.userId);
      final currentUserId = await _authService.getCurrentUserId();

      if (mounted) {
        setState(() {
          _user = userInfo;
          _isMe = (currentUserId == widget.userId);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user info: $e')),
        );
        setState(() {
          _loading = false;
          _user = null;
        });
      }
    }
  }

  void _loadNowPlaying() {
    try {
      final nowPlayingData = _nativeThroatService.getNowPlaying();
      setState(() {
        _nowPlaying = nowPlayingData;
      });
    } catch (e) {
      // It's okay if this fails, it's a non-critical feature
      print('Could not get "Now Playing" info: $e');
    }
  }

  String _displayName() {
    try {
      if (_user == null) return widget.initialName ?? widget.userId;
      // Matrix displayname is usually directly in the map, not under 'prefs'
      final name = (_user!['displayname'] as String?)?.trim();
      if (name != null && name.isNotEmpty) return name;
    } catch (_) {}
    return widget.initialName ?? widget.userId;
  }

  String? _avatarUrl() {
    try {
      if (_user != null) {
        // Matrix avatar_url is usually directly in the map
        return (_user!['avatar_url'] as String?);
      }
    } catch (_) {}
    return widget.initialAvatar;
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _displayName();
    final avatar = _avatarUrl();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Профиль'),
        centerTitle: false,
        actions: [
          if (_isMe) // Show edit button only for own profile
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.of(context).pushNamed(
                  '/edit_profile',
                  arguments: {
                    'userId': widget.userId,
                    'profileData': _user ?? {},
                  },
                );
                if (result == true) {
                  // If profile was saved, reload data
                  _loadUser();
                }
              },
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(UITokens.space),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: UserAvatar(key: ValueKey(avatar ?? 'noavatar_${widget.userId}'), avatarUrl: avatar, name: name, radius: 56),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(child: Text(name, style: Theme.of(context).textTheme.headlineSmall)),
                  const SizedBox(height: 6),
                  if (_user != null && _user!['displayname'] != null) ...[
                    Center(child: Text('@${_user!['displayname']}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withAlpha((0.7 * 255).round())))),
                    const SizedBox(height: 16),
                  ],
                  // "Now Playing" widget
                  if (_nowPlaying != null)
                    _buildNowPlayingWidget(),
                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    ElevatedButton.icon(
                          onPressed: _actionLoading ? null : () async {
                        setState(() => _actionLoading = true);
                        final messenger = ScaffoldMessenger.of(context);
                        final navState = appNavigatorKey.currentState;
                        try {
                          final cs = createChatBackend();
                          final m = await cs.getOrCreateDirectChat(widget.userId);
                          final chat = Chat.fromMap(m);
                          if (!mounted) return;
                          // Return created/selected chat to caller so HomeScreen can react (select on two-pane)
                          navState?.pop(chat);
                        } catch (e) {
                          messenger.showSnackBar(SnackBar(content: Text('Не удалось создать чат: $e')));
                        } finally {
                          if (mounted) setState(() => _actionLoading = false);
                        }
                      },
                      icon: _actionLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.chat_bubble_outline),
                      label: const Text('Написать'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        // start call: derive a room name and open CallScreen
                        final roomName = 'call_${widget.userId.replaceAll(RegExp(r"[^a-zA-Z0-9_-]"), '_')}_${DateTime.now().millisecondsSinceEpoch}';
                        // This part needs to be updated to use CallService
                        // For now, it's a placeholder
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Call functionality not fully integrated here')),
                        );
                        // Navigator.of(context).push(MaterialPageRoute(builder: (_) => CallScreen(room: roomName, isVideo: true, displayName: _displayName(), avatarUrl: _avatarUrl())));
                      },
                      icon: const Icon(Icons.call_outlined),
                      label: const Text('Позвонить'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert),
                      label: const Text('Ещё'),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  // Social Media Links
                  if (_user != null && _socialMediaPlatforms.any((platform) => _user![platform.key] != null))
                    Card(
                      elevation: UITokens.cardElevation,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(UITokens.corner)),
                      margin: const EdgeInsets.only(bottom: UITokens.space),
                      child: Padding(
                        padding: const EdgeInsets.all(UITokens.space),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Социальные сети', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: _socialMediaPlatforms.map((platform) {
                                final handleOrUrl = _user![platform.key] as String?;
                                if (handleOrUrl != null && handleOrUrl.isNotEmpty) {
                                  String urlToLaunch = handleOrUrl;
                                  if (!handleOrUrl.startsWith('http') && platform.baseUrl != null) {
                                    urlToLaunch = '${platform.baseUrl}$handleOrUrl';
                                  }
                                  return Tooltip(
                                    message: platform.name,
                                    child: IconButton(
                                      icon: Icon(platform.icon, color: Theme.of(context).colorScheme.primary),
                                      onPressed: () => _launchUrl(urlToLaunch),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Card(
                    elevation: UITokens.cardElevation,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(UITokens.corner)),
                    child: Padding(
                      padding: const EdgeInsets.all(UITokens.space),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _buildInfoRow('О себе', (_user != null) ? (_user!['about'] ?? '') : ''), // Changed from prefs?['about']
                        const Divider(),
                        // Email: show depending on user's preferences or local settings if viewing own profile
                        if (_user != null)
                          Builder(builder: (c) {
                            // Assuming email is directly in _user map for Matrix
                            final email = (_user!['email'] as String?) ?? '';
                            final shouldShowEmail = (_isMe ? true : false); // Matrix doesn't have a direct 'showEmail' pref in profile
                            if (email.isNotEmpty && shouldShowEmail) {
                              return Column(children: [
                              _buildInfoRow('Email', email),
                              const Divider(),
                            ]);
                            }
                            return const SizedBox.shrink();
                          }),

                        // Phone: similar visibility rules
                        if (_user != null)
                          Builder(builder: (c) {
                            // Assuming phone is directly in _user map for Matrix
                            final phone = (_user!['phone'] as String?) ?? '';
                            final shouldShowPhone = (_isMe ? true : false); // Matrix doesn't have a direct 'showPhone' pref in profile
                            if (phone.isNotEmpty && shouldShowPhone) {
                              return Column(children: [
                              _buildInfoRow('Телефон', phone),
                              const Divider(),
                            ]);
                            }
                            return const SizedBox.shrink();
                          }),

                        _buildInfoRow('Никнейм', (_user != null) ? (_user!['displayname'] ?? '') : ''), // Changed from prefs?['nickname']
                        const Divider(),
                        _buildInfoRow('Место', (_user != null) ? (_user!['location'] ?? '') : ''),
                        const Divider(),
                        _buildInfoRow('День рождения', (_user != null) ? (_user!['birthday'] ?? '') : ''),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildNowPlayingWidget() {
    return Card(
      elevation: UITokens.cardElevation,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(UITokens.corner)),
      margin: const EdgeInsets.only(bottom: UITokens.space),
      child: Padding(
        padding: const EdgeInsets.all(UITokens.space),
        child: Row(
          children: [
            const Icon(Icons.music_note, color: Colors.green),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _nowPlaying!['track']!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'by ${_nowPlaying!['artist']!}',
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value?.isNotEmpty == true ? value! : '-', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 4),
  Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withAlpha((0.6 * 255).round()))),
      ]),
    );
  }
}
