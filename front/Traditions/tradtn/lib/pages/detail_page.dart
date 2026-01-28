import 'package:flutter/material.dart';
import '../models/tradition.dart';

class DetailPage extends StatelessWidget {
  final Tradition tradition;

  DetailPage({required this.tradition});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tradition.title)),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Text(tradition.description),
      ),
    );
  }
}
