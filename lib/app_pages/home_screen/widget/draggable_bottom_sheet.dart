import 'package:flutter/material.dart';

class DraggableBottomSheet extends StatelessWidget {
  const DraggableBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final sheet = GlobalKey();
    final controller = DraggableScrollableController();
    return DraggableScrollableSheet(
      key: sheet,
      initialChildSize: 0.5,
      maxChildSize: 1,
      minChildSize: 0,
      expand: true,
      snap: true,
      snapSizes: const [0.5],
      controller: controller,
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
