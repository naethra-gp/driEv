import 'package:flutter/material.dart';

class DraggableBottomSheet extends StatelessWidget {
  const DraggableBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final _sheet = GlobalKey();
    final _controller = DraggableScrollableController();
    return DraggableScrollableSheet(
      key: _sheet,
      initialChildSize: 0.5,
      maxChildSize: 1,
      minChildSize: 0,
      expand: true,
      snap: true,
      snapSizes: const [0.5],
      controller: _controller,
      builder: (BuildContext context, ScrollController scrollController) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              const SliverToBoxAdapter(
                child: Text('Title'),
              ),
              SliverList.list(
                children: const [
                  Text('Content'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}