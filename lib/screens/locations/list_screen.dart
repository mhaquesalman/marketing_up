import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marketing_up/models/location_model.dart';


var items = [
  'Item 1',
  'Item 2',
  'Item 3',
  'Item 4',
  'Item 5',
  'Item 6',
  'Item 7',
  'Item 8',
  'Item 9',
  'Item 10',
  'Item 11',
  'Item 12',
  'Item 13',
  'Item 14',
  'Item 15',
  'Item 16',
  'Item 17',
  'Item 18',
  'Item 19',
  'Item 20',
  'Item 21',
  'Item 22',
  'Item 23',
  'Item 24',
  'Item 25',
  'Item 26',
  'Item 27',
  'Item 28',
  'Item 29',
];

class ListScreen extends StatelessWidget {

  List<LocationModel>? locations;

  ListScreen({super.key, this.locations});

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat("MMM dd - yyyy, h:mm a");

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: ListView.separated(
        itemCount: locations?.length ?? 0,
        itemBuilder: (context, index) {
          LocationModel lm = locations![index];
          int si = (index + 1);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("#: $si"),
                Text("${lm.streetAddress.split(",")[0]}, ${lm.streetAddress.split(",")[1]}"),
                Text(dateFormat.format(lm.createdTime).split(",")[1])
              ],
            ),
          );
        },
        separatorBuilder: (context, index) => Container(height: 1, color: Colors.grey,),
      ),
    );
  }
}
