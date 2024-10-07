import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_up/app_provider.dart';
import 'package:provider/provider.dart';

PreferredSize appBarWidget(BuildContext context, {Widget? leading}) {
  return PreferredSize(
    preferredSize: AppBar().preferredSize,
    child: AppBar(
      elevation: 20,
      title: Text("Marketing Up", style: TextStyle(fontFamily: GoogleFonts.caveat().fontFamily,
          fontSize: 28, color: Colors.white),),
      backgroundColor: Theme.of(context).primaryColor,
      leading: leading,
      iconTheme: IconThemeData(color: Colors.white),
    ),
  );
}

