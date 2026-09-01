enum UserRole {
  superAdmin,
  merchant,
  customer,
}


class UserAccount {

  final String id;

  final String name;

  final String phone;

  final String email;

  final String password;

  final UserRole role;


  UserAccount({

    required this.id,

    required this.name,

    required this.phone,

    required this.email,

    required this.password,

    required this.role,

  });

}