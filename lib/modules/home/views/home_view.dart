import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import '../../messeger/views/widgets/user_online.dart';
import '../../messeger/views/widgets/list_messeger.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome back"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.12,
              child: Row(
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                          radius: 30,
                          child: IconButton(
                              onPressed: () {
                                print("add story");
                              },
                              icon: const Icon(
                                Icons.add,
                                size: 25,
                              ))),
                      const SizedBox(
                        height: 4,
                      ),
                      const Text(
                        "Add story",
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  // Expanded(
                  //   child: ListView.separated(
                  //       separatorBuilder: (context, index) => const SizedBox(
                  //             width: 3,
                  //           ),
                  //       scrollDirection: Axis.horizontal,
                  //       itemBuilder: (context, index) {
                  //         return  UserOnline(user: lis,);
                  //       },
                  //  itemCount: 8),
                  // child: CustomScrollView(
                  //   slivers: [
                  //     SliverToBoxAdapter(
                  //       child: UserOnline(),
                  //     )
                  //   ],
                  // ),
                  //           ),
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            const ListMesseger(),
          ],
        ),
      ),
    );
  }
}
