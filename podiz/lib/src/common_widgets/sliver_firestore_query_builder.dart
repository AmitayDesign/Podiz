import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';

class SliverFirestoreQueryBuilder<T> extends StatelessWidget {
  final Query<T> query;
  final Widget Function(BuildContext context, T data)? builder;
  final Widget Function(BuildContext context, T data, int i)? indexedBuilder;

  const SliverFirestoreQueryBuilder({
    Key? key,
    required this.query,
    this.builder,
    this.indexedBuilder,
  })  : assert(builder != null || indexedBuilder != null),
        super(key: key);

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
              return builder?.call(context, snapshot.docs[i].data()) ??
                  indexedBuilder!(context, snapshot.docs[i].data(), i);
            },
            childCount: snapshot.docs.length,
          ),
        );
      },
    );
  }
}
