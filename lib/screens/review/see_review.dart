import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oleh_bali_mobile/base_buyer.dart';
import 'package:oleh_bali_mobile/models/review_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class SeeReview extends StatefulWidget {
  final String productId;
  final String productName;
  const SeeReview({Key? key, required this.productId, required this.productName}) : super(key: key);

  @override
  _SeeReviewPageState createState() => _SeeReviewPageState();
}

class _SeeReviewPageState extends State<SeeReview> {
  List<ReviewEntry>? reviewEntries;
  late Future<void> _fetchReviewProductFuture;
  final TextEditingController _reviewTextController = TextEditingController();
  final TextEditingController _editReviewController = TextEditingController();

  Future<void> _fetchReviews(CookieRequest request) async {
    final response = await request.get("https://ezar-akhdan-olehbali.pbp.cs.ui.ac.id/review/json/${widget.productId}");
    List rawData = response;
    List<ReviewEntry> fetchedReviews = [];
    for (var d in rawData) {
      if (d != null) {
        fetchedReviews.add(ReviewEntry.fromJson(d));
      }
    }
    setState(() {
      reviewEntries = fetchedReviews;
    });
  }

  Future<void> _createReview(CookieRequest request, String reviewText) async {
    final response = await request.postJson(
      "https://ezar-akhdan-olehbali.pbp.cs.ui.ac.id/review/create/${widget.productId}",
      jsonEncode(<String, String>{
        'review_text': reviewText,
      }),
    );
    // If successful, refresh the reviews
    if (response['success'] == true) {
      await _fetchReviews(request);
    }
  }

  Future<void> _editReview(CookieRequest request, String reviewText, String reviewId) async {
    final response = await request.postJson(
      "https://ezar-akhdan-olehbali.pbp.cs.ui.ac.id/review/edit-review/mobile/${reviewId}",
      jsonEncode(<String, String>{
        'review_text': reviewText,
      }),
    );
    // If successful, refresh the reviews
    if (response['status'] == "success") {
      await _fetchReviews(request);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchReviewProductFuture = _fetchReviews(context.read<CookieRequest>());
  }

  void _showAddReviewDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final request = context.watch<CookieRequest>();
        return AlertDialog(
          title: const Text(
            "Add Your Review",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: TextField(
              controller: _reviewTextController,
              minLines: 6,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: "Write your review here...",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Close", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Submit Review", style: TextStyle(color:Colors.white),),
              onPressed: () async {
                await _createReview(request, _reviewTextController.text);
                _reviewTextController.clear();
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditReviewDialog(String text, String id) {
    _editReviewController.text = text;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final request = context.watch<CookieRequest>();
        return AlertDialog(
          title: const Text(
            "Edit Your Review",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: TextField(
              controller: _editReviewController,
              minLines: 6,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: "Write your review here...",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Close", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Edit Review", style: TextStyle(color:Colors.white),),
              onPressed: () async {
                await _editReview(request, _editReviewController.text,id);
                _editReviewController.clear();
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return FutureBuilder<void>(
      future: _fetchReviewProductFuture,
      builder: (context, snapshot) {
        // Display loading spinner
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // Display any error
        if (snapshot.hasError) {
          return BaseBuyer(
            appBar: AppBar(title: const Text("Reviews")),
            currentIndex: 2,
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        }
        // Build the UI if data is fetched
        final reviews = reviewEntries;
        return BaseBuyer(
          appBar: AppBar(title: Text("${widget.productName} Reviews")),
          currentIndex: 2,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Review",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: _showAddReviewDialog,
                      child: const Text("Add Review", style: TextStyle(color: Colors.white),),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (reviews == null || reviews.isEmpty) ...[
                    const Text(
                      "No Reviews yet",
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    // Render each review as a card-like layout
                    for (final review in reviews)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Replace "profilePictureUrl" with the user’s actual profile image field
                            ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child: Image.network(
                                review.user.profilepicture,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.person),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Replace "displayName" and "time" with actual fields
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        review.user.displayname,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        review.time,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    review.user.nationality,
                                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(review.reviewText),
                                  // Conditionally show edit/delete for review owners
                                  if (review.user.displayname == review.thisUser)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            // Handle edit navigation
                                            _showEditReviewDialog(review.reviewText,review.id);
                                          },
                                          child: const Text(
                                            "Edit",
                                            style: TextStyle(
                                              color: Colors.blue,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        InkWell(
                                          onTap: () async {
                                          final response = await request.get(
                                              "https://ezar-akhdan-olehbali.pbp.cs.ui.ac.id/review/delete/mobile/${review.id}",
                                            );

                                            if (response['success']) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text("Review deleted successfully."),
                                                ),
                                              );
                                              setState(() {
                                                reviewEntries!.remove(review);
                                              });
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text("Failed to delete Review."),
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text(
                                            "Delete",
                                            style: TextStyle(
                                              color: Colors.red,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}