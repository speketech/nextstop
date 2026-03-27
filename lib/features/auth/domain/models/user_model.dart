enum UserRole { passenger, driver, admin }

class UserModel {
  final String id;
  final String phone;
  final String email;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final UserRole role;

  // Professional Profile
  final String? jobTitle;
  final String? company;
  final String? industry;
  final String? linkedinUrl;

  // Verification & Safety
  final bool ninVerified;
  final bool licenseVerified;
  final bool vehicleVerified;
  final bool womenOnlyPref;

  UserModel({
    required this.id,
    required this.phone,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    required this.role,
    this.jobTitle,
    this.company,
    this.industry,
    this.linkedinUrl,
    this.ninVerified = false,
    this.licenseVerified = false,
    this.vehicleVerified = false,
    this.womenOnlyPref = false,
  });

  /// Convenience getter matching the old `fullName` usage in the UI
  String get fullName => '$firstName $lastName'.trim();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user_id'] ?? json['id'] ?? '',
      phone: json['phone_number'] ?? json['phone'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      avatarUrl: json['profile_picture_url'] ?? json['avatar_url'],
      role: UserRole.values.firstWhere(
        // Schema stores lowercase: 'passenger' | 'driver'
        (e) => e.name == (json['user_type'] ?? json['role'] ?? 'passenger'),
        orElse: () => UserRole.passenger,
      ),
      jobTitle: json['job_title'],
      company: json['company'],
      industry: json['industry'],
      linkedinUrl: json['linkedin_profile_url'] ?? json['linkedin_url'],
      // Schema stores TINYINT(1): 0 or 1
      ninVerified: (json['nin_verified'] == 1 || json['nin_verified'] == true),
      licenseVerified: (json['license_verified'] == 1 || json['license_verified'] == true),
      vehicleVerified: (json['vehicle_verified'] == 1 || json['vehicle_verified'] == true),
      womenOnlyPref: (json['women_only_preference'] == 1 || json['women_only_preference'] == true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'phone_number': phone,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'profile_picture_url': avatarUrl,
      // Schema stores lowercase
      'user_type': role.name,
      'job_title': jobTitle,
      'company': company,
      'industry': industry,
      'linkedin_profile_url': linkedinUrl,
      'nin_verified': ninVerified ? 1 : 0,
      'license_verified': licenseVerified ? 1 : 0,
      'vehicle_verified': vehicleVerified ? 1 : 0,
      'women_only_preference': womenOnlyPref ? 1 : 0,
    };
  }
}
