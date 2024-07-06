
import 'package:flutter/material.dart';
// import 'package:hexcolor/hexcolor.dart';

class ThemeHelper{

  InputDecoration textInputDecoration([String lableText="", String hintText = "",IconData? icon,VoidCallback? onPress]){
    return InputDecoration(
      labelText: lableText,
      hintText: hintText,
        prefixIcon: IconButton(
          icon: Icon(
            icon,
            color: Colors.black12.withOpacity(.3),
          ),
          onPressed:onPress,
        ),
        border: InputBorder.none,
        hintMaxLines: 1,
        // hintText: hintText,
        iconColor: Colors.black12,
        hintStyle: TextStyle(
          fontSize: 14,
          color: Colors.black12.withOpacity(.5),
        ),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),borderSide: BorderSide(color: Colors.black12,),),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),borderSide: BorderSide(color: Colors.black12,),),
        errorBorder: UnderlineInputBorder(borderRadius: BorderRadius.circular(15),borderSide: BorderSide(color: Colors.redAccent,),),
        focusedErrorBorder: UnderlineInputBorder(borderRadius: BorderRadius.circular(15),borderSide: BorderSide(color: Colors.redAccent,),),
        contentPadding: EdgeInsets.symmetric(vertical: 18)
    );
  }

  BoxDecoration inputBoxDecorationShaddow() {
    return BoxDecoration(
      color: Colors.white,
        boxShadow: [
      BoxShadow(
        // color: Colors.black.withOpacity(0.7),
        // blurRadius: 5,
        // offset: const Offset(0, 5),
      )
    ]
    );
  }

  BoxDecoration buttonBoxDecoration(BuildContext context, [String color1 = "", String color2 = ""]) {
    Color c1 = Colors.indigo;
    Color c2 = Colors.white;
    // if (color1.isEmpty == false) {
    //   c1 = color1;
    // }
    // if (color2.isEmpty == false) {
    //   c2 = HexColor(color2);
    // }

    return BoxDecoration(
      boxShadow: [
        BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 5.0)
      ],
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 1.0],
        colors: [
          c1,
          c2,
        ],
      ),
      color: Colors.black,
      borderRadius: BorderRadius.circular(30),
    );
  }

  ButtonStyle buttonStyle() {
    return ButtonStyle(
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      minimumSize: MaterialStateProperty.all(Size(50, 50)),
      backgroundColor: MaterialStateProperty.all(Colors.transparent),
      shadowColor: MaterialStateProperty.all(Colors.transparent),
    );
  }

  AlertDialog alartDialog(String title, String content, BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          child: Text(
            "OK",
            style: TextStyle(color: Colors.white),
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.black38)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

}

class LoginFormStyle{

}
