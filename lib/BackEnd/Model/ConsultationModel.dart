
// Model/ConsultationModel.dart (Assuming this is in a Model subfolder)
class ConsultationModel {
  final ConsultationHeader header;
  final List<ImmunizationDetail> detail;

  ConsultationModel({
    required this.header,
    required this.detail,
  });

  Map<String, dynamic> toJson() => {
    'header': header.toJson(),
    'detail': detail.map((e) => e.toJson()).toList(),
  };

  factory ConsultationModel.fromJson(Map<String, dynamic> json) {
    return ConsultationModel(
      header: ConsultationHeader.fromJson(json['header'] as Map<String, dynamic>),
      detail: (json['detail'] as List<dynamic>)
          .map((e) => ImmunizationDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
class ConsultationHeader {
  final int consultId;
  final int customerId;
  final int petId; // ✅ Add this line
  final String customerName;
  final String phone;
  final String petName;
  final String species;
  final String breed;
  final String gender;
  final DateTime postingDate;
  final String historiesTreatment;
  final DateTime createDate;

  ConsultationHeader({
    required this.consultId,
    required this.customerId,
    required this.petId, // ✅ Include in constructor
    required this.customerName,
    required this.phone,
    required this.petName,
    required this.species,
    required this.breed,
    required this.gender,
    required this.postingDate,
    required this.historiesTreatment,
    required this.createDate,
  });

  Map<String, dynamic> toJson() => {
    'ConsultId': consultId,
    'CustomerId': customerId,
    'PetId': petId, // ✅ Include in JSON
    'CustomerName': customerName,
    'Phone': phone,
    'PetName': petName,
    'Species': species,
    'Breed': breed,
    'Gender': gender,
    'PostingDate': postingDate.toIso8601String(),
    'HistoriesTreatment': historiesTreatment,
    'CreateDate': createDate.toIso8601String(),
  };

  factory ConsultationHeader.fromJson(Map<String, dynamic> json) {
    return ConsultationHeader(
      consultId: json['ConsultId'] as int,
      customerId: json['CustomerId'] as int,
      petId: json['PetId'] ?? 0, // ✅ Safely decode petId
      customerName: json['CustomerName'] as String,
      phone: json['Phone'] as String,
      petName: json['PetName'] as String,
      species: json['Species'] as String,
      breed: json['Breed'] as String,
      gender: json['Gender'] as String,
      postingDate: DateTime.parse(json['PostingDate'] as String),
      historiesTreatment: json['HistoriesTreatment'] as String,
      createDate: DateTime.parse(json['CreateDate'] as String),
    );
  }
}

class ImmunizationDetail {
  final int immunId;
  final int consultId;
  final String immunizationType;
  final DateTime givenDate;
  final DateTime nextDueDate;
  final DateTime notifyDate;

  ImmunizationDetail({
    required this.immunId,
    required this.consultId,
    required this.immunizationType,
    required this.givenDate,
    required this.nextDueDate,
    required this.notifyDate,
  });

  Map<String, dynamic> toJson() => {
    'ImmunId': immunId,
    'ConsultId': consultId,
    'ImmunizationType': immunizationType,
    'GivenDate': givenDate.toIso8601String(),
    'NextDueDate': nextDueDate.toIso8601String(),
    'NotifyDate': notifyDate.toIso8601String(),
  };

  factory ImmunizationDetail.fromJson(Map<String, dynamic> json) {
    return ImmunizationDetail(
      immunId: json['ImmunId'] as int,
      consultId: json['ConsultId'] as int,
      immunizationType: json['ImmunizationType'] as String,
      givenDate: DateTime.parse(json['GivenDate'] as String),
      nextDueDate: DateTime.parse(json['NextDueDate'] as String),
      notifyDate: DateTime.parse(json['NotifyDate'] as String),
    );
  }
}

