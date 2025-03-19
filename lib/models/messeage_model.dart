

class Message {
  final String id;
  final String content;
  final String senderId;
  final DateTime createdOn;

  Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.createdOn,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] ?? '',
      content: json['message'] ?? '',
      senderId: json['Sender'] ?? '',  
      createdOn: json['createdOn'] != null 
          ? DateTime.parse(json['createdOn'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'message': content,
      'Sender': senderId,  
      'createdOn': createdOn.toIso8601String(),
    };
  }
}