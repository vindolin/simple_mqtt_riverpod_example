import 'dart:convert';
import 'dart:io';
import 'dart:developer' as d;

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:nanoid/nanoid.dart';

import 'config.dart' as config;

part 'mqtt_providers.g.dart';

const subscribeTopics = [
  'echo/#',
  'another/topic',
];

class MqttMessages extends _$MqttMessages {
  @override
  dynamic build(topic) {
    return null;
  }
}

@Riverpod(keepAlive: true)
class MqttClient extends _$MqttClient {
  late MqttServerClient client;

  final clientIdentifier = 'demo${nanoid()}';

  @override
  build() {
    ref.onDispose(() {
      disconnect();
    });
  }

  FutureOr connect() async {
    client = MqttServerClient.withPort(
      config.mqttServerAddress,
      clientIdentifier,
      config.mqttServerPort,
    );

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

    client.autoReconnect = true;

    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;

    mqtt.MqttClientConnectionStatus? mqttConnectionStatus =
        await client.connect(config.mqttServerUserName, config.mqttServerPassword).catchError(
      (error) {
        return null;
      },
    );

    for (var topic in subscribeTopics) {
      client.subscribe(topic, mqtt.MqttQos.atLeastOnce);
    }

    return mqttConnectionStatus?.state ?? mqtt.MqttConnectionState.faulted;
  }

  void disconnect() {
    client.disconnect();
  }

  void onConnected() {
    d.log('connected');

    for (var topic in subscribeTopics) {
      client.subscribe(topic, mqtt.MqttQos.atLeastOnce);
    }

    client.pongCallback = () {
      d.log('ping response client callback invoked');
    };

    client.updates?.listen(
      (List<mqtt.MqttReceivedMessage<mqtt.MqttMessage>> messages) {
        // iterate over all new messages
        for (mqtt.MqttReceivedMessage mqttReceivedMessage in messages) {
          // get the topic
          final topic = mqttReceivedMessage.topic;

          // get the message
          final payload = mqttReceivedMessage.payload as mqtt.MqttPublishMessage;
          final String message = const Utf8Decoder().convert(payload.payload.message);

          dynamic payloadDecoded;
          // try to parse the payload as json
          try {
            payloadDecoded = jsonDecode(message);
            // if the payload is not json, it's probably a string
          } on FormatException catch (_) {
            payloadDecoded = message;
          }

          ref.read(mqttMessagesProvider(mqttReceivedMessage.topic).notifier).state = payloadDecoded;

          d.log('received topic: "$topic", message: "$message"');
        }
      },
    );
  }

  // generic publish function
  void publish(String topic, String payload, {bool retain = false}) {
    d.log('publishing $topic: $payload');
    final builder = mqtt.MqttClientPayloadBuilder();
    builder.addString(payload);
    client.publishMessage(topic, mqtt.MqttQos.atLeastOnce, builder.payload!, retain: retain);
  }

  void onDisconnected() {}
}
