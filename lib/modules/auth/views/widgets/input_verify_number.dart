import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/register.dart';
import 'package:chat_app/service/auth.dart';

class VerifyPhone extends StatefulWidget {
  const VerifyPhone({super.key});

  @override
  State<VerifyPhone> createState() => _VerifyPhoneState();
}

class _VerifyPhoneState extends State<VerifyPhone> {
  late TextEditingController number1;
  late TextEditingController number2;
  late TextEditingController number3;
  late TextEditingController number4;
  late TextEditingController number5;
  late TextEditingController number6;
  @override
  void initState() {
    number1 = TextEditingController();
    number2 = TextEditingController();
    number3 = TextEditingController();
    number4 = TextEditingController();
    number5 = TextEditingController();
    number6 = TextEditingController();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    number1.dispose();
    number2.dispose();
    number3.dispose();
    number4.dispose();
    number5.dispose();
    number6.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // toolbarOpacity: 0.5,
        // bottomOpacity: 0.5,
        // backgroundColor: Color(0xfff7f6fb),
        title: const Text("Verification"),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 90,
              ),
              const Text(
                "Code has been seen to +84964651146",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                "Enter your OTP code number",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
              ),
              const SizedBox(
                height: 40,
              ),
              Form(
                child: FittedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // SizedBox(
                      //   height: MediaQuery.of(context).size.width * 0.2,
                      //   width: MediaQuery.of(context).size.width * 0.2,
                      //   child: TextFormField(
                      //     onChanged: (value) {
                      //       if (value.length == 1) {
                      //         FocusScope.of(context).nextFocus();
                      //       }
                      //     },
                      //     textAlign: TextAlign.center,
                      //     inputFormatters: [
                      //       LengthLimitingTextInputFormatter(1),
                      //       FilteringTextInputFormatter.digitsOnly
                      //     ],
                      //     keyboardType: TextInputType.number,
                      //     controller: number1,
                      //     decoration: InputDecoration(
                      //       border: OutlineInputBorder(
                      //         borderRadius: BorderRadius.circular(5),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: MediaQuery.of(context).size.width * 0.2,
                      //   width: MediaQuery.of(context).size.width * 0.2,
                      //   child: TextFormField(
                      //     onChanged: (value) {
                      //       if (value.length == 1) {
                      //         FocusScope.of(context).nextFocus();
                      //       }
                      //     },
                      //     textAlign: TextAlign.center,
                      //     inputFormatters: [
                      //       LengthLimitingTextInputFormatter(1),
                      //       FilteringTextInputFormatter.digitsOnly
                      //     ],
                      //     controller: number2,
                      //     keyboardType: TextInputType.number,
                      //     decoration: InputDecoration(
                      //       border: OutlineInputBorder(
                      //         borderRadius: BorderRadius.circular(5),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: MediaQuery.of(context).size.width * 0.2,
                      //   width: MediaQuery.of(context).size.width * 0.2,
                      //   child: TextFormField(
                      //     onChanged: (value) {
                      //       if (value.length == 1) {
                      //         FocusScope.of(context).nextFocus();
                      //       }
                      //     },
                      //     textAlign: TextAlign.center,
                      //     inputFormatters: [
                      //       LengthLimitingTextInputFormatter(1),
                      //       FilteringTextInputFormatter.digitsOnly
                      //     ],
                      //     controller: number3,
                      //     keyboardType: TextInputType.number,
                      //     decoration: InputDecoration(
                      //       border: OutlineInputBorder(
                      //         borderRadius: BorderRadius.circular(5),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: MediaQuery.of(context).size.width * 0.2,
                      //   width: MediaQuery.of(context).size.width * 0.2,
                      //   child: TextFormField(
                      //     onChanged: (value) {
                      //       if (value.length == 1) {
                      //         FocusScope.of(context).nextFocus();
                      //       }
                      //     },
                      //     textAlign: TextAlign.center,
                      //     inputFormatters: [
                      //       LengthLimitingTextInputFormatter(1),
                      //       FilteringTextInputFormatter.digitsOnly
                      //     ],
                      //     controller: number4,
                      //     keyboardType: TextInputType.number,
                      //     decoration: InputDecoration(
                      //       border: OutlineInputBorder(
                      //         borderRadius: BorderRadius.circular(5),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      _textFieldOTP(true, false, context, number1),
                      _textFieldOTP(false, false, context, number2),
                      _textFieldOTP(false, false, context, number3),
                      _textFieldOTP(false, false, context, number4),
                      _textFieldOTP(false, false, context, number5),
                      _textFieldOTP(false, true, context, number6),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(15)),
                height: 50,
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: () async {
                    String text = number1.text +
                        number2.text +
                        number3.text +
                        number4.text +
                        number5.text +
                        number6.text;
                    print("Text is: $text");
                    await AuthService().verifyPhoneNumber(text);
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  child: const Text("Send"),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              TextButton(
                  onPressed: () {},
                  child: const Text("Resend new code in x(s)"))
            ],
          ),
        ),
      ),
    );
  }
}

Widget _textFieldOTP(bool first, bool last, BuildContext context,
    TextEditingController controller) {
  return Container(
    height: 60,
    child: AspectRatio(
      aspectRatio: 1.0,
      child: TextField(
        autofocus: true,
        onChanged: (value) {
          if (value.length == 1 && last == false) {
            FocusScope.of(context).nextFocus();
          }
          if (value.length == 0 && first == false) {
            FocusScope.of(context).previousFocus();
          }
        },
        showCursor: false,
        readOnly: false,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        keyboardType: TextInputType.number,
        maxLength: 1,
        controller: controller,
        decoration: InputDecoration(
          counter: const Offstage(),
          enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(width: 2, color: Colors.black12),
              borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(width: 2, color: Colors.purple),
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    ),
  );
}
