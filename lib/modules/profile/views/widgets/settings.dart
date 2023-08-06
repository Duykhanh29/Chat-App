import 'package:chat_app/modules/messeger/views/widgets/components/view_media_file_link.dart';
import 'package:chat_app/modules/profile/views/widgets/settings_widgets/chat_settings.dart';
import 'package:chat_app/modules/profile/views/widgets/settings_widgets/help_centre.dart';
import 'package:chat_app/modules/profile/views/widgets/settings_widgets/language.dart';
import 'package:chat_app/modules/profile/views/widgets/settings_widgets/notifications.dart';
import 'package:chat_app/modules/profile/views/widgets/settings_widgets/security.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import './settings_widgets/account_settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => const Account());
              },
              child: SizedBox(
                height: 60,
                child: ListTile(
                  leading: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.blue.withOpacity(0.1)),
                      child:
                          const Icon(Icons.person_rounded, color: Colors.blue)),
                  title: const Text("Account"),
                  trailing: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.navigate_next_sharp)),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => const ChattingSettings());
              },
              child: SizedBox(
                height: 60,
                child: ListTile(
                  leading: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.blue.withOpacity(0.1)),
                      child: const Icon(Icons.chat_bubble_outline,
                          color: Colors.blue)),
                  title: const Text("Chat"),
                  trailing: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.navigate_next_sharp)),
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => const Notifications());
              },
              child: SizedBox(
                // decoration:
                //     BoxDecoration(border: Border.all(color: Colors.black45)),
                height: 60,
                child: Center(
                  child: ListTile(
                    leading: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.blue.withOpacity(0.1)),
                        child: const Icon(Icons.notifications,
                            color: Colors.blue)),
                    title: const Text("Notifications"),
                    trailing: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.navigate_next_sharp)),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => const SecuritySettings());
              },
              child: SizedBox(
                height: 60,
                child: ListTile(
                  leading: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.blue.withOpacity(0.1)),
                      child: const Icon(Icons.security_outlined,
                          color: Colors.blue)),
                  title: const Text("Security"),
                  trailing: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.navigate_next_sharp)),
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => const Language());
              },
              child: SizedBox(
                height: 60,
                child: ListTile(
                  leading: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.blue.withOpacity(0.1)),
                      child: const Icon(Icons.language_rounded,
                          color: Colors.blue)),
                  title: const Text("Language"),
                  trailing: FittedBox(
                    child: Row(
                      children: [
                        const Text("English(US)"),
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.navigate_next_sharp))
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => const HelpCentre());
              },
              child: SizedBox(
                height: 60,
                child: ListTile(
                  leading: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.blue.withOpacity(0.1)),
                      child: const Icon(Icons.help, color: Colors.blue)),
                  title: const Text("Helps centre"),
                  trailing: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.navigate_next_sharp)),
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            SizedBox(
              height: 60,
              child: ListTile(
                leading: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.blue.withOpacity(0.1)),
                    child: const Icon(Icons.change_circle, color: Colors.blue)),
                title: const Text("Dark mode"),
                trailing: Switch(
                  value: false,
                  onChanged: (value) {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
