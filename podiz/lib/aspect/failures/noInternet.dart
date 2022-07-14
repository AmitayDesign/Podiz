import 'package:flutter/material.dart';

class NoInternet extends StatelessWidget {
  const NoInternet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration:BoxDecoration(gradient: gradient()),
      child:Column(children: [
        //backButton
        //image
        //text
        //text
      ],)
      ),
    );
  }

  LinearGradient gradient(){
    return const LinearGradient(colors: [
      Color(0xFF20053E),
      Color(0xFF210640),
      Color(0x7F190232),
      Color(0x000D011A),
    ], begin: Alignment.topCenter, end: Alignment.bottomCenter);
  }
}