class PostProduct {
  final String code;
  final String description;
  final int qty;
  final double? costPrice;
  final double? unitPrice;
  final DateTime? expireDate;
  final String? type;

  PostProduct({
    required this.code,
    required this.description,
    this.qty = 0,
    this.costPrice,
    this.unitPrice,
    this.expireDate,
    this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'Code': code,
      'Description': description,
      'Qty': qty,
      'CostPrice': costPrice,
      'UnitPrice': unitPrice,
      'ExpireDate': expireDate?.toIso8601String(),
      'Type': type,
    };
  }
}