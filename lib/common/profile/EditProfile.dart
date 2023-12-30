import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devjobs/models/freelancer/user_model.dart';
import 'package:devjobs/services/freelancer/authservice.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatefulWidget {

  final String? uid;
  EditProfile({super.key,required this.uid});

  @override
  State<EditProfile> createState() => _EditProfileState();
}
File? ProfileImage;

class _EditProfileState extends State<EditProfile> {
  Future<void>change({
   required String email,required String oldpassword,required String newpassword
})async{
    try{
      var cred=EmailAuthProvider.credential(email: email,
          password: oldpassword);
      await FirebaseAuth.instance.currentUser!
          .reauthenticateWithCredential(cred)
          .then((value)
      async{
        await FirebaseAuth.instance.currentUser!
            .updatePassword(newpassword);
        FirebaseFirestore.instance
            .collection('user')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'email':email,


          'password':newpassword
        }
        );

          });
          }
      catch(e){
      print(e.toString());
      }



  }
  TextEditingController _emailController = TextEditingController(text: '');
  TextEditingController _passwordController = TextEditingController(text: '');
  TextEditingController _cpasswordController = TextEditingController(text: '');
  TextEditingController _skillController = TextEditingController(text: '');

  String? uid;
  bool isLoading=true;
  bool _obscure=true;
  List<String> usertypes=<String>[
    "Freelancer",
    "Employer",

  ];
  var selectedValue;
  User? user=FirebaseAuth.instance.currentUser;
  final _regKey = GlobalKey<FormState>();
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    getData();
  }
  void getData() async {
    try {


      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('user')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (userDoc == null) {
        CircularProgressIndicator();
      } else {
        final _uid = FirebaseAuth.instance.currentUser!.uid;




        setState(() {
          uid=userDoc.get('id');
          _emailController.text=userDoc.get('email');
          //skills = List.from(userDoc['skills']);
          _passwordController.text=userDoc.get('password');
          _cpasswordController.text=userDoc.get('password');
          selectedValue = userDoc.get('usertype');
          _skillController.text = userDoc.get('skills');



        }

        );
        print(_emailController);
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _Image_dialogue()
  {
    showDialog(context: context, builder:(context)
    {
      return AlertDialog(
        title: Center(child: Text("Choose an option")),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: (){
                    _getfromCamera();

                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(padding: EdgeInsets.all(8),
                        child: Icon(Icons.camera),),
                      Text("Camera"),
                    ],
                  ),
                ),
                InkWell(
                  onTap: (){
                    _getfromGallery();

                  },

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(padding: EdgeInsets.all(8),
                        child: Icon(Icons.image),),
                      Text("Image"),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      );
    }
    );
  }

  void _getfromCamera()
  async{
    XFile? image=await ImagePicker().pickImage(source: ImageSource.camera);
    _cropImage(image!.path);
    Navigator.pop(context);

  }

  void _getfromGallery()
  async{
    XFile? image=await ImagePicker().pickImage(source: ImageSource.gallery);
    _cropImage(image!.path);
    Navigator.pop(context);

  }

  void _cropImage(filePath)
  async{
    CroppedFile? croppedImage =await ImageCropper().cropImage(
        sourcePath: filePath,
        maxHeight: 1080,
        maxWidth: 1080);
    if(croppedImage!=null)
    {
      setState(() {
        ProfileImage=File(croppedImage.path);
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _regKey,
        child: GestureDetector(
          onTap: (){
            _Image_dialogue();
          },
          child: Stack(
            children: [Positioned(
              child: Container(
                width: 500,
                height: 1000,
                child: Stack(children: [
                  Positioned(
                      left: 160,
                      top: 100,
                      child: Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            border: Border.all(width: 2),

                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              child: ProfileImage==null ? const Icon(
                                  Icons.add_a_photo
                              ):Image.file(ProfileImage!,fit: BoxFit.fill,),
                            ),
                          )
                      )
                  ),
                  Positioned(
                    left: 20,
                    top: 250,
                    child: Container(
                      width: 380,
                      child: TextFormField(
                        controller: _emailController,
                        validator: (value) {
                          if(value!.isEmpty || !value.contains('@'))
                          {
                            return "Invalid Email";
                          }
                          else
                          {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                            hintText: 'Email',
                            prefixIcon: Icon(Icons.alternate_email_outlined),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xFF81D4FA), width: 3),
                                borderRadius: BorderRadius.circular(40)),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xFF81D4FA), width: 3),
                                borderRadius: BorderRadius.circular(40))),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    top: 320,
                    child: Container(
                      width: 380,
                      child: TextFormField(
                        obscureText: _obscure,
                        keyboardType: TextInputType.visiblePassword,
                        validator: (value)
                        {
                          if(value!.isEmpty||value.length<7)
                          {
                            return 'Please enter valid password';
                          }
                          else
                          {
                            return null;
                          }
                        },
                        controller: _passwordController,
                        decoration: InputDecoration(
                            suffixIcon: GestureDetector(
                                onTap: (){
                                  setState(() {
                                    _obscure=!_obscure;
                                  });
                                }
                                ,child: Icon(Icons.remove_red_eye,)),
                            hintText: 'Password',
                            prefixIcon: Icon(Icons.key),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xFF81D4FA), width: 3),
                                borderRadius: BorderRadius.circular(40)),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xFF81D4FA), width: 3),
                                borderRadius: BorderRadius.circular(40))),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    top: 390,
                    child: Container(
                      width: 380,
                      child: TextFormField(
                        obscureText: _obscure,
                        controller: _cpasswordController,
                        decoration: InputDecoration(
                            suffixIcon: GestureDetector(
                                onTap: (){
                                  setState(() {
                                    _obscure=!_obscure;
                                  });
                                }
                                ,child: Icon(Icons.remove_red_eye,)),

                            hintText: 'Re-Password',
                            prefixIcon: Icon(Icons.key),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xFF81D4FA), width: 3),
                                borderRadius: BorderRadius.circular(40)),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xFF81D4FA), width: 3),
                                borderRadius: BorderRadius.circular(40))),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    top: 460,
                    child: Container(
                      width: 380,
                      height: 300,
                      child: TextFormField(
                        controller: _skillController,
                        minLines: 5,
                        maxLines: 11,
                        decoration: InputDecoration(
                            hintText: 'Skills',
                            prefixIcon: Padding(
                              padding:
                              const EdgeInsets.only(bottom: 77, left: 10),
                              child: Icon(Icons.local_activity_outlined),
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xFF81D4FA), width: 3),
                                borderRadius: BorderRadius.circular(40)),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xFF81D4FA), width: 3),
                                borderRadius: BorderRadius.circular(40))),
                      ),
                    ),
                  ),
                  Positioned(
                      top: 630, left: 145, child: Row(
                    children: [
                      Text("Role:  ",style: TextStyle(
                          fontSize: 18
                      ),),
                      DropdownButton(
                        value:selectedValue,
                        items: usertypes.map<DropdownMenuItem<String>>(
                                (String value)
                            {
                              return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value));
                            }).toList(),

                        onChanged: (newvalue){
                          setState(() {
                            selectedValue=newvalue;

                          });

                        },
                      ),
                    ],
                  )
                  ),
                  Positioned(
                    top: 700,
                    left: 20,
                    child: InkWell(
                      onTap: () async{
                        if(_regKey.currentState!.validate())
                        {
                           FirebaseFirestore.instance
                              .collection('user')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .update({
                            'email':_emailController.text,
                            'usertype':selectedValue.toString(),
                            'skills':_skillController.text.split(","),
                             'password':_passwordController.text
                          }
                          );

                           await change(email: _emailController.text,oldpassword: _passwordController.text,newpassword:_cpasswordController.text,);
                           Fluttertoast.showToast(
                               msg: "The profile has been edited",
                               toastLength: Toast.LENGTH_LONG,
                               backgroundColor: Colors.green,
                               fontSize: 18);



                        }




                      },
                      child: Container(
                        child: Center(
                            child: Text("EDIT PROFILE",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700))),
                        width: 380,
                        height: 60,
                        decoration: BoxDecoration(
                            border:
                            Border.all(color: Color(0xFF81D4FA), width: 5),
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(40)),
                      ),
                    ),
                  ),
                  // Positioned(
                  //   top: 700,
                  //   left: 20,
                  //   child: Container(
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         Image.asset(
                  //           'assets/icon/g.png',
                  //           scale: 50,
                  //         ),
                  //         Text("Sign in with google",
                  //             style: TextStyle(
                  //                 fontSize: 20, fontWeight: FontWeight.w700)),
                  //       ],
                  //     ),
                  //     width: 380,
                  //     height: 60,
                  //     decoration: BoxDecoration(
                  //         border:
                  //             Border.all(color: Color(0xFF81D4FA), width: 5),
                  //         color: Colors.transparent,
                  //         borderRadius: BorderRadius.circular(40)),
                  //   ),
                  // )
                ]),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}
