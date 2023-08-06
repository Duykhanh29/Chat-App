import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/utils/constants/image_data.dart';
import 'package:chat_app/utils/helpers/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' show PreviewData;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chat_app/utils/utils.dart';
import 'package:chat_app/service/storage_service.dart';
import 'package:video_player/video_player.dart';

class ViewMediaLink extends StatefulWidget {
  const ViewMediaLink({super.key});

  @override
  State<ViewMediaLink> createState() => _ViewMediaLinkState();
}

class _ViewMediaLinkState extends State<ViewMediaLink>
    with TickerProviderStateMixin {
  TabController? tabBarController;
  int _selectedIndex = 0;
  @override
  void initState() {
    // TODO: implement initState
    tabBarController = TabController(length: 3, vsync: this);
    tabBarController!.addListener(() {
      setState(() {
        _selectedIndex = tabBarController!.index;
      });
      print("Selected Index: " + tabBarController!.index.toString());
    });
    super.initState();
  }

  @override
  void dispose() {
    tabBarController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final msgController = Get.find<MessageController>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Media, files and links"),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontStyle: FontStyle.italic),
            overlayColor:
                MaterialStateColor.resolveWith((Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) {
                return Colors.blue;
              }
              if (states.contains(MaterialState.focused)) {
                return Colors.orange;
              } else if (states.contains(MaterialState.hovered)) {
                return Colors.pinkAccent;
              }

              return Colors.transparent;
            }),
            physics: const BouncingScrollPhysics(),
            onTap: (int index) {
              print('Tab $index is tapped');
            },
            padding: const EdgeInsets.all(5),
            enableFeedback: true,
            controller: tabBarController,
            isScrollable: false,
            indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.greenAccent),
            indicatorWeight: 2,
            indicatorSize: TabBarIndicatorSize.tab,
            // indicatorColor: Colors.amberAccent,
            tabs: const [
              Tab(
                text: "Media",
              ),
              Tab(
                text: "Files",
              ),
              Tab(
                text: "Links",
              )
            ],
          ),
        ),
        body: TabBarView(
          controller: tabBarController,
          children: [ListMedia(), const ListFiles(), ViewLink()],
        ),
      ),
    );
  }
}

