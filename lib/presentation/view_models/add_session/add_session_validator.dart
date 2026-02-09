/// Validation class for all fields related to the AddSessionScreen
class AddSessionValidator {
  static String? validateDate({
    required DateTime? startDate,
    required DateTime? endDate,
  }) {
    if (startDate == null) {
      return 'Startdatum muss gegeben sein.';
    }
    if (endDate == null) {
      return 'Enddatum muss gegeben sein.';
    }
    if (endDate.isBefore(startDate)) {
      return 'Startdatum muss vor dem Enddatum liegen.';
    }
    if (endDate.isAtSameMomentAs(startDate)) {
      return '''Start- und Enddatum können nicht am selben Tag sein. '''
          '''Wähle einmalig stattdessen.''';
    }
    return null;
  }
}
