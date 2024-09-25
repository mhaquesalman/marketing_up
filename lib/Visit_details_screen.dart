import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:marketing_up/imagemodel.dart';
import 'package:marketing_up/visitmodel.dart';

class VisitDetailsScreen extends StatelessWidget {
  final VisitModel visitModel;
  final List<ImageModel> imageModels;
  final DateFormat dateFormat = DateFormat("MMM dd - yy, h:mm a");

  VisitDetailsScreen({super.key, required this.visitModel, required this.imageModels});

  @override
  Widget build(BuildContext context) {
    // print("image: ${imageModels[0].image}");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Visited At: ${visitModel.company}"),
            Text("Visited To: ${visitModel.person}"),
            Text("Phone: ${visitModel.phone}"),
            Text("Date & Time: ${dateFormat.format(visitModel.date)}"),
            imageModels.isNotEmpty ?
            Text("Available Photos", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),)
            : Text(""),
            Container(
              height: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(imageModels.length, (int index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.memory(base64Decode(imageModels[index].image)),
                  );
                }),
              ),
            )
            // Image.memory(
            //   base64Decode(imageModels[0].image),
            //   width: 150,
            //   height: 150,
            // )
          ],
        ),
      ),
    );
  }
}
