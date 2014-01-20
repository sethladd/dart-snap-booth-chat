library persistable;

import 'dart:async' show Future, Stream;
import 'package:lawndart/lawndart.dart' show Store;
import 'package:logging/logging.dart' show Logger;
import 'package:serialization/serialization.dart' show Serialization;
import 'dart:convert' show JSON;

final Logger log = new Logger("persistence");

const String serialized = "__SERIALIZED";

Map<Type, Store> _stores = <Type, Store>{};

/**
 * Open a store for each type. The future completes when all databases
 * have been opened.
 *
 * TODO: can we auto-detect all the types that want persistence?
 */
Future init(String dbName, List<Type> types) {
  return Future.forEach(types, (type) {
    var store = new Store(dbName, type.toString());
    _stores[type] = store;
    return store.open();
  });
}

bool isInitialized(Type type) => _stores[type] == null ? false : _stores[type].isOpen;

int _counter = 0;
final String _idOffset = new DateTime.now().millisecondsSinceEpoch.toString();
String _nextId() => _idOffset + '-' + (_counter++).toString();

final Serialization _serializer = new Serialization();

abstract class Persistable {

  String id;

  static Future load(String id, Type type) {

    if (!isInitialized(type)) {
      throw new StateError('Store is not initialized with type $type');
    }

    return _stores[type].getByKey(id).then((String serialized) {
      if (serialized == null) {
        return null;
      } else {
        return _deserialize(serialized);
      }
    });
  }

  static Stream all(Type type) {
    if (!isInitialized(type)) {
      throw new StateError('Store is not initialized with type $type');
    }

    return _stores[type].all().map((String serialized) => _deserialize(serialized));
  }

  static dynamic _deserialize(String serialized) {
    Map data = JSON.decode(serialized);
    return _serializer.read(data);
  }

  /**
   * Completes with the ID of the object just stored into persistence.
   */
  Future<String> store() {
    if (!isInitialized(runtimeType)) {
      throw new StateError('Store is not initialized with type $runtimeType');
    }

    if (id == null) {
      id = _nextId();
    }

    // TODO do I need to encode to JSON? Can we store maps and lists of
    // core types?

    return _stores[runtimeType].save(JSON.encode(_serializer.write(this)), id);
  }

  Future delete() {
    if (!isInitialized(runtimeType)) {
      throw new StateError('Store is not initialized with type $runtimeType');
    }

    return _stores[runtimeType].removeByKey(id);
  }

  static Future clear(Type type) {
    if (!isInitialized(type)) {
      throw new StateError('Store is not initialized with type $type');
    }

    return _stores[type].nuke();
  }

}
