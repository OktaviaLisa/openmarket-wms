class Supplier {
  final int id;
  final String name;
  final String contactPerson;
  final String phone;
  final String email;

  Supplier({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.phone,
    required this.email,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'],
      name: json['name'] ?? '',
      contactPerson: json['contact_person'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class Customer {
  final int id;
  final String name;
  final String contactPerson;
  final String phone;
  final String email;

  Customer({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.phone,
    required this.email,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'] ?? '',
      contactPerson: json['contact_person'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class Unit {
  final int id;
  final String name;
  final String symbol;

  Unit({
    required this.id,
    required this.name,
    required this.symbol,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'],
      name: json['name'] ?? '',
      symbol: json['symbol'] ?? '',
    );
  }
}

class Location {
  final int id;
  final String name;
  final String code;
  final String description;

  Location({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class Receiving {
  final int id;
  final String documentNumber;
  final DateTime receiveDate;
  final int quantity;
  final String remarks;
  final DateTime createdAt;
  final String supplierName;
  final String productName;
  final String unitSymbol;
  final String locationName;

  Receiving({
    required this.id,
    required this.documentNumber,
    required this.receiveDate,
    required this.quantity,
    required this.remarks,
    required this.createdAt,
    required this.supplierName,
    required this.productName,
    required this.unitSymbol,
    required this.locationName,
  });

  factory Receiving.fromJson(Map<String, dynamic> json) {
    return Receiving(
      id: json['id'],
      documentNumber: json['document_number'] ?? '',
      receiveDate: DateTime.parse(json['receive_date']),
      quantity: json['quantity'] ?? 0,
      remarks: json['remarks'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      supplierName: json['supplier_name'] ?? '',
      productName: json['product_name'] ?? '',
      unitSymbol: json['unit_symbol'] ?? '',
      locationName: json['location_name'] ?? '',
    );
  }
}

class Issuing {
  final int id;
  final String documentNumber;
  final DateTime issueDate;
  final int quantity;
  final String remarks;
  final DateTime createdAt;
  final String customerName;
  final String productName;
  final String unitSymbol;
  final String locationName;

  Issuing({
    required this.id,
    required this.documentNumber,
    required this.issueDate,
    required this.quantity,
    required this.remarks,
    required this.createdAt,
    required this.customerName,
    required this.productName,
    required this.unitSymbol,
    required this.locationName,
  });

  factory Issuing.fromJson(Map<String, dynamic> json) {
    return Issuing(
      id: json['id'],
      documentNumber: json['document_number'] ?? '',
      issueDate: DateTime.parse(json['issue_date']),
      quantity: json['quantity'] ?? 0,
      remarks: json['remarks'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      customerName: json['customer_name'] ?? '',
      productName: json['product_name'] ?? '',
      unitSymbol: json['unit_symbol'] ?? '',
      locationName: json['location_name'] ?? '',
    );
  }
}

class ReceivingRequest {
  final String receiveDate;
  final int supplierId;
  final int productId;
  final int quantity;
  final int unitId;
  final int locationId;
  final String remarks;

  ReceivingRequest({
    required this.receiveDate,
    required this.supplierId,
    required this.productId,
    required this.quantity,
    required this.unitId,
    required this.locationId,
    required this.remarks,
  });

  Map<String, dynamic> toJson() {
    return {
      'receive_date': receiveDate,
      'supplier_id': supplierId,
      'product_id': productId,
      'quantity': quantity,
      'unit_id': unitId,
      'location_id': locationId,
      'remarks': remarks,
    };
  }
}

class IssuingRequest {
  final String issueDate;
  final int customerId;
  final int productId;
  final int quantity;
  final int unitId;
  final int locationId;
  final String remarks;

  IssuingRequest({
    required this.issueDate,
    required this.customerId,
    required this.productId,
    required this.quantity,
    required this.unitId,
    required this.locationId,
    required this.remarks,
  });

  Map<String, dynamic> toJson() {
    return {
      'issue_date': issueDate,
      'customer_id': customerId,
      'product_id': productId,
      'quantity': quantity,
      'unit_id': unitId,
      'location_id': locationId,
      'remarks': remarks,
    };
  }
}