class Appointment {
  final int? appointmentId;
  final int? petId;
  final int? doctorId;
  final String fullName;
  final String petOfNumber;
  final String species;
  final DateTime appointmentDate;
  final String appointmentType;
  final String appointmentTime;
  final String phoneNumber;
  final String? email;
  final String? detail;
  final String? status;
  final DateTime? createdDate;
  final DateTime? updateDate;

  Appointment({
    this.appointmentId,
    this.petId,
    this.doctorId,
    this.status,
    this.createdDate,
    this.updateDate,
    required this.fullName,
    required this.petOfNumber,
    required this.species,
    required this.appointmentDate,
    required this.appointmentType,
    required this.appointmentTime,
    required this.phoneNumber,
    this.email,
    this.detail,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      appointmentId: _parseInt(json['AppointmentId']),
      petId: _parseInt(json['PetId']),
      doctorId: _parseInt(json['DoctorId']),
      petOfNumber: json['Pet_of_Number']?.toString() ?? '',
      species: json['Species']?.toString() ?? '',
      appointmentDate: _parseDateTime(json['AppointmentDate']) ?? DateTime.now(),
      appointmentType: json['AppointmentType']?.toString() ?? '',
      appointmentTime: json['AppointmentTime']?.toString() ?? '',
      phoneNumber: json['PhoneNumber']?.toString() ?? '',
      email: json['Email']?.toString(),
      status: json['Status']?.toString(),
      detail: json['Detail']?.toString(),
      fullName: json['FullName']?.toString() ?? '',
      createdDate: _parseDateTime(json['CreatedDate']),
      updateDate: _parseDateTime(json['UpdateDate']),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (e) {
      return null;
    }
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  Map<String, dynamic> toJson() {
    return {
      if (appointmentId != null) 'AppointmentId': appointmentId,
      if (petId != null) 'PetId': petId,
      if (doctorId != null) 'DoctorId': doctorId,
      'FullName': fullName,
      'PhoneNumber': phoneNumber,
      if (email != null) 'Email': email,
      'Pet_of_Number': petOfNumber,
      'Species': species,
      'AppointmentDate': appointmentDate.toIso8601String(),
      'AppointmentType': appointmentType,
      'AppointmentTime': appointmentTime,
      if (detail != null) 'Detail': detail,
      if (status != null) 'Status': status,
      if (createdDate != null) 'CreatedDate': createdDate?.toIso8601String(),
      if (updateDate != null) 'UpdateDate': updateDate?.toIso8601String(),
    };
  }
}