class SellerRegistrationModel {
  String? phone;
  String? phoneOtp;
  String? regToken;
  String? email;
  String? emailOtp;
  String? emailToken;
  String? firstName;
  String? lastName;
  String? password;
  String? confirmPassword;

  SellerRegistrationModel({
    this.phone,
    this.phoneOtp,
    this.regToken,
    this.email,
    this.emailOtp,
    this.emailToken,
    this.firstName,
    this.lastName,
    this.password,
    this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'regToken': regToken,
      'email': email,
      'emailToken': emailToken,
      'firstName': firstName,
      'lastName': lastName,
      'password': password,
    };
  }

  factory SellerRegistrationModel.fromJson(Map<String, dynamic> json) {
    return SellerRegistrationModel(
      phone: json['phone'] as String?,
      regToken: json['regToken'] as String?,
      email: json['email'] as String?,
      emailToken: json['emailToken'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
    );
  }
}

