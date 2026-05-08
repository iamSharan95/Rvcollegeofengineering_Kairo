enum ContentType { news, github }

class ContentItem {
  final String title;
  final String description;
  final String? imageUrl;
  final String? url;
  final String tag;
  final ContentType type;

  ContentItem({
    required this.title,
    required this.description,
    this.imageUrl,
    this.url,
    required this.tag,
    required this.type,
  });
}
