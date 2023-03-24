// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mqtt_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mqttMessagesHash() => r'47b4140dfcc8dbbe7845ee3b5811cc0297e17017';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$MqttMessages extends BuildlessNotifier<dynamic> {
  late final dynamic topic;

  dynamic build(
    dynamic topic,
  );
}

/// See also [MqttMessages].
@ProviderFor(MqttMessages)
const mqttMessagesProvider = MqttMessagesFamily();

/// See also [MqttMessages].
class MqttMessagesFamily extends Family<dynamic> {
  /// See also [MqttMessages].
  const MqttMessagesFamily();

  /// See also [MqttMessages].
  MqttMessagesProvider call(
    dynamic topic,
  ) {
    return MqttMessagesProvider(
      topic,
    );
  }

  @override
  MqttMessagesProvider getProviderOverride(
    covariant MqttMessagesProvider provider,
  ) {
    return call(
      provider.topic,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'mqttMessagesProvider';
}

/// See also [MqttMessages].
class MqttMessagesProvider extends NotifierProviderImpl<MqttMessages, dynamic> {
  /// See also [MqttMessages].
  MqttMessagesProvider(
    this.topic,
  ) : super.internal(
          () => MqttMessages()..topic = topic,
          from: mqttMessagesProvider,
          name: r'mqttMessagesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mqttMessagesHash,
          dependencies: MqttMessagesFamily._dependencies,
          allTransitiveDependencies:
              MqttMessagesFamily._allTransitiveDependencies,
        );

  final dynamic topic;

  @override
  bool operator ==(Object other) {
    return other is MqttMessagesProvider && other.topic == topic;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, topic.hashCode);

    return _SystemHash.finish(hash);
  }

  @override
  dynamic runNotifierBuild(
    covariant MqttMessages notifier,
  ) {
    return notifier.build(
      topic,
    );
  }
}

String _$mqttClientHash() => r'719e6f480a28d4d38fc11e53df5b2755c83074f7';

/// See also [MqttClient].
@ProviderFor(MqttClient)
final mqttClientProvider = NotifierProvider<MqttClient, dynamic>.internal(
  MqttClient.new,
  name: r'mqttClientProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$mqttClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MqttClient = Notifier<dynamic>;
// ignore_for_file: unnecessary_raw_strings, subtype_of_sealed_class, invalid_use_of_internal_member, do_not_use_environment, prefer_const_constructors, public_member_api_docs, avoid_private_typedef_functions
