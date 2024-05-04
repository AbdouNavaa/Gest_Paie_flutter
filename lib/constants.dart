import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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


const kSpacingUnit = 10;

const kDarkPrimaryColor = Color(0xFF212121);
const kDarkSecondaryColor = Color(0xFF373737);
const kLightPrimaryColor = Color(0xFFFFFFFF);
const kLightSecondaryColor = Color(0xFFF3F7FB);
const kAccentColor = Color(0xFFFFC107);

final kTitleTextStyle = TextStyle(
  // fontSize: ScreenUtil().setSp(kSpacingUnit.w * 1.7),
  fontWeight: FontWeight.w600,
);

final kCaptionTextStyle = TextStyle(
  // fontSize: ScreenUtil().setSp(10 * 1.3),
  fontWeight: FontWeight.w100,
);

final kButtonTextStyle = TextStyle(
  // fontSize: ScreenUtil().setSp(kSpacingUnit.w * 1.5),
  fontWeight: FontWeight.w400,
  color: kDarkPrimaryColor,
);

final kDarkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'SFProText',
  primaryColor: kDarkPrimaryColor,
  canvasColor: kDarkPrimaryColor,
  backgroundColor: kDarkSecondaryColor,
  // accentColor: kAccentColor,
  iconTheme: ThemeData.dark().iconTheme.copyWith(
    color: kLightSecondaryColor,
  ),
  textTheme: ThemeData.dark().textTheme.apply(
    fontFamily: 'SFProText',
    bodyColor: kLightSecondaryColor,
    displayColor: kLightSecondaryColor,
  ),
);

final kLightTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'SFProText',
  primaryColor: kLightPrimaryColor,
  canvasColor: kLightPrimaryColor,
  backgroundColor: kLightSecondaryColor,
  // accentColor: kAccentColor,

  iconTheme: ThemeData.light().iconTheme.copyWith(
    color: kDarkSecondaryColor,
  ),
  textTheme: ThemeData.light().textTheme.apply(
    fontFamily: 'SFProText',
    bodyColor: kDarkSecondaryColor,
    displayColor: kDarkSecondaryColor,
  ),
);
