enum ActivityLevel {
  sedentary,
  light,
  moderate,
  intense,
}

enum Gender {
  male,
  female,
}

class UserProfile {
  final String name;
  final double weightKg;
  final int age;
  final ActivityLevel activityLevel;
  final Gender gender;
  final int wakeHour;
  final int sleepHour;
  final bool isSetupComplete;

  const UserProfile({
    required this.name,
    required this.weightKg,
    required this.age,
    required this.activityLevel,
    required this.gender,
    this.wakeHour = 7,
    this.sleepHour = 22,
    this.isSetupComplete = false,
  });

  UserProfile copyWith({
    String? name,
    double? weightKg,
    int? age,
    ActivityLevel? activityLevel,
    Gender? gender,
    int? wakeHour,
    int? sleepHour,
    bool? isSetupComplete,
  }) {
    return UserProfile(
      name: name ?? this.name,
      weightKg: weightKg ?? this.weightKg,
      age: age ?? this.age,
      activityLevel: activityLevel ?? this.activityLevel,
      gender: gender ?? this.gender,
      wakeHour: wakeHour ?? this.wakeHour,
      sleepHour: sleepHour ?? this.sleepHour,
      isSetupComplete: isSetupComplete ?? this.isSetupComplete,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'weightKg': weightKg,
        'age': age,
        'activityLevel': activityLevel.name,
        'gender': gender.name,
        'wakeHour': wakeHour,
        'sleepHour': sleepHour,
        'isSetupComplete': isSetupComplete,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] as String? ?? '',
        weightKg: (json['weightKg'] as num?)?.toDouble() ?? 70.0,
        age: json['age'] as int? ?? 30,
        activityLevel: ActivityLevel.values.firstWhere(
          (e) => e.name == json['activityLevel'],
          orElse: () => ActivityLevel.moderate,
        ),
        gender: Gender.values.firstWhere(
          (e) => e.name == json['gender'],
          orElse: () => Gender.male,
        ),
        wakeHour: json['wakeHour'] as int? ?? 7,
        sleepHour: json['sleepHour'] as int? ?? 22,
        isSetupComplete: json['isSetupComplete'] as bool? ?? false,
      );

  static UserProfile get defaultProfile => const UserProfile(
        name: '',
        weightKg: 70,
        age: 30,
        activityLevel: ActivityLevel.moderate,
        gender: Gender.male,
        wakeHour: 7,
        sleepHour: 22,
        isSetupComplete: false,
      );
}
