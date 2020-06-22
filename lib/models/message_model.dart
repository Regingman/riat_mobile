class MessageModel {
  String text;
  int senderId;
  int addresseeId;
  String sendDate;

  MessageModel.fromJson(Map<String, dynamic> json)
      : text = json['text'],
        sendDate = json['sendDate'],
        senderId = json['senderId'] as int,
        addresseeId = json['addresseeId'] as int;

  Map<String, dynamic> toJson() => {
        'addresseeId': addresseeId,
        'text': text,
        'sendDate': sendDate,
        'senderId':senderId,
        };

  MessageModel({
    this.addresseeId,
    this.sendDate,
    this.senderId,
    this.text});
}
