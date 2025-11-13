class CollaboratorResponse {
  final int idCollaborator;
  final String email;
  final String? userName;
  final bool canEdit;
  final bool canComment;
  final DateTime invitedDate;
  final DateTime? acceptedDate;
  final bool isActive;
  final String status;

  CollaboratorResponse({
    required this.idCollaborator,
    required this.email,
    this.userName,
    required this.canEdit,
    required this.canComment,
    required this.invitedDate,
    this.acceptedDate,
    required this.isActive,
    required this.status,
  });

  factory CollaboratorResponse.fromJson(Map<String, dynamic> json) {
    return CollaboratorResponse(
      idCollaborator: json['idCollaborator'],
      email: json['email'],
      userName: json['userName'],
      canEdit: json['canEdit'],
      canComment: json['canComment'],
      invitedDate: DateTime.parse(json['invitedDate']),
      acceptedDate: json['acceptedDate'] != null ? DateTime.parse(json['acceptedDate']) : null,
      isActive: json['isActive'],
      status: json['status'],
    );
  }
}