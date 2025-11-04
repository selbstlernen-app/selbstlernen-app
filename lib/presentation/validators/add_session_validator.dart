import 'package:srl_app/domain/models/models.dart';

/// Validation class for all fields related to the AddSessionScreen
class AddSessionValidator {
  static String? validateTitle(String? title) {
    if (title == null || title.trim().isEmpty) {
      return 'Titel kann nicht leer sein.';
    }
    if (title.length < 3) {
      return 'Titel muss mind. 3 Charaktere lang sein.';
    }
    return null;
  }

  static String? validateStartDate(
    DateTime? date, {
    required bool isRepeating,
    DateTime? endDate,
  }) {
    if (!isRepeating) return null;
    if (date == null) {
      return 'Startdatum muss gegeben sein.';
    }
    if (endDate != null) {
      if (endDate.isBefore(date)) {
        return 'Startdatum muss vor dem Enddatum liegen.';
      }
      if (endDate.isAtSameMomentAs(date)) {
        return 'Start- und Enddatum können nicht am selben Tag sein. Wähle einmalig stattdessen.';
      }
    }
    return null;
  }

  static String? validateEndDate(
    DateTime? date, {
    required bool isRepeating,
    DateTime? startDate,
  }) {
    if (!isRepeating) return null;
    if (date == null) {
      return 'Enddatum muss gegeben sein.';
    }
    if (startDate != null) {
      if (date.isBefore(startDate)) {
        return 'Enddatum muss nach dem Startdatum liegen.';
      }
      if (date.isAtSameMomentAs(startDate)) {
        return 'Start- und Enddatum können nicht am selben Tag sein. Wähle einmalig stattdessen.';
      }
    }
    return null;
  }

  static String? validateDays(
    List<int> selectedDays, {
    required bool isRepeating,
  }) {
    if (!isRepeating) return null;
    if (selectedDays.isEmpty) {
      return "Es muss mind. ein Tag ausgewählt werden.";
    }
    return null;
  }

  static String? validateGoals({
    required bool setGoals,
    required List<GoalModel> goals,
    required List<TaskModel> tasks,
  }) {
    if (setGoals && goals.isEmpty) {
      return "Es muss mind. 1 Ziel festgelegt werden.";
    }
    if (!setGoals && tasks.isEmpty) {
      return "Es muss mind. 1 Aufgabe festgelegt werden.";
    }
    return null;
  }
}
