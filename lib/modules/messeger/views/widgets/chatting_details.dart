import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';

class ChattingDetails extends GetView<MessageController> {
  ChattingDetails({super.key});

  Widget showSearch1(
      MessageController messageController, MessageData messageData) {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: TextField(
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            //hanlde the value when user click search in
            messageController.searchMessages(value, messageData);
            Get.back();
          },
          controller: messageController.searchController,
          decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search...',
              suffixIcon: IconButton(
                  onPressed: () {
                    messageController.searchController.text = "";
                  },
                  icon: const Icon(Icons.cancel_rounded)),
              border: InputBorder.none
              //  OutlineInputBorder(
              // //  borderRadius: BorderRadius.circular(15),
              // ),
              ),
        ),
      ),
    );
  }

  //var searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageController>();
    MessageData messageData = Get.arguments;
    // User sender = messageData.sender!;
    User? receiver =
        controller.userGetUserFromIDBYGetX(messageData.receivers!.last);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          leading: Obx(() => controller.isSearch.value
              ? IconButton(
                  onPressed: () {
                    controller.cancelSearch();
                  },
                  icon: const Icon(Icons.arrow_back),
                )
              : IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: const Icon(Icons.arrow_back),
                )),
          title: Obx(() => controller.isSearch.value
              ? showSearch1(controller, messageData)
              : const Text(""))),
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 30,
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: receiver!.userStatus == UserStatus.ONLINE
                        ? Colors.blue
                        : Colors.grey,
                    child: CircleAvatar(
                      radius: 53,
                      backgroundImage: NetworkImage(receiver.urlImage!),
                    ),
                  ),
                  // user.userStatus == UserStatus.ONLINE
                  //     ? Positioned(
                  //         left: 80,
                  //         right: 0,
                  //         bottom: 8,
                  //         child: Container(
                  //           width: 15,
                  //           height: 15,
                  //           decoration: const BoxDecoration(
                  //               shape: BoxShape.circle, color: Colors.green),
                  //         ),
                  //       )
                  //     : Container()
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                receiver.name!,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    label: const Text("Profile"),
                    icon: const Icon(Icons.info_rounded),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    label: const Text("Mute"),
                    icon: const Icon(Icons.notifications),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              const Text("Customization"),
              Container(
                height: MediaQuery.of(context).size.height * 0.15,
                width: MediaQuery.of(context).size.width,
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  color: Color.fromARGB(255, 194, 232, 247),
                  shadowColor: Color.fromARGB(255, 248, 149, 149),
                  child: ListView(
                    children: [
                      ListTile(
                        title: const Text("Theme"),
                        onTap: () {},
                        leading: const Icon(
                          Icons.color_lens,
                          color: Colors.red,
                        ),
                      ),
                      const Divider(
                        height: 2,
                        color: Color.fromARGB(255, 42, 42, 42),
                      ),
                      ListTile(
                        title: const Text("Nickname"),
                        onTap: () {},
                        leading: const Icon(
                          Icons.abc_outlined,
                          color: Colors.black,
                        ),
                      ),
                      const Divider(
                        height: 2,
                        color: Color.fromARGB(255, 42, 42, 42),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              FittedBox(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Actions"),
                    ]),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.15,
                width: MediaQuery.of(context).size.width,
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  color: Color.fromARGB(255, 194, 232, 247),
                  shadowColor: Color.fromARGB(255, 248, 149, 149),
                  child: ListView(
                    children: [
                      ListTile(
                        title: const Text("Search"),
                        onTap: () {
                          controller.searchMode();
                          if (controller.isSearch.value) {
                            print("true");
                          } else {
                            print("false");
                          }
                        },
                        leading: const Icon(
                          Icons.search_outlined,
                          color: Colors.deepOrange,
                        ),
                      ),
                      const Divider(
                        height: 2,
                        color: Color.fromARGB(255, 42, 42, 42),
                      ),
                      ListTile(
                        title: Text("Create Group with ${receiver.name}"),
                        onTap: () {},
                        leading: const Icon(
                          Icons.group_add_outlined,
                          color: Colors.purpleAccent,
                        ),
                      ),
                      const Divider(
                        height: 2,
                        color: Color.fromARGB(255, 42, 42, 42),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
