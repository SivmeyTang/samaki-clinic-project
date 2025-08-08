// lib/logic/add_pet_provider.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Model for the data you send TO the API to ADD a pet
class AddPetRequestModel {
  final int customerId;
  final String petName;
  final String species;
  final String breed;
  final String gender;
  final String color;
  final DateTime birthDate;
  final double weight;
  final bool spayedNeutered;

  AddPetRequestModel({
    required this.customerId,
    required this.petName,
    required this.species,
    required this.breed,
    required this.gender,
    required this.color,
    required this.birthDate,
    required this.weight,
    required this.spayedNeutered,
  });

  String toJson() => json.encode({
        "CustomerId": customerId,
        "PetName": petName,
        "Species": species,
        "Breed": breed,
        "Gender": gender,
        "Color": color,
        "BirthDate": birthDate.toIso8601String(),
        "Weight": weight,
        "SpayedNeutered": spayedNeutered,
      });
}

// Model for the data you send TO the API to UPDATE a pet
class UpdatePetRequestModel {
  final int petId; // Important: ID of the pet to update
  final int customerId;
  final String petName;
  final String species;
  final String breed;
  final String gender;
  final String color;
  final DateTime birthDate;
  final double weight;
  final bool spayedNeutered;

  UpdatePetRequestModel({
    required this.petId,
    required this.customerId,
    required this.petName,
    required this.species,
    required this.breed,
    required this.gender,
    required this.color,
    required this.birthDate,
    required this.weight,
    required this.spayedNeutered,
  });

  String toJson() => json.encode({
        "PetId": petId,
        "CustomerId": customerId,
        "PetName": petName,
        "Species": species,
        "Breed": breed,
        "Gender": gender,
        "Color": color,
        "BirthDate": birthDate.toIso8601String(),
        "Weight": weight,
        "SpayedNeutered": spayedNeutered,
      });
}


// Provider to handle the state
class AddPetProvider with ChangeNotifier {
  // IMPORTANT: Replace with your actual API URL
  final String _baseUrl = "http://localhost:58691";
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void _startLoading() {
    _isLoading = true;
    _error = null;
    notifyListeners();
  }

  void _stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addPet(AddPetRequestModel model) async {
    _startLoading();

    try {
      final url = Uri.parse('$_baseUrl/api/Clinic/SavePet');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: model.toJson(),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final success = responseBody['success'] ?? false;
        if (!success) {
            _error = responseBody['message'] ?? "Failed to save pet.";
        }
        return success;
      } else {
          _error = "Server error: ${response.statusCode}";
          return false;
      }
    } catch (e) {
      _error = "An error occurred: $e";
      return false;
    } finally {
      _stopLoading();
    }
  }

  // --- NEW UPDATE METHOD ---
  Future<bool> updatePet(UpdatePetRequestModel model) async {
    _startLoading();

    try {
      final url = Uri.parse('$_baseUrl/api/Clinic/UpdatePet');
      final response = await http.put( // Use http.put for updates
        url,
        headers: {"Content-Type": "application/json"},
        body: model.toJson(),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final success = responseBody['success'] ?? false;
         if (!success) {
            _error = responseBody['message'] ?? "Failed to update pet.";
        }
        return success;
      } else {
        _error = "Server error: ${response.statusCode}";
        return false;
      }
    } catch (e) {
      _error = "An error occurred: $e";
      return false;
    } finally {
      _stopLoading();
    }
  }
}