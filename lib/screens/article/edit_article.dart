import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:oleh_bali_mobile/models/article_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class EditArticle extends StatefulWidget {
  final ArticleEntry article;

  const EditArticle({super.key, required this.article});

  @override
  State<EditArticle> createState() => _EditArticleState();
}

class _EditArticleState extends State<EditArticle> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _textController = TextEditingController();
  final _imageUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.article.title;
    _textController.text = widget.article.text;
    _imageUrlController.text = widget.article.img ?? '';
  }

  Future<void> editArticle(CookieRequest request) async {
    final response = await request.postJson(
      'http://localhost:8000/article/edit/mobile/${widget.article.id}/',
      jsonEncode({
        'title': _titleController.text,
        'text': _textController.text,
        'img': _imageUrlController.text,
      }),
    );

    if (response['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Article updated successfully')),
      );
      Navigator.pop(context, true); // Pass true to indicate success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update article')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Article'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  hintText: "Image URL",
                  labelText: "Image URL",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an image URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: "Title",
                  labelText: "Title",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: "Text",
                  labelText: "Text",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the text';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    editArticle(request);
                  }
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}