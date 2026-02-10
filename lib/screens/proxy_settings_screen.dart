import 'package:flutter/material.dart';
import 'package:two_space_app/services/settings_service.dart';
import 'package:two_space_app/config/ui_tokens.dart';

class ProxySettingsScreen extends StatefulWidget {
  const ProxySettingsScreen({super.key});

  @override
  State<ProxySettingsScreen> createState() => _ProxySettingsScreenState();
}

class _ProxySettingsScreenState extends State<ProxySettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _hostController;
  late TextEditingController _portController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  bool _proxyEnabled = false;
  AudioPlayerType _selectedPlayer = AudioPlayerType.internal;

  @override
  void initState() {
    super.initState();
    final proxySettings = SettingsService.proxySettings;
    _proxyEnabled = proxySettings['enabled'] ?? false;
    _hostController = TextEditingController(text: proxySettings['host'] ?? '');
    _portController = TextEditingController(text: proxySettings['port'] ?? '');
    _usernameController = TextEditingController(text: proxySettings['username'] ?? '');
    _passwordController = TextEditingController(text: proxySettings['password'] ?? '');
    _selectedPlayer = SettingsService.audioPlayerType;
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      final proxySettings = {
        'enabled': _proxyEnabled,
        'host': _hostController.text.trim(),
        'port': _portController.text.trim(),
        'username': _usernameController.text.trim(),
        'password': _passwordController.text.trim(),
      };
      await SettingsService.saveProxySettings(proxySettings);
      await SettingsService.saveAudioPlayerType(_selectedPlayer);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved. App restart may be required.')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proxy & Audio Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UITokens.space),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Proxy Settings', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text('Enable Proxy'),
                value: _proxyEnabled,
                onChanged: (value) {
                  setState(() {
                    _proxyEnabled = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _hostController,
                decoration: const InputDecoration(
                  labelText: 'Proxy Host',
                  border: OutlineInputBorder(),
                ),
                enabled: _proxyEnabled,
                validator: (value) {
                  if (_proxyEnabled && (value == null || value.isEmpty)) {
                    return 'Host cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _portController,
                decoration: const InputDecoration(
                  labelText: 'Proxy Port',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                enabled: _proxyEnabled,
                validator: (value) {
                  if (_proxyEnabled && (value == null || value.isEmpty)) {
                    return 'Port cannot be empty';
                  }
                  if (_proxyEnabled && int.tryParse(value!) == null) {
                    return 'Invalid port number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username (optional)',
                  border: OutlineInputBorder(),
                ),
                enabled: _proxyEnabled,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password (optional)',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                enabled: _proxyEnabled,
              ),
              const Divider(height: 40),
              Text('Audio Player Settings', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              DropdownButtonFormField<AudioPlayerType>(
                value: _selectedPlayer,
                decoration: const InputDecoration(
                  labelText: 'Preferred Audio Player',
                  border: OutlineInputBorder(),
                ),
                items: AudioPlayerType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPlayer = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
