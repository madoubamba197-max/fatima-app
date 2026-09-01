class AdminSession {

  static bool isLogged = false;

  static void login() {
    isLogged = true;
  }

  static void logout() {
    isLogged = false;
  }

  static bool isAdmin() {
    return isLogged;
  }

}