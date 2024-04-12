/// events corresponding to mono events
library;

enum MonoEvent {
  /// [OPENED] Triggered when the user opens the Connect Widget.
  opened,

  /// [SUCCESS] Triggered when the user successfully links their account and provides the code for autentication.
  success,

  ///	Triggered when the user closes the Connect Widget. [EXIT]
  exit,

  /// [INSTITUTION_SELECTED]	Triggered when the user selects an institution.
  institutionSelected,

  /// [AUTH_METHOD_SWITCHED]	Triggered when the user changes authentication method from internet to mobile banking, or vice versa.
  authMethodSwitched,

  /// SUBMIT_CREDENTIALS	Triggered when the user presses Log in.
  submitCredentials,

  /// ACCOUNT_LINKED	Triggered when the user successfully links their account.
  accountLinked,

  /// ACCOUNT_SELECTED	Triggered when the user selects a new account.,
  accountSelected,

  /// ERROR	Triggered when the widget reports an error.
  error,

  /// An unexpected event
  unknown,
}

extension M on MonoEvent {
  /// convert a string value to a Mono event
  MonoEvent fromString(String value) {
    switch (value.toUpperCase()) {
      case 'INSTITUTION_SELECTED':
        return MonoEvent.institutionSelected;
      case 'AUTH_METHOD_SWITCHED':
        return MonoEvent.authMethodSwitched;
      case 'SUBMIT_CREDENTIALS':
        return MonoEvent.submitCredentials;
      case 'ACCOUNT_LINKED':
        return MonoEvent.accountLinked;
      case 'ACCOUNT_SELECTED':
        return MonoEvent.accountSelected;

      default:
    }
    final event =
        MonoEvent.values.where((e) => e.name == value.toLowerCase()).toList();

    return event.isNotEmpty ? event[0] : MonoEvent.unknown;
  }
}
