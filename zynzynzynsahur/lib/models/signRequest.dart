class SignRequest {
  final DocumentInfo documentInfo;
  final String submitter;
  final String submitterName;
  final List<Signatory> signatories;
  final String applicationVersion;
  final String? reference;
  final String? content;
  final String? callbackURL;
  final String? signingUrl;
  final String? uuid;
  final String? state;

  bool get isSigned => state == 'SIGNED';
  bool get isPending => state == 'NOT_VALIDATED' || state == 'PARTIALLY_VALIDATED';
  bool get isRejected => state == 'REJECTED';

  SignRequest({
    required this.documentInfo,
    required this.submitter,
    required this.submitterName,
    required this.signatories,
    required this.applicationVersion,
    this.reference,
    this.content,
    this.callbackURL,
    this.signingUrl,
    this.uuid,
    this.state,
  });

  Map<String, dynamic> toJson() {
    return {
      'documentInfo': documentInfo.toJson(),
      'submitter': submitter,
      'submitterName': submitterName,
      'signatories': signatories.map((s) => s.toJson()).toList(),
      'applicationVersion': applicationVersion,
      'reference': reference,
      'content': content,
      'callbackURL': callbackURL,
      'signingUrl': signingUrl,
    };
  }

  factory SignRequest.fromJson(Map<String, dynamic> json) {
    final signReq = json['signRequest'] as Map<String, dynamic>? ?? {};

    return SignRequest(
      documentInfo: DocumentInfo(
        name: json['name'] ?? '',
        description: json['description'] ?? '',
      ),
      submitter: signReq['submitter'] ?? '',
      submitterName: signReq['submitterName'] ?? '',
      signatories: (json['signatories'] as List? ?? [])
          .map((s) => Signatory.fromJson(s as Map<String, dynamic>))
          .toList(),
      applicationVersion: signReq['applicationVersion'] ?? '',
      reference: signReq['reference'],
      content: null,
      callbackURL: signReq['callbackURL'],
      signingUrl: null,
      uuid: json['documentUUID'],
      state: json['documentState'],
    );
  }
}

class DocumentInfo {
  final String name;
  final String description;

  DocumentInfo({
    required this.name,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
  };

  factory DocumentInfo.fromJson(Map<String, dynamic> json) {
    return DocumentInfo(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class Signatory {
  final String name;
  final String email;
  final String signatoryRole;
  final String? state;
  final String? rejectReason;
  final List<AuthenticationMethod> authenticationMethods;

  Signatory({
    required this.name,
    required this.email,
    required this.signatoryRole,
    required this.authenticationMethods,
    this.state,
    this.rejectReason,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'signatoryRole': signatoryRole,
    'state': state,
    'rejectReason': rejectReason,
    'authenticationMethods': authenticationMethods.map((a) => a.toJson()).toList(),
  };

  factory Signatory.fromJson(Map<String, dynamic> json) {
    return Signatory(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      signatoryRole: json['signatoryRole'] ?? 'SIGN',
      state: json['state'],
      rejectReason: json['rejectReason'],
      authenticationMethods: (json['authenticationMethods'] as List? ?? [])
          .map((a) => AuthenticationMethod.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AuthenticationMethod {
  final String type;      // e.g. MOUSE, SMSTAN
  final String authType;  // e.g. AFTERVIEW, PREVIEW
  final String processState;

  AuthenticationMethod({
    required this.type,
    required this.authType,
    required this.processState,
  });

  Map<String, dynamic> toJson() => {
    'authenticationMethods': type,
    'authType': authType,
    'processState': processState,
  };

  factory AuthenticationMethod.fromJson(Map<String, dynamic> json) {
    return AuthenticationMethod(
      // API uses 'authenticationMethods' as the key for the method type
      type: json['authenticationMethods'] ?? '',
      authType: json['authType'] ?? '',
      processState: json['processState'] ?? '',
    );
  }
}