class ListFiles extends StatelessWidget {
  const ListFiles({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class ListMedia extends StatelessWidget {
  ListMedia({super.key});
  List llist = [
    ImageData.googleLogo,
    ImageData.googleLogo,
    ImageData.googleLogo,
    ImageData.googleLogo,
    ImageData.googleLogo,
    ImageData.googleLogo,
    ImageData.googleLogo,
    ImageData.googleLogo,
    ImageData.googleLogo,
    ImageData.googleLogo,
    ImageData.googleLogo,
    ImageData.googleLogo,
    ImageData.googleLogo,
    ImageData.googleLogo,
    ImageData.googleLogo,
    ImageData.googleLogo,
    ImageData.googleLogo,
    ImageData.googleLogo,
    ImageData.googleLogo,
    ImageData.googleLogo,
    ImageData.googleLogo,
    ImageData.googleLogo,
    ImageData.googleLogo,
    ImageData.googleLogo,
    ImageData.googleLogo,
    ImageData.googleLogo,
    ImageData.googleLogo,
    ImageData.googleLogo,
    ImageData.googleLogo,
    ImageData.googleLogo,
    ImageData.googleLogo,
    ImageData.googleLogo,
    ImageData.googleLogo,
    ImageData.googleLogo,
    ImageData.googleLogo,
    ImageData.googleLogo,
  ];
  Storage storage = Storage();
  @override
  Widget build(BuildContext context) {
    final msgController = Get.find<MessageController>();
    List<Map<String, String>> listMedia = msgController.listMedia!.value;
    return Theme(
      data: Theme.of(context).copyWith(
          scrollbarTheme: ScrollbarThemeData(
              thumbColor: MaterialStateProperty.all<Color>(Colors.blueAccent))),
      child: Scrollbar(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.only(bottom: 10, top: 6, right: 5, left: 5),
            child: Wrap(
              spacing: MediaQuery.of(context).size.width * 0.01,
              runSpacing: MediaQuery.of(context).size.width * 0.01,
              direction: Axis.horizontal,
              children: List.generate(listMedia.length, (index) {
                var item = listMedia[index];
                final key = item.keys.first;
                final url = item.values.first;
                if (key == 'images') {
                  return ImageCard(url: url, storage: storage);
                }
                return VideoCard(url: url, storage: storage);
              }
                  // return Text(values.last);
                  // for (var url in values) {

                  // }
                  // },
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class VideoCard extends StatelessWidget {
  VideoCard({super.key, required this.url, required this.storage});
  String url;
  Storage storage;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black45)),
        height: MediaQuery.of(context).size.width * 0.23,
        width: MediaQuery.of(context).size.width * 0.23,
        child: const Center(
          child: Icon(Icons.play_arrow),
        ),
      ),
      onTap: () {
        Get.to(() => Scaffold(
              appBar: AppBar(
                actions: [
                  IconButton(
                      onPressed: () async {
                        await storage.downloadFileToLocalDevice(url, "video");
                      },
                      icon: const Icon(Icons.download))
                ],
              ),
              body: PlayerVideo(url: url),
            ));
      },
    );
  }
}

class PlayerVideo extends StatefulWidget {
  PlayerVideo({super.key, required this.url});
  String url;

  @override
  State<PlayerVideo> createState() => _PlayerVideoState();
}

class _PlayerVideoState extends State<PlayerVideo> {
  late VideoPlayerController controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool isPlayed = false;
  Duration position = Duration.zero;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = VideoPlayerController.network(widget.url)
      ..addListener(() {
        setState(() {
          position = controller.value.position;
        });
      })
      ..setLooping(false)
      ..initialize().then((value) {
        if (isPlayed) {
          controller.play();
        }
      });
  }

  void playVideo() {
    setState(() {
      if (controller.value.isInitialized) {
        controller.seekTo(position);
      }
      controller.play();
      isPlayed = true;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return controller != null && controller.value.isInitialized
        ? Container(
            height: MediaQuery.of(context).size.height * 0.85,
            width: MediaQuery.of(context).size.width * 0.85,
            alignment: Alignment.topCenter,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 1.5,
                  child: VideoPlayer(controller),
                ),
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => controller.value.isPlaying
                        ? controller.pause()
                        : playVideo(),
                    child: Stack(
                      children: <Widget>[
                        controller.value.isPlaying
                            ? Container()
                            : Container(
                                alignment: Alignment.center,
                                color: Colors.black26,
                                child: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 45,
                                ),
                              ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: VideoProgressIndicator(controller,
                              allowScrubbing: true),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        : Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.indigo, width: 1)),
            height: MediaQuery.of(context).size.height * 0.85,
            width: MediaQuery.of(context).size.width * 0.85,
            child: const Center(child: CircularProgressIndicator()),
          );
  }
}

class ImageCard extends StatelessWidget {
  const ImageCard({
    super.key,
    required this.url,
    required this.storage,
  });

  final String url;
  final Storage storage;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Validators.isSVG(url)
          ? Utils.showSVGImage(
              url: url,
              height: MediaQuery.of(context).size.width * 0.23,
              width: MediaQuery.of(context).size.width * 0.23)
          : Utils.showCacheImage(
              url: url,
              height: MediaQuery.of(context).size.width * 0.23,
              width: MediaQuery.of(context).size.width * 0.23),
      // Image.asset(
      //   listMedia[index],
      //   height: MediaQuery.of(context).size.width * 0.23,
      //   width: MediaQuery.of(context).size.width * 0.23,
      // ),
      onTap: () {
        Get.to(() => Scaffold(
              appBar: AppBar(
                actions: [
                  IconButton(
                      onPressed: () async {
                        await storage.downloadFileToLocalDevice(url, "image");
                      },
                      icon: const Icon(Icons.download))
                ],
              ),
              body: Center(
                child: PhotoView(imageProvider: NetworkImage(url)),
              ),
            ));
      },
    );
  }
}

class ViewLink extends StatelessWidget {
  ViewLink({super.key});

  List list = [
    "https://www.youtube.com/watch?v=LmhJ9GRqM0Y&list=RDnWAB23dUw2o&index=5",
    "https://www.youtube.com/watch?v=7j5JHry4FCQ&list=RD7j5JHry4FCQ&start_radio=1",
    "https://developers.google.com/learn/pathways/intro-to-flutter?hl=en",
    "https://chat.openai.com/",
    "https://www.instagram.com/duykhanh_02.09/",
    "https://randomuser.me/",
    "https://www.topcv.vn/viec-lam",
    "https://flutterawesome.com/a-feature-packed-audio-recorder-app-built-using-flutter/",
    "https://www.linkedin.com/feed/",
    "https://shopee.vn/shopee-coins",
    "https://translate.google.com/?hl=vi",
    "https://kids.mindx.edu.vn/cc_baovne?utm_channel=outbound&utm_source=coccoc&utm_campaign=native&utm_medium=congdb&utm_content=CPA4&utm_term=*&md=_05be50vdanX7cmsEHDREOluJlDw4-8Ma32DakoSq5ryhHbx*zZG6Fjn19Tuqa6dogu1W*RgE68nqueOvnOQeITsFEwcAdZymBENMdE6hdFvAA93gRmOfUaHSfxoXeVcX2Nfo.",
  ];

  @override
  Widget build(BuildContext context) {
    final msgController = Get.find<MessageController>();
    List<String> listLink = msgController.listLink.value;
    return Theme(
      data: Theme.of(context).copyWith(
          scrollbarTheme: ScrollbarThemeData(
              thumbColor: MaterialStateProperty.all<Color>(Colors.blueAccent))),
      child: Scrollbar(
        // child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(5),
          child: ListView.separated(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            separatorBuilder: (context, index) => const SizedBox(
              height: 4,
            ),
            itemBuilder: (context, index) {
              return ALink(link: listLink[index]);
            },
            itemCount: listLink.length,
          ),
        ),
      ),
      //),
    );
  }
}

class ALink extends StatefulWidget {
  ALink({super.key, required this.link});
  String? link;

