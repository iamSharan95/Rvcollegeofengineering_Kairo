import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/explore_provider.dart';
import '../providers/notes_provider.dart';
import '../models/content_item.dart';
import '../models/note.dart';
import 'package:url_launcher/url_launcher.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      Provider.of<ExploreProvider>(context, listen: false).fetchContent();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExploreProvider>(
      builder: (context, provider, child) {
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          itemCount: provider.items.length + 1,
          itemBuilder: (context, index) {
            if (index == provider.items.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 32.0),
                child: Center(child: CircularProgressIndicator.adaptive()),
              );
            }

            final item = provider.items[index];
            return item.type == ContentType.news 
                ? _buildReleaseCard(item) 
                : _buildGithubItem(context, item);
          },
        );
      },
    );
  }

  Widget _buildReleaseCard(ContentItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.imageUrl != null)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                image: DecorationImage(image: NetworkImage(item.imageUrl!), fit: BoxFit.cover),
              ),
            ),
          const SizedBox(height: 16),
          Text(item.tag, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(item.description, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _launchUrl(item.url ?? ""),
            child: Text("Explore Now >", style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildGithubItem(BuildContext context, ContentItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(item.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                child: Text(item.tag.split(':').last.trim(), style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(item.description, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.star_outline, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              const Text("Trending", style: TextStyle(fontSize: 11, color: Colors.grey)),
              const Spacer(),
              _minimalActionBtn(
                icon: Icons.bookmark_border, 
                onTap: () {
                  final note = Note(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: "Saved Repo: ${item.title}",
                    content: "Description: ${item.description}\nLink: ${item.url}",
                    date: DateTime.now(),
                    type: NoteType.personal,
                  );
                  Provider.of<NotesProvider>(context, listen: false).addNote(note);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Saved ${item.title} to Hub"), duration: const Duration(seconds: 1)),
                  );
                }
              ),
              const SizedBox(width: 8),
              _minimalActionBtn(
                icon: Icons.arrow_outward, 
                onTap: () => _launchUrl(item.url ?? ""),
                isDark: true
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _minimalActionBtn({required IconData icon, required VoidCallback onTap, bool isDark = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2E1A) : Colors.grey.shade100, 
          shape: BoxShape.circle
        ),
        child: Icon(icon, size: 14, color: isDark ? Colors.white : Colors.black),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) throw Exception('Could not launch $url');
  }
}
