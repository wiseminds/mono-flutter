
import '../extensions/map.dart';

class MonoEventData {
  /// type of event mono.connect.xxxx
  final String type;

  /// reference passed through the connect config
  final String? reference;

  /// name of page the widget exited on
  final String? pageName;

  /// auth method before it was last changed
  final String? prevAuthMethod;

  /// current auth method
  final String? authMethod;

  /// type of MFA the current user/bank requires
  final String? mfaType;

  /// number of accounts selected by the user,  emitted in ACCOUNT_SELECTED
  final int? selectedAccountsCount;
// error thrown by widget
  final String? errorType;
// error message describing the error
  final String? errorMessage;

  String? get institutionId =>
      institution?.getKey<String>('id'); // id of institution
  // name of institution
  String? get institutionName => institution?.getKey<String>('name');
  final Map<String, dynamic>? institution;

  /// unix timestamp of the event as an Integer
  final int timestamp;

  MonoEventData(this.type,
      {this.reference,
      this.pageName,
      this.prevAuthMethod,
      this.authMethod,
      this.mfaType,
      this.selectedAccountsCount,
      this.errorType,
      this.errorMessage,
      this.institution,
      required this.timestamp});

  factory MonoEventData.fromJson(Map<String, dynamic> json) => MonoEventData(
        'event',
        timestamp: json.getKey<int>('timestamp') ??
            DateTime.now().millisecondsSinceEpoch,
        reference: json.getKey<String>('reference'),
        authMethod: json.getKey<String>('authMethod'),
        errorMessage: json.getKey<String>('errorMessage'),
        errorType: json.getKey<String>('errorType'),
        mfaType: json.getKey<String>('mfaType'),
        pageName: json.getKey<String>('pageName'),
        prevAuthMethod: json.getKey<String>('prevAuthMethod'),
        selectedAccountsCount: json.getKey<int>('selectedAccountsCount'),
        institution: json['institution'] as Map<String, dynamic>?,
      );
}
