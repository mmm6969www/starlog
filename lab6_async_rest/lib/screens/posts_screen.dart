import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/api_service.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final _api = ApiService();
  final List<Post> _created = []; // записи, створені в цій сесії (сервер їх не зберігає)
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = _api.getPosts();
  }

  /// Кнопка «Повторити».
  void _reload() {
    setState(() {
      _postsFuture = _api.getPosts();
    });
  }

  /// Pull-to-refresh: onRefresh має повернути Future, тож чекаємо на результат.
  Future<void> _refresh() async {
    final future = _api.getPosts();
    setState(() {
      _postsFuture = future;
    });
    try {
      await future;
    } on ApiException catch (e) {
      _showError(e.message);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
      ));
  }

  Future<void> _showCreateDialog() async {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Нове спостереження'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Об’єкт (заголовок)'),
            ),
            TextField(
              controller: bodyCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Нотатки'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Скасувати'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Надіслати'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    final title = titleCtrl.text.trim();
    if (title.isEmpty) {
      _showError('Вкажіть назву об’єкта');
      return;
    }

    try {
      final created = await _api.createPost(title, bodyCtrl.text.trim());
      if (!mounted) return;
      setState(() {
        _created.insert(0, created);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Сервер створив запис №${created.id}')),
      );
    } on ApiException catch (e) {
      _showError(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('StarLog · Журнал')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('Нове'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Post>>(
          future: _postsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return _ErrorView(
                message: '${snapshot.error}',
                onRetry: _reload,
              );
            }
            final posts = [..._created, ...snapshot.data!];
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return ListTile(
                  leading: CircleAvatar(child: Text('${post.id}')),
                  title: Text(post.title),
                  subtitle: Text(
                    post.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 56),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Повторити'),
            ),
          ],
        ),
      ),
    );
  }
}