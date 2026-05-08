import '../models/content_item.dart';
import 'dart:math';

class NewsService {
  final List<String> _baseTechNews = [
    "Apple Vision Pro 2: Leaks reveal lighter design and cheaper display tech.",
    "OpenAI GPT-5 training begins with massive new data center in Iowa.",
    "NVIDIA market cap hits \$3.5 trillion as AI hardware demand surges.",
    "Flutter 4.0 Preview: WASM support becomes stable for web apps.",
    "The rise of Small Language Models: Why size isn't everything anymore.",
    "Tesla FSD v13 rolls out with improved minimalist navigation UI.",
    "SpaceX Starship successfully completes vertical landing in Texas.",
    "The Silicon Valley 'Market correction': Tech hiring starts to rebound.",
    "Quantum Computing breakthrough at Google: Error correction solved.",
    "Bio-tech integration: Neuralink patient demonstrates gaming with mind."
  ];

  final List<String> _githubRepos = [
    "kairo-os/core", "flutter/flutter", "openai/swarm", "microsoft/autogen",
    "google/gemma", "anthropics/claude-dev", "shadcn/ui", "tailwind/css",
    "rust-lang/rust", "facebook/react", "vercel/next.js", "supabase/supabase"
  ];

  Future<List<ContentItem>> fetchDiscoveryContent() async {
    // Simulating a "Non-limited" stream by generating diverse content
    await Future.delayed(const Duration(milliseconds: 800));
    final random = Random();
    
    return List.generate(10, (index) {
      final isNews = random.nextBool();
      if (isNews) {
        final title = _baseTechNews[random.nextInt(_baseTechNews.length)];
        return ContentItem(
          title: title,
          description: "This is a curated deep-dive into how this technology is shaping the future of engineering and the tech market.",
          imageUrl: "https://picsum.photos/seed/${random.nextInt(1000)}/600/400",
          tag: "TECH NEWS",
          type: ContentType.news,
          url: "https://google.com/search?q=${Uri.encodeComponent(title)}",
        );
      } else {
        final repo = _githubRepos[random.nextInt(_githubRepos.length)];
        return ContentItem(
          title: repo,
          description: "Refined tools and frameworks for the modern developer. Trending on GitHub today.",
          tag: "GITHUB TRENDING",
          type: ContentType.github,
          url: "https://github.com/$repo",
        );
      }
    });
  }
}
