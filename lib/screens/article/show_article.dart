import 'package:flutter/material.dart';
import 'package:oleh_bali_mobile/base_buyer.dart';
import 'package:oleh_bali_mobile/models/article_entry.dart';
import 'package:oleh_bali_mobile/screens/article/add_article.dart';
import 'package:oleh_bali_mobile/widgets/article/article_card.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'edit_article.dart';

class ShowArticle extends StatefulWidget {
  const ShowArticle({super.key});

  @override
  State<ShowArticle> createState() => _ShowArticleState();
}

class _ShowArticleState extends State<ShowArticle> {
  bool showAllArticles = true;
  List<ArticleEntry> articles = [];
  late Future<void> _fetchArticlesFuture;

  @override
  void initState() {
    super.initState();
    _fetchArticlesFuture = fetchArticles(context.read<CookieRequest>());
  }

  Future<void> fetchArticles(CookieRequest request) async {
    final response = await request.get(showAllArticles
        ? "http://localhost:8000/article/json-all/"
        : "http://localhost:8000/article/json-user/");
    var data = response;
    List<ArticleEntry> fetchedArticles = [];
    for (var d in data) {
      if (d != null) {
        ArticleEntry article = ArticleEntry.fromJson(d);
        fetchedArticles.add(article);
      }
    }
    setState(() {
      articles = fetchedArticles;
    });
  }

  Future<void> _navigateToEditArticle(ArticleEntry article) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditArticle(article: article),
      ),
    );

    if (result == true) {
      // Refetch articles if the edit was successful
      _fetchArticlesFuture = fetchArticles(context.read<CookieRequest>());
    }
  }
  Future<void> _navigateToAddArticle() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ArticleEntryForm(),
      ),
    );

    if (result == true) {
      // Refetch articles if the edit was successful
      _fetchArticlesFuture = fetchArticles(context.read<CookieRequest>());
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return BaseBuyer(
      appBar: AppBar(
        title: const Text("Articles"),
      ), 
      currentIndex: 1,
      backgroundColor: const Color.fromARGB(255,185,28,27),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Center(
            child: ElevatedButton(
              onPressed: () {
                _navigateToAddArticle();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2463EB),
                foregroundColor: Colors.white,
              ),
              child: const Text("Add Article"),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showAllArticles = true;
                    _fetchArticlesFuture = fetchArticles(request);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: showAllArticles
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white,
                  foregroundColor: showAllArticles
                      ? Colors.white
                      : Theme.of(context).colorScheme.primary,
                ),
                child: const Text("Explore"),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showAllArticles = false;
                    _fetchArticlesFuture = fetchArticles(request);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: !showAllArticles
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white,
                  foregroundColor: !showAllArticles
                      ? Colors.white
                      : Theme.of(context).colorScheme.primary,
                ),
                child: const Text("My Articles"),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder(
              future: _fetchArticlesFuture,
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (articles.isEmpty) {
                  return const Center(
                    child: Text("No articles found"),
                  );
                } else {
                  return ListView.builder(
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      return ArticleCard(
                        articles[index],
                        showAllArticles,
                        onDelete: () {
                          setState(() {
                            articles.removeAt(index);
                          });
                        },
                        onEdit: () {
                          _navigateToEditArticle(articles[index]);
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ), 
      );
  }
}