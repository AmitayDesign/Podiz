enum Channel { replies, follows }

class NotificationPodiz {
  final Channel channel;
  final String id;

  NotificationPodiz(this.channel, this.id);
  factory NotificationPodiz.fromPayload(String payload) {
    final payloadList = payload.split(':');
    final id = payloadList.last;
    final channel = Channel.values.firstWhere(
      (channel) => channel.name == payloadList.first,
    );
    return NotificationPodiz(channel, id);
  }
}
