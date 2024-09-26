import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

PreferredSize appBarWidget(BuildContext context) {
  return PreferredSize(
    preferredSize: AppBar().preferredSize,
    child: AppBar(
      title: Text("Marketing Up", style: TextStyle(fontFamily: GoogleFonts.caveat().fontFamily, fontSize: 28, color: Colors.white),),
      backgroundColor: Theme.of(context).primaryColor,
      iconTheme: IconThemeData(color: Colors.white),
    ),
  );
}

