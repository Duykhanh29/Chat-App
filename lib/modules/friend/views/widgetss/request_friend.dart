import 'package:chat_app/modules/friend/views/widgetss/list_received_request.dart';
import 'package:chat_app/modules/friend/views/widgetss/list_sent_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';

class RequestFriend extends StatefulWidget {
  const RequestFriend({super.key});

  @override
  State<RequestFriend> createState() => _RequestFriendState();
}

class _RequestFriendState extends State<RequestFriend>
    with TickerProviderStateMixin {
  TabController? tabController;
  int selectedIndex = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tabController!.addListener(() {
      setState(() {
        selectedIndex = tabController!.index;
      });
    });
  }

  @override
  void dispose() {
    tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Friend Request"),
          leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.arrow_back)),
          bottom: TabBar(
            indicatorColor: Colors.greenAccent,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            controller: tabController,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(
                text: "Received",
              ),
              Tab(
                text: "Sent",
              )
            ],
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            ListReceivedRequest(),
            ListSentRequest(),
          ],
        ),
      ),
    );
  }
}
