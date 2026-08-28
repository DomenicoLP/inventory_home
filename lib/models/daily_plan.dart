class DailyPlan {
  final String day;
  final String breakfast;
  final String lunch;
  final String snack;
  final String dinner;

  const DailyPlan({
    required this.day,
    this.breakfast = '',
    this.lunch = '',
    this.snack = '',
    this.dinner = '',
  });

  DailyPlan copyWith({
    String? day,
    String? breakfast,
    String? lunch,
    String? snack,
    String? dinner,
  }) {
    return DailyPlan(
      day: day ?? this.day,
      breakfast: breakfast ?? this.breakfast,
      lunch: lunch ?? this.lunch,
      snack: snack ?? this.snack,
      dinner: dinner ?? this.dinner,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'breakfast': breakfast,
      'lunch': lunch,
      'snack': snack,
      'dinner': dinner,
    };
  }

  factory DailyPlan.fromMap(Map<String, dynamic> map) {
    return DailyPlan(
      day: map['day'] as String,
      breakfast: map['breakfast'] as String? ?? '',
      lunch: map['lunch'] as String? ?? '',
      snack: map['snack'] as String? ?? '',
      dinner: map['dinner'] as String? ?? '',
    );
  }
}