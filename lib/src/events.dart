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

  final rawParams = (map['params'] as Map?)?.cast<String, dynamic>();

  Map<String, dynamic>? normalizedParams;
  if (rawParams != null) {
    // 如果只有一层包裹 { klarnaToken: {...} }
    if (rawParams.length == 1 && rawParams.values.first is Map) {
      normalizedParams = (rawParams.values.first as Map).cast<String, dynamic>();
    } else {
      normalizedParams = rawParams;
    }
  }


    return KlarnaEvent(
      map['action'] as String,
      normalizedParams,
    );
  }
}