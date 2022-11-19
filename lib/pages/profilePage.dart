import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:seavive/config.dart';
import 'package:seavive/main.dart';

import '../models/account.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    Account account = context.watch<SeaVive>().account;
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Center(
        heightFactor: 1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
           children: [
             const SizedBox(height: 30.0,),
             CircleAvatar(
               radius: size.width*0.2,
               backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
               backgroundImage: NetworkImage(account.photoUrl!),
             ),
             const SizedBox(height: 30.0,),
             Text(account.name!, style: const TextStyle(fontWeight: FontWeight.bold),),
             Text(account.email!),
             Text(account.phone!),
             const SizedBox(height: 30.0,),
             Padding(
               padding: const EdgeInsets.all(10.0),
               child: RaisedButton.icon(
                 onPressed: () async {
                   await FirebaseAuth.instance.signOut();

                   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const SplashScreen()));
                 },
                 color: Theme.of(context).primaryColor,
                 elevation: 5.0,
                 shape: RoundedRectangleBorder(
                     borderRadius:
                     BorderRadius.circular(30.0)),
                 label: Text("Logout",
                     style: GoogleFonts.baloo2(
                         color: Colors.white)),
                 icon: const Icon(
                   Icons.logout,
                   color: Colors.white,
                 ),
               ),
             )
           ],
        ),
      ),
    );
  }
}
