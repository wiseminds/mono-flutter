import 'dart:convert';

class MonoCustomer {
  final MonoExistingCustomerModel? existingCustomer;
  final MonoNewCustomerModel? newCustomer;

  const MonoCustomer({
    this.existingCustomer,
    this.newCustomer,
  });
}

class MonoExistingCustomerModel {
  final String id;

  const MonoExistingCustomerModel({
    required this.id,
  });

  MonoExistingCustomerModel copyWith({
    String? id,
  }) {
    return MonoExistingCustomerModel(
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
    };
  }

  factory MonoExistingCustomerModel.fromMap(Map<String, dynamic> map) {
    return MonoExistingCustomerModel(
      id: map['id'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory MonoExistingCustomerModel.fromJson(String source) =>
      MonoExistingCustomerModel.fromMap(json.decode(source));

  @override
  String toString() => 'MonoExistingCustomerModel(id: $id)';
}

class MonoNewCustomerModel {
  final String name;
  final String email;
  final MonoNewCustomerIdentity? identity;

  const MonoNewCustomerModel({
    required this.name,
    required this.email,
    this.identity,
  });

  MonoNewCustomerModel copyWith({
    String? name,
    String? email,
    MonoNewCustomerIdentity? identity,
  }) {
    return MonoNewCustomerModel(
      name: name ?? this.name,
      email: email ?? this.email,
      identity: identity ?? this.identity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      if (identity != null) 'identity': identity!.toMap(),
    };
  }

  factory MonoNewCustomerModel.fromMap(Map<String, dynamic> map) {
    return MonoNewCustomerModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      identity: map['identity'] != null
          ? MonoNewCustomerIdentity.fromMap(map['identity'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory MonoNewCustomerModel.fromJson(String source) =>
      MonoNewCustomerModel.fromMap(json.decode(source));

  @override
  String toString() =>
      'MonoNewCustomerModel(name: $name, email: $email, identity: $identity)';
}

class MonoNewCustomerIdentity {
  final String type;
  final String number;
  const MonoNewCustomerIdentity({
    required this.type,
    required this.number,
  });

  MonoNewCustomerIdentity copyWith({
    String? type,
    String? number,
  }) {
    return MonoNewCustomerIdentity(
      type: type ?? this.type,
      number: number ?? this.number,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'number': number,
    };
  }

  factory MonoNewCustomerIdentity.fromMap(Map<String, dynamic> map) {
    return MonoNewCustomerIdentity(
      type: map['type'] ?? '',
      number: map['number'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory MonoNewCustomerIdentity.fromJson(String source) =>
      MonoNewCustomerIdentity.fromMap(json.decode(source));

  @override
  String toString() => 'MonoNewCustomerIdentity(type: $type, number: $number)';
}

extension MonoCustomerToJson on MonoCustomer {
  Map<String, dynamic> toMap() {
    return existingCustomer?.toMap() ?? newCustomer?.toMap() ?? {};
  }

  String toJson() => json.encode(toMap());
}
