enum MessageEnum{
  image('image'),
  video('video'),
  audio('audio'),
  text('text'), 
  gif('gif');

  const MessageEnum(this.description);
  final String description;
}

extension ConvertMessage on String {
  MessageEnum toEnum() {
    switch (this) {
      case 'image':
        return MessageEnum.image;
      case 'video':
        return MessageEnum.video;
      case 'audio':
        return MessageEnum.audio;
      case 'text':
        return MessageEnum.text;
      case 'gif':
        return MessageEnum.gif;        
      default:
        return MessageEnum.text;
    }
  }
}