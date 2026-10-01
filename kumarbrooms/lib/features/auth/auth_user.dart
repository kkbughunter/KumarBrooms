class AuthUser {
  const AuthUser({
    required this.userId,
    required this.orgId,
    required this.orgCode,
    required this.email,
    required this.fullName,
    required this.roles,
    this.phone,
    this.gender,
  });

  final String userId;
  final String orgId;
  final String orgCode;
  final String email;
  final String fullName;
  final List<String> roles;
  final String? phone;
  final String? gender;

  bool get isAdmin => roles.any((role) => role.toUpperCase() == 'ADMIN');

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        userId: json['userId'] as String? ?? '',
        orgId: json['orgId'] as String? ?? '',
        orgCode: json['orgCode'] as String? ?? '',
        email: json['email'] as String? ?? '',
        fullName: json['fullName'] as String? ?? '',
        phone: json['phone'] as String?,
        gender: json['gender'] as String?,
        roles: (json['roles'] as List<dynamic>? ?? const [])
            .map((role) => role.toString())
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'orgId': orgId,
        'orgCode': orgCode,
        'email': email,
        'fullName': fullName,
        'phone': phone,
        'gender': gender,
        'roles': roles,
      };
}
