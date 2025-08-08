class ImmunizationTracking {
  int? id;
  int? consultId;
  String vaccine;
  DateTime dueDate;

  ImmunizationTracking({
    this.id,
    this.consultId,
    required this.vaccine,
    required this.dueDate,
  });

  factory ImmunizationTracking.fromJson(Map<String, dynamic> json) {
    return ImmunizationTracking(
      id: json['Id'],
      consultId: json['ConsultId'],
      vaccine: json['Vaccine'],
      dueDate: DateTime.parse(json['DueDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'ConsultId': consultId,
      'Vaccine': vaccine,
      'DueDate': dueDate.toIso8601String(),
    };
  }
}