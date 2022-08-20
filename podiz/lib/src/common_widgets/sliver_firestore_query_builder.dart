import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';

//TODO stop using this
class SliverFirestoreQueryBuilder<T> extends StatelessWidget {
  final Query<T> query;
  final Widget Function(BuildContext context, T data) builder;

  const SliverFirestoreQueryBuilder({
    Key? key,
    required this.query,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FirestoreQueryBuilder<T>(
      query: query,
      builder: (context, snapshot, _) {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              final length = snapshot.docs.length;
              if (snapshot.hasMore && length == i + 1) {
                snapshot.fetchMore();
              }
              return builder(context, snapshot.docs[i].data());
            },
            childCount: snapshot.docs.length,
          ),
        );
      },
    );
  }
}
