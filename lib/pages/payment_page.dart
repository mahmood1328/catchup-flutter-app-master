import 'package:catchup/api/auth.dart';
import 'package:catchup/colors.dart';
import 'package:catchup/global.dart';
import 'package:catchup/ui/ErrorSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  PlanType type;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CatchupColors.black,
        elevation: 0,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () => Navigator.pop(context)),
      ),
      backgroundColor: CatchupColors.black,
      body: Builder(
      builder: (context) => SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 50,),
            Image.asset(
              'assets/logo.png',
              width: 200,
            ),
            SizedBox(height: 100,),
            item(PlanType.SILVER),
            item(PlanType.GOLD),
            item(PlanType.PRO),
            SizedBox(
              height: 50,
            ),
            if (type != null)
              GestureDetector(
                onTap: () async{
                  setState(() {
                    isLoading = true;
                  });
                  try {
                    String address = await Auth.redirectBuy(Global.user.token,
                        type == PlanType.SILVER ? 'Silver' :
                        type == PlanType.GOLD ? "Gold" : "Pro");

                    await canLaunch(address)
                        ? await launch(address)
                        : throw 'Could not launch $address';
                  }on AuthException catch(e){
                    Scaffold.of(context).showSnackBar(ErrorSnackBar(e.cause));
                  }
                },
                child: Container(
                  width: 150,
                  height: 50,
                  decoration: BoxDecoration(
                    color: CatchupColors.orange,
                    borderRadius: BorderRadius.circular(30),

                  ),
                  child: Center(
                    child: isLoading ? CircularProgressIndicator() : Text('Buy' ,   style: TextStyle(color: Colors.white),),
                  ),
                ),
              ),

            SizedBox(height: 50,),
          ],
        ),
      ),
      ),
    );
  }

  Widget item(PlanType planType) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (planType == type) {
            type = null;
          } else {
            type = planType;
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height / 50,
            horizontal: MediaQuery.of(context).size.width / 100 * 12),
        decoration: BoxDecoration(
          color: type == planType
              ? CatchupColors.red.withOpacity(.6)
              : Colors.transparent,
          border: Border.all(color: CatchupColors.red),
          borderRadius: BorderRadius.circular(30),
        ),
        child: ListTile(
          title: Text(
            planType == PlanType.SILVER
                ? 'Annual 3 User'
                : planType == PlanType.GOLD
                    ? 'Annual 5 User'
                    : 'Annual 10 User',
          style: TextStyle(color: Colors.white),),
          leading: Padding(
              padding: EdgeInsets.symmetric(vertical: 13),
              child: Image.asset('assets/crown.png')),
          trailing: Text(
            planType == PlanType.SILVER
                ? '2.99\$'
                : planType == PlanType.GOLD
                    ? '3.99\$'
                    : '7.99\$',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

enum PlanType { FREE, SILVER, GOLD, PRO }
