import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum Gender {
  male,
  female;

  static Gender? fromString(String? gender) {
    try {
      return Gender.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toLowerCase() == gender?.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}

enum MalaysianState {
  johor,
  kedah,
  kelantan,
  melaka,
  negeriSembilan,
  pahang,
  perak,
  perlis,
  pulauPinang,
  sabah,
  sarawak,
  selangor,
  terengganu,
  kualaLumpur,
  labuan,
  putrajaya
}

extension MalaysianStateExtension on MalaysianState {
  String get displayName {
    switch (this) {
      case MalaysianState.johor:
        return "Johor";
      case MalaysianState.kedah:
        return "Kedah";
      case MalaysianState.kelantan:
        return "Kelantan";
      case MalaysianState.melaka:
        return "Melaka";
      case MalaysianState.negeriSembilan:
        return "Negeri Sembilan";
      case MalaysianState.pahang:
        return "Pahang";
      case MalaysianState.perak:
        return "Perak";
      case MalaysianState.perlis:
        return "Perlis";
      case MalaysianState.pulauPinang:
        return "Pulau Pinang";
      case MalaysianState.sabah:
        return "Sabah";
      case MalaysianState.sarawak:
        return "Sarawak";
      case MalaysianState.selangor:
        return "Selangor";
      case MalaysianState.terengganu:
        return "Terengganu";
      case MalaysianState.kualaLumpur:
        return "Kuala Lumpur";
      case MalaysianState.labuan:
        return "Labuan";
      case MalaysianState.putrajaya:
        return "Putrajaya";
    }
  }
}

enum Reminder { today, daily, upcoming }

enum OrganisationAccountStatus { pending, approved, rejected }

enum AdminEventStatus { pending, approved, rejected }

enum OrganiserEventStatus { upcoming, pending, past, rejected }

enum ElderlyEventStatus { upcoming, myticket }

enum BindingStatus { pending, approved, rejected, removed }

enum NotificationType {
  sosAlert,
  sosCancel,
  elderlyReminder,
  missedReminder,
  bindingRequest,
  eventFeedback,
  eventUpdate,
  broadcast,
  accountUpdate,
}

enum RecordType {
  labReport,
  prescription,
  invoice,
}

extension RecordTypeExtension on RecordType {
  String get name {
    switch (this) {
      case RecordType.labReport:
        return "Lab Report";
      case RecordType.prescription:
        return "Prescription";
      case RecordType.invoice:
        return "Invoice";
    }
  }

  IconData get icon {
    switch (this) {
      case RecordType.labReport:
        return Icons.description;
      case RecordType.prescription:
        return Icons.local_pharmacy;
      case RecordType.invoice:
        return Icons.receipt_long;
    }
  }
}

enum Role { admin, elderly, caregiver, eventOrganiser }

extension RoleExtension on Role {
  String get name {
    switch (this) {
      case Role.admin:
        return "Admin";
      case Role.elderly:
        return "Elderly";
      case Role.caregiver:
        return "Caregiver";
      case Role.eventOrganiser:
        return "Event Organiser";
    }
  }
}
