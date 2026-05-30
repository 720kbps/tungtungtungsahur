class SignRequest {
  final DocumentInfo documentInfo;
  final String submitter;
  final String submitterName;
  final List<Signatory> signatories;
  final String applicationVersion;
  final String? reference;
  final String? content; // Base64 encoded PDF content
  final String? callbackURL;
  
  // These fields are often returned by the API in a response or list
  final String? uuid;
  final String? state;

  bool get isSigned => state == 'SIGNED';

  SignRequest({
    required this.documentInfo,
    required this.submitter,
    required this.submitterName,
    required this.signatories,
    required this.applicationVersion,
    this.reference,
    this.content,
    this.callbackURL,
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
    };
  }

  factory SignRequest.fromJson(Map<String, dynamic> json) {
    return SignRequest(
      documentInfo: DocumentInfo.fromJson(json['documentInfo'] ?? {}),
      submitter: json['submitter'] ?? '',
      submitterName: json['submitterName'] ?? '',
      signatories: (json['signatories'] as List? ?? [])
          .map((s) => Signatory.fromJson(s))
          .toList(),
      applicationVersion: json['applicationVersion'] ?? '',
      reference: json['reference'],
      content: json['content'],
      callbackURL: json['callbackURL'],
      uuid: json['uuid'],
      state: json['state'],
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
  final List<AuthenticationMethod> authenticationMethods;

  Signatory({
    required this.name,
    required this.email,
    required this.signatoryRole,
    required this.authenticationMethods,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'signatoryRole': signatoryRole,
    'authenticationMethods': authenticationMethods.map((a) => a.toJson()).toList(),
  };

  factory Signatory.fromJson(Map<String, dynamic> json) {
    return Signatory(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      signatoryRole: json['signatoryRole'] ?? 'SIGN',
      authenticationMethods: (json['authenticationMethods'] as List? ?? [])
          .map((a) => AuthenticationMethod.fromJson(a))
          .toList(),
    );
  }
}

class AuthenticationMethod {
  final String type;

  AuthenticationMethod({required this.type});

  Map<String, dynamic> toJson() => {
    'type': type,
  };

  factory AuthenticationMethod.fromJson(Map<String, dynamic> json) {
    return AuthenticationMethod(
      type: json['type'] ?? '',
    );
  }
}
