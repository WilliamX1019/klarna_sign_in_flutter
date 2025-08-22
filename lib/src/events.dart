class KlarnaEventAction {
  static const userTappedButton = 'USER_TAPPED_BUTTON';
  static const userAuth = 'USER_AUTH';
  static const userCancelled = 'USER_CANCELLED';
  static const token = 'TOKEN';
  static const error = 'ERROR';
}

class KlarnaEvent {
  final String action;
  final Map<String, dynamic>? params;

  KlarnaEvent(this.action, [this.params]);

  factory KlarnaEvent.fromMap(Map<dynamic, dynamic> map) {
    return KlarnaEvent(
      map['action'] as String,
      (map['params'] as Map?)?.cast<String, dynamic>(),
    );
  }
}