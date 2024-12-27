class User {
  final String id;
  final String fullname;
  final String roles;
  final String username;
  final String password;
  final String branch;

  User({
    required this.id,
    required this.fullname, 
    required this.roles, 
    required this.username, 
    required this.password, 
    required this.branch
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullname: json['fullname'],
      roles: json['roles'],
      username: json['username'],
      password: json['password'] ?? '',
      branch: json['branch']  
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullname': fullname,
      'roles': roles,
      'username': username,
      'password': password,
      'branch': branch
    };
  }
}