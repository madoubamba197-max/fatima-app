import 'package:flutter/material.dart';

import '../client/home_client_page.dart';
import '../creator/creator_home_page.dart';
import '../admin/admin_login_page.dart';
import '../super_admin/super_admin_login_page.dart';


class WelcomePage extends StatefulWidget {

  const WelcomePage({super.key});


  @override
  State<WelcomePage> createState() => _WelcomePageState();

}



class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {


  late AnimationController _controller;

  late Animation<double> _scaleAnimation;

  late Animation<double> _fadeAnimation;


  int adminTap = 0;



  @override
  void initState() {

    super.initState();


    _controller = AnimationController(

      duration: const Duration(seconds: 2),

      vsync: this,

    );


    _scaleAnimation = Tween<double>(

      begin: 0.6,

      end: 1,

    ).animate(

      CurvedAnimation(

        parent: _controller,

        curve: Curves.elasticOut,

      ),

    );


    _fadeAnimation = Tween<double>(

      begin: 0,

      end: 1,

    ).animate(

      CurvedAnimation(

        parent: _controller,

        curve: Curves.easeIn,

      ),

    );


    _controller.forward();


  }



  @override
  void dispose() {

    _controller.dispose();

    super.dispose();

  }



  void _tapSuperAdmin() {


    adminTap++;


    if(adminTap >= 5){


      adminTap = 0;


      Navigator.push(

        context,

        MaterialPageRoute(

          builder: (_) => const SuperAdminLoginPage(),

        ),

      );


    }


  }




  void _longPressMerchant(){


    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) => const AdminLoginPage(),

      ),

    );


  }




  @override
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor: Colors.white,


      body: SafeArea(

        child: Center(

          child: FadeTransition(

            opacity: _fadeAnimation,


            child: Column(

              mainAxisAlignment:
              MainAxisAlignment.center,


              children: [



                GestureDetector(

                  onTap: _tapSuperAdmin,

                  onLongPress: _longPressMerchant,


                  child: ScaleTransition(

                    scale: _scaleAnimation,


                    child: Container(

                      width: 230,

                      height: 230,


                      decoration: BoxDecoration(

                        shape: BoxShape.circle,


                        gradient: const LinearGradient(

                          colors: [

                            Colors.orange,

                            Colors.deepOrange,

                          ],

                        ),


                        boxShadow: [


                          BoxShadow(

                            color: Colors.orange
                                .withOpacity(0.5),

                            blurRadius: 35,

                            spreadRadius: 10,

                          )

                        ],

                      ),



                      child: const Center(

                        child: Text(

                          "FATIMA",


                          style: TextStyle(

                            color: Colors.white,

                            fontSize: 45,

                            fontWeight:
                            FontWeight.bold,

                            letterSpacing: 5,

                          ),

                        ),

                      ),

                    ),

                  ),

                ),



                const SizedBox(height:40),




                const Text(

                  "Bienvenue dans FATIMA",

                  style: TextStyle(

                    fontSize: 30,

                    fontWeight: FontWeight.bold,

                  ),

                ),




                const SizedBox(height:15),




                const Padding(

                  padding:
                  EdgeInsets.symmetric(horizontal:40),


                  child: Text(

                    "La plateforme qui connecte "
                    "les commerces et leurs clients.",


                    textAlign: TextAlign.center,


                    style: TextStyle(

                      fontSize:18,

                      color:Colors.grey,

                    ),

                  ),

                ),




                const SizedBox(height:60),





                SizedBox(

                  width:280,

                  height:55,


                  child: ElevatedButton(

                    style: ElevatedButton.styleFrom(

                      backgroundColor:Colors.orange,


                      shape:
                      RoundedRectangleBorder(

                        borderRadius:
                        BorderRadius.circular(30),

                      ),

                    ),



                    onPressed:(){


                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder:(_)=>
                          const HomeClientPage(),

                        ),

                      );


                    },


                    child:const Text(

                      "ENTRER",

                      style:TextStyle(

                        fontSize:22,

                        color:Colors.white,

                        fontWeight:
                        FontWeight.bold,

                      ),

                    ),


                  ),

                ),



              ],

            ),

          ),

        ),

      ),

    );


  }


}