import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'post_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const OfflinePostsApp());
}

class OfflinePostsApp extends StatelessWidget {
  const OfflinePostsApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      home: const PostsScreen(),
    );
  }
}

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});
  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  late Future<List<Post>> postsFuture;

  @override
  void initState() {
    super.initState();
    refreshPosts();
  }

  void refreshPosts() {
    setState(() {
      postsFuture = DatabaseHelper.instance.readAllPosts();
    });
  }

  void _showPostForm(Post? post) {
    final titleController = TextEditingController(text: post?.title ?? '');
    final contentController = TextEditingController(text: post?.content ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              post == null ? "Add New Post" : "Edit Post",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: contentController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () async {
                final title = titleController.text;
                final content = contentController.text;

                if (title.isNotEmpty && content.isNotEmpty) {
                  if (post == null) {
                    await DatabaseHelper.instance.create(
                      Post(title: title, content: content),
                    );
                  } else {
                    await DatabaseHelper.instance.update(
                      Post(id: post.id, title: title, content: content),
                    );
                  }
                  refreshPosts();
                  Navigator.pop(context);
                }
              },
              child: Text(post == null ? "Save Post" : "Update Post"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Offline Posts Manager")),
      body: FutureBuilder<List<Post>>(
        future: postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No posts yet. Add one!"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final post = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                child: ListTile(
                  title: Text(
                    post.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(post.content, maxLines: 1),
                  onTap: () => _showPostForm(post),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      await DatabaseHelper.instance.delete(post.id!);
                      refreshPosts();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPostForm(null),
        label: const Text("New Post"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