  @override
  State<ALink> createState() => _ALinkState();
}

class _ALinkState extends State<ALink> {
  String title = '';
  String imageURL = '';
  Future getLinkPreview() async {
    http.Response response = await http.get(Uri.parse(widget.link!));
    if (response.statusCode == 200) {
      dom.Document document = parser.parse(response.body);
      dom.Element? ogImage =
          document.querySelector('meta[property="og:image"]');
      dom.Element? ogTitle =
          document.querySelector('meta[property="og:title"]');
      String domain = await getDomain(widget.link!);
      if (mounted) {
        setState(() {
          imageURL = ogImage?.attributes['content'] ?? '';
          title = ogTitle?.attributes['content'] ?? '';
          if (title == '') {
            title = domain;
          }
        });
      }
    } else {
      print("Failed to access");
    }
  }

  Future<String> getDomain(String url) async {
    var uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      var domain = uri.host;
      return domain.startsWith('www.') ? domain.substring(4) : domain;
    }
    return '';
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    getLinkPreview();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.09,
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: Colors.black),
        ),
        onTap: () async {
          await launchUrl(Uri.parse(widget.link!));
        },
        leading: SizedBox(
          width: MediaQuery.of(context).size.width * 0.25,
          height: MediaQuery.of(context).size.height * 0.12,
          child: imageURL == ""
              ? Utils.showCacheImage(
                  url:
                      "https://www.pulsecarshalton.co.uk/wp-content/uploads/2016/08/jk-placeholder-image.jpg",
                  height: MediaQuery.of(context).size.height * 0.12,
                  width: MediaQuery.of(context).size.width * 0.25)
              : Validators.isSVG(imageURL)
                  ? Utils.showSVGImage(
                      url: imageURL,
                      height: MediaQuery.of(context).size.height * 0.12,
                      width: MediaQuery.of(context).size.width * 0.25)
                  : Utils.showCacheImage(
                      url: imageURL,
                      height: MediaQuery.of(context).size.height * 0.12,
                      width: MediaQuery.of(context).size.width * 0.25),
          // Image.network(
          //     widget.networkUrl,
          //     fit: BoxFit.fill,
          //     loadingBuilder: (BuildContext context, Widget child,
          //         ImageChunkEvent? loadingProgress) {
          //       if (loadingProgress == null) return child;
          //       return Center(
          //         child: CircularProgressIndicator(
          //           value: loadingProgress.expectedTotalBytes != null
          //               ? loadingProgress.cumulativeBytesLoaded /
          //                   loadingProgress.expectedTotalBytes!
          //               : null,
          //         ),
          //       );
          //     },
          //   ),
        ),
        title: Text(
          title,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
