class Validator {
  static final RegExp _urlRegExp = RegExp(
      r"^(?:http(s)?:\/\/)[\w.-]+(?:\.[\w\.-]+)+[\w\-\._~:/?#[\]@!\$&'\(\)\*\+,;=.]+$");

  static final RegExp _nameRegExp = RegExp(r'(^[a-zA-Z ]*$)');

  static final RegExp _emailRegExp = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$');

  static bool validUrl(String url) {
    return _urlRegExp.hasMatch(url);
  }

  static bool validName(String name) {
    return _nameRegExp.hasMatch(name);
  }

  static bool validEmail(String email) {
    return _emailRegExp.hasMatch(email);
  }

  static bool validPassword(String password) {
    return password.length > 5;
  }
}
