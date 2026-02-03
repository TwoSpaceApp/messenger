import 'package:flutter/material.dart';
import 'package:two_space_app/widgets/screen_background.dart';
import 'package:two_space_app/widgets/glass_card.dart';

class CallsScreen extends StatelessWidget {
  const CallsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               Padding(
                 padding: const EdgeInsets.all(16.0),
                 child: Text('Звонки', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
               ),
               Expanded(
                 child: ListView.builder(
                   itemCount: 5,
                   itemBuilder: (c, i) => Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                     child: GlassCard(
                        child: ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text('Контакт '),
                          subtitle: Text(i % 2 == 0 ? 'Входящий' : 'Исходящий'),
                          trailing: Icon(i % 2 == 0 ? Icons.call_received : Icons.call_made, color: i % 2 == 0 ? Colors.red : Colors.green),
                        ),
                     ),
                   ),
                 ),
               ),
            ],
          ),
        ),
      ),
    );
  }
}
