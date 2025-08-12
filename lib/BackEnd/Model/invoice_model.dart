import 'dart:convert';

// Top-level response for fetching a list of invoices
class InvoiceResponse {
  final bool success;
  final String message;
  final List<Invoice> data;

  InvoiceResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory InvoiceResponse.fromJson(Map<String, dynamic> json) {
    return InvoiceResponse(
      success: json['success'],
      message: json['message'],
      data: List<Invoice>.from(json['data'].map((x) => Invoice.fromJson(x))),
    );
  }
}

// Represents a single complete invoice (header and details)
class Invoice {
  final InvoiceHeader header;
  final List<InvoiceDetail> detail;

  Invoice({
    required this.header,
    required this.detail,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      header: InvoiceHeader.fromJson(json['header']),
      detail: List<InvoiceDetail>.from(
          json['detail'].map((x) => InvoiceDetail.fromJson(x))),
    );
  }
  
  // Converts the Invoice object to a JSON map to send to the API
  Map<String, dynamic> toJson() {
    return {
      'header': header.toJson(),
      'detail': detail.map((item) => item.toJson()).toList(),
    };
  }
}

// Represents the main information of the invoice
class InvoiceHeader {
  final int invoiceId;
  final int consultId;
  final int customerId;
  final String customerName;
  final String phone;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final double subTotal;
  final double tax;
  final double discount;
  final double grandTotal;
  final String paymentStatus;
  final String note;
  final DateTime createDate;

  InvoiceHeader({
    required this.invoiceId,
    required this.consultId,
    required this.customerId,
    required this.customerName,
    required this.phone,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.subTotal,
    required this.tax,
    required this.discount,
    required this.grandTotal,
    required this.paymentStatus,
    required this.note,
    required this.createDate,
  });

  factory InvoiceHeader.fromJson(Map<String, dynamic> json) {
    return InvoiceHeader(
      invoiceId: json['InvoiceId'],
      consultId: json['ConsultId'],
      customerId: json['CustomerId'],
      customerName: json['CustomerName'],
      phone: json['Phone'],
      invoiceNumber: json['InvoiceNumber'],
      invoiceDate: DateTime.parse(json['InvoiceDate']),
      subTotal: json['SubTotal'].toDouble(),
      tax: json['Tax'].toDouble(),
      discount: json['Discount'].toDouble(),
      grandTotal: json['GrandTotal'].toDouble(),
      paymentStatus: json['PaymentStatus'],
      note: json['Note'],
      createDate: DateTime.parse(json['CreateDate']),
    );
  }

  // Converts the InvoiceHeader object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'InvoiceId': invoiceId,
      'ConsultId': consultId,
      'CustomerId': customerId,
      'CustomerName': customerName,
      'Phone': phone,
      'InvoiceNumber': invoiceNumber,
      'InvoiceDate': invoiceDate.toIso8601String(),
      'SubTotal': subTotal,
      'Tax': tax,
      'Discount': discount,
      'GrandTotal': grandTotal,
      'PaymentStatus': paymentStatus,
      'Note': note,
      'CreateDate': createDate.toIso8601String(),
    };
  }
}

// Represents a single line item in the invoice
class InvoiceDetail {
  final int invoiceDetailId;
  final int invoiceId;
  final int productId;
  final String code;
  final String description;
  final int qty;
  final double unitPrice;
  final double lineTotal;

  InvoiceDetail({
    required this.invoiceDetailId,
    required this.invoiceId,
    required this.productId,
    required this.code,
    required this.description,
    required this.qty,
    required this.unitPrice,
    required this.lineTotal,
  });

  factory InvoiceDetail.fromJson(Map<String, dynamic> json) {
    return InvoiceDetail(
      invoiceDetailId: json['InvoiceDetailId'],
      invoiceId: json['InvoiceId'],
      productId: json['ProductId'],
      code: json['Code'],
      description: json['Description'],
      qty: json['Qty'],
      unitPrice: json['UnitPrice'].toDouble(),
      lineTotal: json['LineTotal'].toDouble(),
    );
  }

  // Converts the InvoiceDetail object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'InvoiceDetailId': invoiceDetailId,
      'InvoiceId': invoiceId,
      'ProductId': productId,
      'Code': code,
      'Description': description,
      'Qty': qty,
      'UnitPrice': unitPrice,
      'LineTotal': lineTotal,
    };
  }
}