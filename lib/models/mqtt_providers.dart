import 'dart:convert';
import 'dart:io';
import 'dart:developer' as d;

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:nanoid/nanoid.dart';

import 'config.dart' as config;

part 'mqtt_providers.g.dart';

const subscribeTopics = [
  'echo/#',
  'another/topic',
];

@riverpod
class MqttMessages extends _$MqttMessages {
  @override
  dynamic build(topic) {
    return null;
  }
}

@Riverpod(keepAlive: true)
class MqttClientConnectionState extends _$MqttClientConnectionState {
  @override
  MqttConnectionState build() {
    return MqttConnectionState.faulted;
  }
}

@Riverpod(keepAlive: true) // keep the provider alive when the instantiating widget gets disposed
class MqttClient extends _$MqttClient {
  late MqttServerClient client;

  final clientIdentifier = 'demo${nanoid()}';

  @override
  build() {
    ref.onDispose(() {
      disconnect();
    });
  }

  connect() async {
    client = MqttServerClient.withPort(
      config.mqttServerAddress,
      clientIdentifier,
      config.mqttServerPort,
    );

    client.autoReconnect = true;

    // if you want to use a secure connection you have to put the certificates in the
    // assets/certs folder and set useCerts to true in the config.dart file
    if (config.useCerts) {
      final cert = await rootBundle.load('assets/certs/ca.crt');
      final clientCrt = await rootBundle.load('assets/certs/client.crt');
      final clientKey = await rootBundle.load('assets/certs/client.key');
      SecurityContext context;

      try {
        context = SecurityContext.defaultContext
          ..setTrustedCertificatesBytes(cert.buffer.asUint8List())
          ..setClientAuthoritiesBytes(cert.buffer.asInt8List())
          ..useCertificateChainBytes(clientCrt.buffer.asInt8List())
          ..usePrivateKeyBytes(clientKey.buffer.asInt8List());
      } catch (_) {
        // print(_);
        // already set
        context = SecurityContext.defaultContext;
      }

      client.securityContext = context;
      client.secure = true;
    }

    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;

    MqttClientConnectionStatus? mqttConnectionStatus =
        await client.connect(config.mqttServerUserName, config.mqttServerPassword).catchError(
      (error) {
        return null;
      },
    );

    if (mqttConnectionStatus == null) return MqttConnectionState.faulted;

    if (mqttConnectionStatus.state == MqttConnectionState.connected) {
      /// subscribe to all topics
      for (var topic in subscribeTopics) {
        client.subscribe(topic, MqttQos.atLeastOnce);
      }
    }

    return mqttConnectionStatus.state;
  }

  void disconnect() {
    d.log('disconnected');
    client.disconnect();
    ref.read(mqttClientConnectionStateProvider.notifier).state = MqttConnectionState.connected;
  }

  void onConnected() {
    d.log('connected');

    for (var topic in subscribeTopics) {
      client.subscribe(topic, MqttQos.atLeastOnce);
    }

    client.pongCallback = () {
      d.log('ping response client callback invoked');
    };

    client.updates?.listen(
      (List<MqttReceivedMessage<MqttMessage>> messages) {
        // iterate over all new messages
        for (MqttReceivedMessage mqttReceivedMessage in messages) {
          // get the topic
          final topic = mqttReceivedMessage.topic;

          // get the message
          final payload = mqttReceivedMessage.payload as MqttPublishMessage;
          final String message = const Utf8Decoder().convert(payload.payload.message);

          // try to parse the payload as json
          dynamic payloadDecoded;
          try {
            payloadDecoded = jsonDecode(message);
            d.log('received topic: "$topic", message<dynamic>: "$message"');

            // if that fails, it's probably a string
          } on FormatException catch (_) {
            payloadDecoded = message;
            d.log('received topic: "$topic", message<string>: "$message"');
          }

          // add the message to the family provider for the topic
          ref.read(mqttMessagesProvider(mqttReceivedMessage.topic).notifier).state = payloadDecoded;
        }
      },
    );
    ref.read(mqttClientConnectionStateProvider.notifier).state = MqttConnectionState.connected;
  }

  // generic publish function
  void publish(String topic, String payload, {bool retain = false, MqttQos qos = MqttQos.atLeastOnce}) {
    d.log('publishing "$topic": "$payload" retain: "$retain"');
    final builder = MqttClientPayloadBuilder();
    builder.addString(payload);
    client.publishMessage(
      topic,
      qos,
      builder.payload!,
      retain: retain,
    );
  }

  void onDisconnected() {}
}
