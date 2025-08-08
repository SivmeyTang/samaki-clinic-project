class ProductModel {
  final int productId;
  final String code;
  final String description;
  final int qty;
  final double costPrice;
  final double unitPrice;
  final DateTime createDate;
  final DateTime? UpdateDate;
  final DateTime expireDate;
  final String status;
  final String type;
  final String? imageUrl;

  ProductModel({
    required this.productId,
    required this.code,
    required this.description,
    required this.qty,
    required this.costPrice,
    required this.unitPrice,
    required this.createDate,
    required this.UpdateDate,
    required this.expireDate,
    required this.status,
    required this.type,
    required this.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['ProductId'] as int,
      code: json['Code'] as String,
      description: json['Description'] as String,
      qty: json['Qty'] as int,
      costPrice: (json['CostPrice'] as num).toDouble(),
      unitPrice: (json['UnitPrice'] as num).toDouble(),
      createDate: DateTime.parse(json['CreateDate'] as String),
      UpdateDate: json['UpdateDate'] != null
          ? DateTime.parse(json['UpdateDate'] as String)
          : null,
      expireDate: DateTime.parse(json['ExpireDate'] as String),
      status: json['Status'] as String,
      type: json['Type'] as String,
      imageUrl: json['ImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ProductId': productId,
      'Code': code,
      'Description': description,
      'Qty': qty,
      'CostPrice': costPrice,
      'UnitPrice': unitPrice,
      'CreateDate': createDate.toIso8601String(),
      'UpdateDate': UpdateDate?.toIso8601String(),
      'ExpireDate': expireDate.toIso8601String(),
      'Status': status,
      'Type': type,
      'ImageUrl': imageUrl,
    };
  }
}
