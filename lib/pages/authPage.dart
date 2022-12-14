import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:seavive/config.dart';

import '../auth/auth.dart';
import '../commonFunctions/fileManager.dart';
import '../dialog/errorDialog.dart';
import '../models/account.dart';
import '../widgets/ProgressWidget.dart';
import '../widgets/customTextField.dart';
import 'home.dart';
import 'otpScreen.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool loading = false;
  bool isSignUp = false;
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController cPassword = TextEditingController();
  TextEditingController idNumber = TextEditingController();
  String accountType = 'Fisherman';
  bool showPassword = true;
  bool showCPassword = true;
  XFile? pickedFile;
  FirebaseAuth auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  double getWidth(Size size, SizingInformation sizeInfo) {
    if (sizeInfo.isMobile) {
      return 20.0;
    } else if (sizeInfo.isTablet) {
      return size.width * 0.2;
    } else {
      return size.width * 0.3;
    }
  }

  controlUploadAndRetrieve() async {
    setState(() {
      loading = true;
    });

    if(isSignUp) {

      final credential = await auth.createUserWithEmailAndPassword(
          email: email.text.trim(),
          password: password.text.trim()
      );

      String result = await Authentication().createUserWithPhoneNative(context,
          name: name.text.trim(),
          idNumber: idNumber.text.trim(),
          email: email.text.trim(),
          password: password.text.trim(),
          phone: phone.text.trim(),
          accountType: accountType,
          pickedFile: pickedFile,
          userCredential: credential);

      if (result.split("+").first == "success") {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(result.split("+").last)
            .get()
            .then((value) {
          Account account = Account.fromDocument(value);

          context.read<SeaVive>().switchUser(account);
        });

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const HomePage()));

        setState(() {
          loading = false;
        });
      } else {
        result = "User Aready Exists!";

        setState(() {
          loading = false;
        });
      }
    } else {

      final credential = await auth.signInWithEmailAndPassword(
          email: email.text.trim(),
          password: password.text.trim()
      );

      await FirebaseFirestore.instance.collection("users")
          .doc(credential.user!.uid).get().then((documentSnapshot) {
            if(documentSnapshot.exists) {
              Account account = Account.fromDocument(documentSnapshot);

              context.read<SeaVive>().switchUser(account);

              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => const HomePage()));

              setState(() {
                loading = false;
              });
            } else {
              Fluttertoast.showToast(msg: "Account Does Not Exist");

              setState(() {
                loading = false;
              });
            }
      });

    }
  }

  void authenticateUser() async {}

  void handleAuth(BuildContext context) async {
    setState(() {
      loading = true;
    });

    if (kIsWeb) {
      String res = "";

      if (isSignUp) {
        await FirebaseFirestore.instance
            .collection("users")
            .where("idNumber", isEqualTo: idNumber.text.trim())
            .get()
            .then((value) async {
          if (value.docs.isEmpty) {
            res = await Authentication().createUserWithPhoneWeb(context,
                name: name.text.trim(),
                idNumber: idNumber.text.trim(),
                email: email.text.isEmpty ? "" : email.text.trim(),
                password: password.text.trim(),
                phone: phone.text.trim(),
                accountType: accountType,
                pickedFile: pickedFile);
          } else {
            res = "User Already Exists!";
          }
        });
      } else {
        res = await Authentication()
            .loginUserWithPhoneWeb(context, phone: phone.text.trim());
      }

      if (res.split("+").first == "success") {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(res.split("+").last)
            .get()
            .then((value) {
          Account account = Account.fromDocument(value);

          context.read<SeaVive>().switchUser(account);
        });

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const HomePage()));

        setState(() {
          loading = false;
        });
      } else {
        showDialog<void>(
          context: context,
          barrierDismissible: true,
          // false = user must tap button, true = tap outside dialog
          builder: (BuildContext dialogContext) {
            return ErrorAlertDialog(
              message: "Error: $res",
            );
          },
        );

        setState(() {
          loading = false;
        });
      }
    } else {
      // Native platforms Android, iOS
      await auth.verifyPhoneNumber(
        phoneNumber: phone.text.trim(),
        verificationCompleted: (PhoneAuthCredential credential) async {
          UserCredential userCredential =
              await auth.signInWithCredential(credential);

         // controlUploadAndRetrieve(userCredential);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            print('The provided phone number is not valid.');

          }
        },
        codeSent: (String verificationId, int? resendToken) async {
          String smsCode = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => OTPScreen(
                    phoneNumber: phone.text.trim(),
                  )));

          if (smsCode != "cancelled") {
            PhoneAuthCredential credential = PhoneAuthProvider.credential(
                verificationId: verificationId, smsCode: smsCode);

            UserCredential userCredential =
                await auth.signInWithCredential(credential);

           // controlUploadAndRetrieve(userCredential);
        }},
        codeAutoRetrievalTimeout: (String verificationId) {
          Fluttertoast.showToast(msg: "Timeout!");
        },
      );

      // print("=====================1========================");
      //
      // String res = "";
      //
      // res = await Authentication().verifyUserWithPhone(context, isSignUp,
      //     name: name.text.trim(),
      //     idNumber: idNumber.text.trim(),
      //     email: email.text.isEmpty ? "" : email.text.trim(),
      //     password: password.text.trim(),
      //     phone: phone.text.trim(),
      //     accountType: accountType,
      //     pickedFile: pickedFile);
      //
      // print("=====================4========================");
      //
      // if (res.split("+").first == "success") {
      //   await FirebaseFirestore.instance
      //       .collection("users")
      //       .doc(res.split("+").last)
      //       .get()
      //       .then((value) {
      //     Account account = Account.fromDocument(value);
      //
      //     context.read<SeaVive>().switchUser(account);
      //   });
      //
      //   Navigator.pushReplacement(
      //       context, MaterialPageRoute(builder: (context) => const HomePage()));
      //
      //   setState(() {
      //     loading = false;
      //   });
      // } else {
      //   showDialog<void>(
      //     context: context,
      //     barrierDismissible: true,
      //     // false = user must tap button, true = tap outside dialog
      //     builder: (BuildContext dialogContext) {
      //       return ErrorAlertDialog(
      //         message: "Error: $res",
      //       );
      //     },
      //   );
      //
      //   setState(() {
      //     loading = false;
      //   });
      // }
    }
  }

  Future pickImageFromCamera(BuildContext context) async {
    final XFile? photo = await FileManager().pickPhoto(
      context: context,
      imageSource: ImageSource.camera,
      cameraDevice: CameraDevice.rear,
    );

    setState(() {
      pickedFile = photo;
    });
  }

  Widget displayPickedFile() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50.0),
      child: kIsWeb
          ? Image.network(
              pickedFile!.path,
              height: 100.0,
              width: 100.0,
              fit: BoxFit.cover,
              errorBuilder: (context, obj, stacktrace) {
                return Text("Error");
              },
            )
          : Image.file(
              File(pickedFile!.path),
              height: 100.0,
              width: 100.0,
              fit: BoxFit.cover,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ResponsiveBuilder(
      builder: (context, sizeInfo) {
        bool isMobile = sizeInfo.isMobile;

        return Scaffold(
            appBar: AppBar(
              title: const Text("Authentication"),
            ),
            body: loading
                ? circularProgress()
                : Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: getWidth(size, sizeInfo)),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text("Welcome to SeaVive",
                                  textAlign: TextAlign.center,
                                  maxLines: null,
                                  style: GoogleFonts.baloo2(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 22.0,
                                  )),
                            ),
                            isSignUp ? Container() : Image.asset(
                              "assets/login.png",
                              width: size.width,
                              fit: BoxFit.contain,
                              height: size.height*0.25,
                              ),

                            Text(isSignUp ? "Create Account" : "Log In",
                                style: GoogleFonts.baloo2(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22.0,
                                )),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: isSignUp
                                  ? [
                                      Stack(
                                        children: [
                                          pickedFile != null
                                              ? displayPickedFile()
                                              : CircleAvatar(
                                                  radius: 50.0,
                                                  backgroundColor: Colors.blue
                                                      .withOpacity(0.1),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50.0),
                                                    child: Image.asset(
                                                      "assets/profile.png",
                                                      height: 100.0,
                                                      width: 100.0,
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                ),
                                          Positioned(
                                            bottom: 0.0,
                                            right: 0.0,
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0)),
                                              child: CircleAvatar(
                                                backgroundColor: Theme.of(
                                                        context)
                                                    .scaffoldBackgroundColor,
                                                child: IconButton(
                                                  hoverColor:
                                                      Colors.transparent,
                                                  onPressed: () =>
                                                      pickImageFromCamera(
                                                          context),
                                                  icon: const Icon(
                                                    Icons.edit,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      AuthTextField(
                                        controller: name,
                                        prefixIcon: const Icon(
                                          Icons.person,
                                          color: Colors.grey,
                                        ),
                                        hintText: "Full Name",
                                        isObscure: false,
                                        inputType: TextInputType.name,
                                      ),
                                      AuthTextField(
                                        controller: phone,
                                        prefixIcon: const Icon(
                                          Icons.phone,
                                          color: Colors.grey,
                                        ),
                                        hintText: "Phone (+2547...)",
                                        isObscure: false,
                                        inputType: TextInputType.phone,
                                      ),
                                      AuthTextField(
                                        controller: idNumber,
                                        prefixIcon: const Icon(
                                          Icons.badge_outlined,
                                          color: Colors.grey,
                                        ),
                                        hintText: "ID Number",
                                        isObscure: false,
                                        inputType: TextInputType.number,
                                      ),
                                      AuthTextField(
                                        controller: email,
                                        prefixIcon: const Icon(
                                          Icons.email_outlined,
                                          color: Colors.grey,
                                        ),
                                        hintText: "Email Address",
                                        isObscure: false,
                                        inputType: TextInputType.emailAddress,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Text("Continue as...",
                                            textAlign: TextAlign.start,
                                            style: GoogleFonts.baloo2(
                                              fontSize: 16.0,
                                            )),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0, vertical: 5.0),
                                        child: DropdownSearch<String>(
                                            mode: Mode.MENU,
                                            showSelectedItems: true,
                                            items: const [
                                              "Fisherman",
                                              "Researcher",
                                              "Government",
                                            ],
                                            hint: "Continue as...",
                                            onChanged: (v) {
                                              setState(() {
                                                accountType = v!;
                                              });
                                            },
                                            selectedItem: accountType),
                                      ),
                                      AuthTextField(
                                        controller: password,
                                        prefixIcon: const Icon(
                                          Icons.lock_outline_rounded,
                                          color: Colors.grey,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: showPassword
                                              ? const Icon(
                                                  Icons.visibility_off_outlined)
                                              : const Icon(Icons.visibility),
                                          onPressed: showPassword
                                              ? () {
                                                  setState(() =>
                                                      showPassword = false);
                                                }
                                              : () {
                                                  setState(() =>
                                                      showPassword = true);
                                                },
                                        ),
                                        hintText: "Password",
                                        isObscure: showPassword,
                                        inputType:
                                            TextInputType.visiblePassword,
                                      ),
                                      AuthTextField(
                                        controller: cPassword,
                                        prefixIcon: const Icon(
                                          Icons.lock_outline_rounded,
                                          color: Colors.grey,
                                        ),
                                        hintText: "Confirm Password",
                                        isObscure: showCPassword,
                                        inputType:
                                            TextInputType.visiblePassword,
                                        suffixIcon: IconButton(
                                          icon: showCPassword
                                              ? const Icon(
                                                  Icons.visibility_off_outlined)
                                              : const Icon(Icons.visibility),
                                          onPressed: showCPassword
                                              ? () {
                                                  setState(() =>
                                                      showCPassword = false);
                                                }
                                              : () {
                                                  setState(() =>
                                                      showCPassword = true);
                                                },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: RaisedButton.icon(
                                          onPressed: () async {
                                            if (name.text.isNotEmpty &&
                                                phone.text.isNotEmpty &&
                                                idNumber.text.isNotEmpty &&
                                                email.text.isNotEmpty &&
                                                password.text.isNotEmpty &&
                                                password.text.trim() ==
                                                    cPassword.text.trim() &&
                                                cPassword.text.isNotEmpty) {
                                              FirebaseFirestore.instance
                                                  .collection("users")
                                                  .where("idNumber",
                                                      isEqualTo: idNumber
                                                          .text.isNotEmpty)
                                                  .get()
                                                  .then((querySnapshot) {
                                                if (querySnapshot
                                                    .docs.isEmpty) {
                                                  controlUploadAndRetrieve();
                                                } else {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          "User Already Exists!");
                                                }
                                              });
                                            }
                                          },
                                          color: Theme.of(context).primaryColor,
                                          elevation: 5.0,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0)),
                                          label: Text("Create",
                                              style: GoogleFonts.baloo2(
                                                  color: Colors.white)),
                                          icon: const Icon(
                                            Icons.done,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text("Already have an Account? ",
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.baloo2(
                                                  fontSize: 16.0,
                                                )),
                                            const SizedBox(
                                              width: 5.0,
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  isSignUp = false;
                                                  name.clear();
                                                  phone.clear();
                                                  email.clear();
                                                  password.clear();
                                                  cPassword.clear();
                                                });
                                              },
                                              child: Text("Log In",
                                                  style: GoogleFonts.baloo2(
                                                      color: Colors.blue)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]
                                  : [
                                      AuthTextField(
                                        controller: email,
                                        prefixIcon: const Icon(
                                          Icons.email_outlined,
                                          color: Colors.grey,
                                        ),
                                        hintText: "Email Address",
                                        isObscure: false,
                                        inputType: TextInputType.emailAddress,
                                      ),
                                      AuthTextField(
                                        controller: password,
                                        prefixIcon: const Icon(
                                          Icons.lock_open,
                                          color: Colors.grey,
                                        ),
                                        hintText: "Password",
                                        isObscure: showPassword,
                                        inputType:
                                            TextInputType.visiblePassword,
                                        suffixIcon: IconButton(
                                          icon: showPassword
                                              ? const Icon(Icons.visibility)
                                              : const Icon(Icons
                                                  .visibility_off_outlined),
                                          onPressed: showPassword
                                              ? () {
                                                  setState(() =>
                                                      showPassword = false);
                                                }
                                              : () {
                                                  setState(() =>
                                                      showPassword = true);
                                                },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: RaisedButton.icon(
                                          onPressed: () {
                                            if (email.text.isNotEmpty &&
                                                password.text.isNotEmpty) {
                                              controlUploadAndRetrieve();
                                            }
                                          },
                                          color: Theme.of(context).primaryColor,
                                          elevation: 5.0,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0)),
                                          label: Text("Login",
                                              style: GoogleFonts.baloo2(
                                                  color: Colors.white)),
                                          icon: const Icon(
                                            Icons.done,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text("Don't have an Account? ",
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.baloo2(
                                                  fontSize: 16.0,
                                                )),
                                            const SizedBox(
                                              width: 5.0,
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  isSignUp = true;
                                                  phone.clear();
                                                  password.clear();
                                                });
                                              },
                                              child: Text("Create Account",
                                                  style: GoogleFonts.baloo2(
                                                      color: Colors.blue)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ));
      },
    );
  }
}
