import 'package:flutter/material.dart';

const Color kErrorBorder = Color(0xFFEB5757);
const Color green = Color(0xFF08BD80);
const Color bg = Color(0xFFFAFBFC);
const Color kSecondaryColor = Color(0xFF6789CA);
const Color kTextBlackColor = Colors.black54;
const Color kTextWhiteColor = Color(0xFFFFFFFF);
const Color kContainerColor = Colors.blueGrey;
const Color kOtherColor = Color(0xFFF4F6F7);
const Color kTextLightColor = Color(0xFFA5A5A5);
const Color kPrimarykeyColor = Color(0xFF345FB4);

const kDefaultPadding = 20.0;

const sizedBox = SizedBox(height: kDefaultPadding,);
const kHalfsizedBox = SizedBox(height: kDefaultPadding / 2);
const kWidthsizedBox = SizedBox(width: kDefaultPadding );
const kHalfWidthsizedBox = SizedBox(width: kDefaultPadding / 2);

//validation for mobile
const String mobilePattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';



//validation for email
const String emailPattern =
    "[a-zA-Z0-9\\+\\.\\_\\%\\-\\+]{1,256}" + "\\@"
        + "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" + "(" + "\\."
        + "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" + ")+";