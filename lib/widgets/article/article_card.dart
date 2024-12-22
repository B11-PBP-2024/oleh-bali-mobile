import 'package:flutter/material.dart';
import 'package:oleh_bali_mobile/models/article_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ArticleCard extends StatelessWidget {
  final ArticleEntry article;
  final bool showAllArticles;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ArticleCard(
    this.article,
    this.showAllArticles, {
    required this.onDelete,
    required this.onEdit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(
                    article.user.profilepicture,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                      return SizedBox(height: 0,);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.user.displayname,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        article.user.nationality,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  article.time,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Center(
              child: Text(
                article.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (article.img != null && article.img.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  article.img,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                      return SizedBox(height: 0,);
                    },
                ),
              ),
            const SizedBox(height: 10),
            Text(
              article.text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
            if (!showAllArticles)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: onEdit,
                    child: const Text('Edit'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final response = await request.get(
                        "https://ezar-akhdan-olehbali.pbp.cs.ui.ac.id/article/delete/mobile/${article.id}/",
                      );

                      if (response['status'] == 'success') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Article deleted successfully."),
                          ),
                        );
                        onDelete();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Failed to delete article."),
                          ),
                        );
                      }
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}