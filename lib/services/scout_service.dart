import '../models/content_item.dart';

class ScoutService {
  Future<List<ContentItem>> scoutContent() async {
    // Simulate network delay for "AI scouting"
    await Future.delayed(const Duration(seconds: 2));

    return [
      ContentItem(
        title: "Apple Vision Pro: A New Era of Spatial Computing",
        description: "How visionOS is changing the landscape of augmented reality apps.",
        imageUrl: "https://picsum.photos/seed/vision/800/1200",
        tag: "TECH NEWS",
        type: ContentType.news,
        url: "https://apple.com",
      ),
      ContentItem(
        title: "flutter/flutter",
        description: "Flutter makes it easy and fast to build beautiful apps for mobile and beyond.",
        tag: "GITHUB REPO",
        type: ContentType.github,
        url: "https://github.com/flutter/flutter",
      ),
      ContentItem(
        title: "The Rise of LLMs in Mobile Apps",
        description: "Integrating powerful language models directly into your handheld devices.",
        imageUrl: "https://picsum.photos/seed/ai/800/1200",
        tag: "AI NEWS",
        type: ContentType.news,
        url: "https://openai.com",
      ),
      ContentItem(
        title: "dart-lang/sdk",
        description: "The Dart SDK, including the VM, dart2js, core libraries, and more.",
        tag: "GITHUB REPO",
        type: ContentType.github,
        url: "https://github.com/dart-lang/sdk",
      ),
    ];
  }
}
