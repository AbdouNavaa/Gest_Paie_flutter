import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gestion_payements/auth/profile_list_item.dart';
import 'package:gestion_payements/auth/settings.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Dashboard.dart';
import '../constants.dart';
import '../main.dart';
import 'login.dart';


class ProfilePage extends StatefulWidget {
  final String? username;
  final String? role;
  final String? email;
  final String? prenom;
  final num? mobile;

  ProfilePage({this.role, this.email, this.username,this.prenom,this.mobile});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isDark = false;
  @override
  Widget build(BuildContext context) {
    // ScreenUtil.init(context, height: 896, width: 414, allowFontScaling: true);

    var profileInfo = Expanded(
      child: Column(
        children: <Widget>[
          Container(

            height: 10 * 10,
            width: 10 * 10,
            margin: EdgeInsets.only(top: 10 * 3),
            child: Stack(
              children: <Widget>[
                CircleAvatar(
                  radius: 10 * 5,backgroundColor: Colors.white,
                  // child: Image.asset("assets/user1.png",width: 90),
                  backgroundImage: AssetImage('assets/user1.png'),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    height: 10 * 2.5,
                    width: 10 * 2.5,
                    decoration: BoxDecoration(
                      // color: Theme.of(context).accentColor,
                      shape: BoxShape.circle,
                    ),
                    // child: Center(
                    //   heightFactor: 10 * 1.5,
                    //   widthFactor: 10 * 1.5,
                    //   child: Icon(
                    //     LineAwesomeIcons.pen,
                    //     color: kDarkPrimaryColor,
                    //     // size: ScreenUtil().setSp(10 * 1.5),
                    //   ),
                    // ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10 * 2),
          Text(
            widget.username!.capitalize!,
            style: TextStyle(color: isDark? Colors.white:Colors.black,
              fontWeight: FontWeight.w300,
          ),
          ),
          SizedBox(height: 10 * 0.5),
          Text(
            widget.email!,
            style: TextStyle(
              color: isDark? Colors.white:Colors.black,
              fontWeight: FontWeight.w200,
            ),
          ),
          SizedBox(height: 10 * 2),
        ],
      ),
    );

    var themeSwitcher = ThemeSwitcher(
      builder: (context) {
        return AnimatedCrossFade(
          duration: Duration(milliseconds: 2),
          crossFadeState
              : CrossFadeState.showFirst,
          firstChild: GestureDetector(
            onTap: () {
              setState(() {
                isDark = !isDark;
              });
            },
            child: Icon(
              isDark? LineAwesomeIcons.sun:LineAwesomeIcons.moon,
              // size: ScreenUtil().setSp(10 * 3),
              color: isDark? Colors.white:Colors.black,
            ),
          ),
          secondChild: GestureDetector(
            onTap: () =>
                ThemeSwitcher.of(context).changeTheme(theme: kDarkTheme),
            child: Icon(
              LineAwesomeIcons.moon,
              // size: ScreenUtil().setSp(10 * 3),
            ),
          ),
        );
      },
    );

    var header = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: 10 * 3),
        InkWell(
          child: Icon(
            LineAwesomeIcons.arrow_left,
            // size: ScreenUtil().setSp(10 * 3),
            color: isDark? Colors.white:Colors.black,
          ),
          onTap: (){
            setState(() {
              Navigator.pop(context);
            });
          },
        ),
        profileInfo,
        themeSwitcher,
        SizedBox(width: 10 * 3),
      ],
    );

    return Scaffold(
      backgroundColor: isDark? Colors.black: Color(0xFFFFFFFF),

      body: Column(
        children: <Widget>[
          SizedBox(height: 10 * 5),
          header,
          Expanded(
            child: ListView(
              children: <Widget>[
                ProfileListItem(
                  MyColor: myColor(),
                  MySecColor: mySecColor(),
                  icon: LineAwesomeIcons.user,
                  text:"Nom : ${ widget.username!.capitalize!}",
                ),
                ProfileListItem(
                  MyColor: myColor(),
                  MySecColor: mySecColor(),
                  icon: Icons.workspace_premium,
                  text:"Role : ${ widget.role!.capitalize!}",
                ),
                ProfileListItem(
                  MyColor: myColor(),
                  MySecColor: mySecColor(),
                  icon: Icons.phone,
                  text:"Role : ${ widget.role!.capitalize!}",
                ),
                ProfileListItem(
                  MyColor: myColor(),
                  MySecColor: mySecColor(),
                  icon: Icons.email_outlined,
                  text:"${ widget.email!}",
                ),
                // ProfileListItem(
                //   icon: LineAwesomeIcons.cog,
                //   text: 'Settings',
                // ),
                // ProfileListItem(
                //   icon: LineAwesomeIcons.user_plus,
                //   text: 'Invite a Friend',
                // ),
                InkWell(onTap: ()async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.setString('token', '');
                        Navigator.push(context,
                        MaterialPageRoute(builder: (context) => KeyboardVisibilityProvider(child: LoginSection())));

                },
                  child: ProfileListItem(
                    MyColor: myColor(),
                    MySecColor: mySecColor(),
                    icon: LineAwesomeIcons.alternate_sign_out,
                    text: 'Logout',
                    hasNavigation: false,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Color mySecColor() => isDark? Colors.black38:Colors.white;

  Color myColor() => isDark? Colors.white:Colors.blueGrey.shade200;
  // Color myColor() => isDark? Colors.white:Colors.black54;
}


