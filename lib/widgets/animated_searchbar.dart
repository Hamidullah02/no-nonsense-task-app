import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimatedSearch extends StatefulWidget {
  const AnimatedSearch({
    Key? key,
    this.width = 0.7,
    this.textEditingController,
    this.startIcon = Icons.search,
    this.closeIcon = Icons.close,
    this.iconColor = Colors.white,
    this.cursorColor = Colors.white,
    this.onChanged,
    this.decoration,
  }) : super(key: key);

  final double width;

  final TextEditingController? textEditingController;

  final IconData? startIcon;

  final IconData? closeIcon;

  final Color? iconColor;

  final Color? cursorColor;

  final Function(String)? onChanged;

  final InputDecoration? decoration;

  @override
  State<AnimatedSearch> createState() => _AnimatedSearchState();
}

class _AnimatedSearchState extends State<AnimatedSearch> {
  bool isFolded = true;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var width = size.width;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 35,
      width: isFolded ? width / 10 : width * widget.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(42.0),
        color: Color.fromARGB(32, 81, 129, 147),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 10),
              child:
                  !isFolded
                      ? TextField(
                        controller: widget.textEditingController,
                        autofocus: true,
                        cursorColor: widget.cursorColor,
                        decoration:
                            widget.decoration ??
                            InputDecoration(
                              hintText: 'Search',
                              hintStyle: TextStyle(
                                color: Color.fromARGB(255, 255, 254, 254),
                              ),
                              border: InputBorder.none,
                            ),
                        onChanged: widget.onChanged,
                      )
                      : null,
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            child: InkWell(
              onTap: () {
                setState(() {
                  isFolded = !isFolded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child:
                    widget.textEditingController!.text.isEmpty
                        ? Icon(
                          isFolded ? widget.startIcon : widget.closeIcon,
                          color: widget.iconColor,
                          size: 20,
                        )
                        : const SizedBox(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
