import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Approval requests"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // ListApprovalRequest()
          ],
        ),
      ),
    );
  }
}
// class ListApprovalRequest extends StatelessWidget {
//   const ListApprovalRequest({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(builder: (context, snapshot) {
//       if(snapshot.connectionState==ConnectionState.none){
//         return const SizedBox();
//       }else if(snapshot.connectionState==ConnectionState.waiting){
//  return const Center(child: CircularProgressIndicator(),);
//       }else{
//         if(snapshot.data!=null){
// return const SizedBox();
//         }else{
//           return const SizedBox();
//         }
//       }
//     },stream: ,);
//   }
// }