import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/youtube_api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = YouTubeApi();
  final _search = TextEditingController();
  late Future<List<VideoItem>> _videos;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _videos = _api.popular();
  }

  @override
  void dispose() {
    _search.dispose();
    _api.close();
    super.dispose();
  }

  void _loadPopular() {
    setState(() { _isSearching = false; _videos = _api.popular(); });
  }

  void _doSearch() {
    final query = _search.text.trim();
    if (query.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() { _isSearching = true; _videos = _api.search(query); });
  }

  Future<void> _openVideo(VideoItem video) async {
    final uri = Uri.https('www.youtube.com', '/watch', {'v': video.id});
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open YouTube.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const Row(children: [
          Icon(Icons.play_circle_fill, color: Color(0xFFFF0033), size: 30),
          SizedBox(width: 8),
          Text('YouTube', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -1)),
          Text(' X', style: TextStyle(color: Color(0xFFFF0033), fontWeight: FontWeight.w800)),
        ]),
        actions: [IconButton(tooltip: 'Refresh', onPressed: _loadPopular, icon: const Icon(Icons.refresh))],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(children: [
            Expanded(child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _doSearch(),
              decoration: InputDecoration(
                hintText: 'Search YouTube',
                prefixIcon: const Icon(Icons.search),
                filled: true, fillColor: const Color(0xFF242424),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            )),
            const SizedBox(width: 8),
            IconButton.filled(onPressed: _doSearch, icon: const Icon(Icons.search)),
          ]),
        ),
        SizedBox(height: 42, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children: [
          _chip('Explore', !_isSearching, _loadPopular),
          _chip('Popular', !_isSearching, _loadPopular),
        ])),
        const SizedBox(height: 8),
        Expanded(child: FutureBuilder<List<VideoItem>>(
          future: _videos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) return Center(child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.cloud_off, size: 48, color: Colors.white54),
                const SizedBox(height: 12),
                Text(snapshot.error.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(onPressed: _loadPopular, child: const Text('Retry')),
              ]),
            ));
            final videos = snapshot.data ?? [];
            if (videos.isEmpty) return const Center(child: Text('No videos found. Try another search.'));
            return LayoutBuilder(builder: (context, constraints) {
              final wide = constraints.maxWidth >= 850;
              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: wide ? 3 : (constraints.maxWidth >= 560 ? 2 : 1),
                  childAspectRatio: wide ? 1.35 : (constraints.maxWidth >= 560 ? 1.15 : 1.45),
                  crossAxisSpacing: 14, mainAxisSpacing: 14,
                ),
                itemCount: videos.length,
                itemBuilder: (context, index) => _VideoCard(video: videos[index], onTap: () => _openVideo(videos[index])),
              );
            });
          },
        )),
      ]),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(label: Text(label), selected: selected, onSelected: (_) => onTap()),
  );
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.video, required this.onTap});
  final VideoItem video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Stack(fit: StackFit.expand, children: [
        ClipRRect(borderRadius: BorderRadius.circular(12), child: video.thumbnail.isEmpty
          ? Container(color: Colors.white10, child: const Icon(Icons.video_library))
          : Image.network(video.thumbnail, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.white10, child: const Icon(Icons.broken_image)))),
        const Center(child: Icon(Icons.play_circle_fill, size: 46, color: Colors.white)),
      ])),
      const SizedBox(height: 8),
      Text(video.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 3),
      Text(video.channel, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white60, fontSize: 12)),
    ]),
  );
}
