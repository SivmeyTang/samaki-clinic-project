// lib/models/customer_models.dart

import 'dart:convert';

// --- Pet Model (for the "detail" part) ---
class PetModel {
  final int petId;
  final int customerId;
  final String petName;
  final String species;
  final String breed;
  final String gender;
  final DateTime birthDate;
  final bool spayedNeutered;
  final double weight;
  final String color;
  final DateTime createDate;

  PetModel({
    required this.petId,
    required this.customerId,
    required this.petName,
    required this.species,
    required this.breed,
    required this.gender,
    required this.birthDate,
    required this.spayedNeutered,
    required this.weight,
    required this.color,
    required this.createDate,
  });

  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      petId: json['PetId'] as int,
      customerId: json['CustomerId'] as int,
      petName: json['PetName'] as String,
      species: json['Species'] as String,
      breed: json['Breed'] as String,
      gender: json['Gender'] as String,
      birthDate: DateTime.parse(json['BirthDate'] as String),
      spayedNeutered: json['SpayedNeutered'] as bool,
      weight: (json['Weight'] as num).toDouble(),
      color: json['Color'] as String,
      createDate: DateTime.parse(json['CreateDate'] as String),
    );
  }
}

// --- Customer Model (for the "header" part) ---
class CustomerModel {
  final int customerId;
  final String fullName;
  final String? title;
  final String email;
  final String phone;
  final String address;
  final DateTime createDate;

  CustomerModel({
    required this.customerId,
    required this.fullName,
    this.title,
    required this.email,
    required this.phone,
    required this.address,
    required this.createDate,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      customerId: json['CustomerId'] as int,
      fullName: json['FullName'] as String,
      title: json['Title'] as String?,
      email: json['Email'] as String,
      phone: json['Phone'] as String,
      address: json['Address'] as String,
      createDate: DateTime.parse(json['CreateDate'] as String),
    );
  }
}

// --- Container Model to hold both Customer and Pets ---
class CustomerWithPets {
  final CustomerModel header;
  final List<PetModel> detail;

  CustomerWithPets({
    required this.header,
    required this.detail,
  });

  factory CustomerWithPets.fromJson(Map<String, dynamic> json) {
    var petList = (json['detail'] as List)
        .map((petJson) => PetModel.fromJson(petJson))
        .toList();

    return CustomerWithPets(
      header: CustomerModel.fromJson(json['header']),
      detail: petList,
    );
  }
}
