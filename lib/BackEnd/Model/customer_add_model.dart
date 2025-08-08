class CustomerHeader {
  final int customerId;
  final String fullName;
  final String? title;
  final String email;
  final String phone;
  final String address;
  final DateTime createDate;

  CustomerHeader({
    required this.customerId,
    required this.fullName,
    this.title,
    required this.email,
    required this.phone,
    required this.address,
    required this.createDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'CustomerId': customerId,
      'FullName': fullName,
      'Title': title,
      'Email': email,
      'Phone': phone,
      'Address': address,
      'CreateDate': createDate.toIso8601String(),
    };
  }
}
class PetDetail {
  String petName;
  String species;
  String breed;
  String gender;
  DateTime birthDate;
  bool spayedNeutered;
  double weight;
  String color;

  PetDetail({
    required this.petName,
    required this.species,
    required this.breed,
    required this.gender,
    required this.birthDate,
    required this.spayedNeutered,
    required this.weight,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
        "PetName": petName,
        "Species": species,
        "Breed": breed,
        "Gender": gender,
        "BirthDate": birthDate.toIso8601String(),
        "SpayedNeutered": spayedNeutered,
        "Weight": weight,
        "Color": color,
      };
}

class CustomerRequestModel {
  CustomerHeader header;
  List<PetDetail> detail;

  CustomerRequestModel({
    required this.header,
    required this.detail,
  });

  Map<String, dynamic> toJson() => {
        "header": header.toJson(),
        "detail": detail.map((e) => e.toJson()).toList(),
      };
}
