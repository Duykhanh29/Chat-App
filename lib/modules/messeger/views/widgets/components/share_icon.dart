import 'package:flutter/material.dart';

class SharedIcon extends StatelessWidget {
  SharedIcon({super.key, required this.size});
  double size;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: size,
      child: Center(
        child: InkWell(
          splashColor: Colors.red,
          highlightColor: Colors.cyan,
          onTap: () {},
          child: Container(
            width: 30,
            height: 30,
            decoration:
                const BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
            child: const Center(
              child: Icon(
                Icons.share_rounded,
                color: Colors.blue,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
