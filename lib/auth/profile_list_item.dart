import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../constants.dart';

class ProfileListItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? MyColor;
  final Color? MySecColor;
  final bool hasNavigation;

  const ProfileListItem({
    // required Key key,
    required this.icon,
    required this.text,
    this.hasNavigation = true,
    this.MyColor,
    this.MySecColor,
  }) ;
      // : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10 * 6.5,
      margin: EdgeInsets.symmetric(
        horizontal: 10 * 2,
      ).copyWith(
        bottom: 10 * 2,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 10 * 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5 * 2),
        // color: Theme.of(context).backgroundColor,
        // color: MyColor,
        color: Colors.white,

        border: Border.all(color: Colors.black12)

      ),
      child: Row(
        children: <Widget>[
          Icon(
            this.icon,
            size: 10 * 2.5,
            color: Colors.black,
          ),
          SizedBox(width: 10 * 1.5),
          Text(
            this.text,
            style: kTitleTextStyle.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          Spacer(),
          if (this.hasNavigation)
            Icon(
              LineAwesomeIcons.angle_right,
              size: 10 * 2.5,
              color: Colors.black,
            ),
        ],
      ),
    );
  }
}
