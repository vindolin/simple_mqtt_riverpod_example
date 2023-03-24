import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/models/mqtt_providers.dart';

void main() async {
  runApp(
    const ProviderScope(
      child: MqttDemo(),
    ),
  );
}

class MqttDemo extends ConsumerStatefulWidget {
  const MqttDemo({super.key});
  @override
  ConsumerState<MqttDemo> createState() => _MqttDemoState();
}

class _MqttDemoState extends ConsumerState<MqttDemo> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    ref.watch(mqttClientProvider.notifier).connect();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'MQTT with Riverpod',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final echo = ref.watch(mqttMessagesProvider('echo'));
    return Scaffold(
      appBar: AppBar(
        title: const Text('MQTT with Riverpod'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  hintText:
                      'Enter a message', // if you enter 0 or 1 this will display a switch, otherwise it shows the echo text.
                ),
                onSubmitted: (value) {
                  ref.watch(mqttClientProvider.notifier).publish('echo', value);
                },
              ),
              echo.runtimeType == int ? Switch(value: echo == 1, onChanged: (_) {}) : Text('Echo: $echo'),
            ],
          ),
        ),
      ),
    );
  }
}
