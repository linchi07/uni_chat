/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-01 11:39
*/

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../src/internals/physics.dart';
import '../src/internals/slivers.dart';

// ignore_for_file: INVALID_USE_OF_PROTECTED_MEMBER
// ignore_for_file: INVALID_USE_OF_VISIBLE_FOR_TESTING_MEMBER
// ignore_for_file: DEPRECATED_MEMBER_USE

/// when viewport not full one page, for different state,whether it should follow the content
typedef void OnTwoLevel(bool isOpen);

/// when viewport not full one page, for different state,whether it should follow the content
typedef bool ShouldFollowContent(LoadStatus? status);

/// global default indicator builder
typedef IndicatorBuilder = Widget Function();

/// header state
enum RefreshStatus {
  /// Initial state, when not being overscrolled into, or after the overscroll
  /// is canceled or after done and the sliver retracted away.
  idle,

  /// Dragged far enough that the onRefresh callback will callback
  canRefresh,

  /// the indicator is refreshing,waiting for the finish callback
  refreshing,

  /// the indicator refresh completed
  completed,

  /// the indicator refresh failed
  failed,

  ///  Dragged far enough that the onTwoLevel callback will callback
  canTwoLevel,

  ///  indicator is opening twoLevel
  twoLevelOpening,

  /// indicator is in twoLevel
  twoLeveling,

  ///  indicator is closing twoLevel
  twoLevelClosing,
}

///  footer state
enum LoadStatus {
  /// Initial state, which can be triggered loading more by gesture pull up
  idle,

  canLoading,

  /// indicator is loading more data
  loading,

  /// indicator is no more data to loading,this state doesn't allow to load more whatever
  noMore,

  /// indicator load failed,Initial state, which can be click retry,If you need to pull up trigger load more,you should set enableLoadingWhenFailed = true in RefreshConfiguration
  failed,
}

/// header indicator display style
enum RefreshStyle {
  // indicator box always follow content
  Follow,
  // indicator box follow content,When the box reaches the top and is fully visible, it does not follow content.
  UnFollow,

  /// Let the indicator size zoom in with the boundary distance,look like showing behind the content
  Behind,

  /// this style just like flutter RefreshIndicator,showing above the content
  Front,
}

/// footer indicator display style
enum LoadStyle {
  /// indicator always own layoutExtent whatever the state
  ShowAlways,

  /// indicator always own 0.0 layoutExtent whatever the state
  HideAlways,

  /// indicator always own layoutExtent when loading state, the other state is 0.0 layoutExtent
  ShowWhenLoading,
}

/// A nested page scroll widget to achieve the same effect of AppleWatch
///
/// Inspired and modified from [flutter pull_to_refresh](https://github.com/peng8350/flutter_pulltorefresh)
///
/// #### Current bugs:
/// - jitter on mouse scroll
/// - scroll position will be reset when page changed
///
/// *这也是为啥会有一些奇怪的参数，因为是从那个包直接魔改来的，所以有些过于耦合的东西就成屎山了*
class PagedScroll extends StatefulWidget {
  /// Refresh Content
  ///
  /// notice that: If child is  extends ScrollView,It will help you get the internal slivers and add footer and header in it.
  /// else it will put child into SliverToBoxAdapter and add footer and header
  final List<Widget>? children;

  /// copy from ScrollView,for setting in SingleChildView,not ScrollView
  final Axis? scrollDirection;

  /// copy from ScrollView,for setting in SingleChildView,not ScrollView
  final bool? reverse;

  /// copy from ScrollView,for setting in SingleChildView,not ScrollView
  final ScrollController? scrollController;

  /// copy from ScrollView,for setting in SingleChildView,not ScrollView
  final bool? primary;

  /// copy from ScrollView,for setting in SingleChildView,not ScrollView
  final ScrollPhysics? physics;

  /// copy from ScrollView,for setting in SingleChildView,not ScrollView
  final double? cacheExtent;

  /// copy from ScrollView,for setting in SingleChildView,not ScrollView
  final int? semanticChildCount;

  /// copy from ScrollView,for setting in SingleChildView,not ScrollView
  final DragStartBehavior? dragStartBehavior;

  late final PageController pageController;

  /// creates a widget help attach the refresh and load more function
  /// controller must not be null,
  /// child is your refresh content,Note that there's a big difference between children inheriting from ScrollView or not.
  /// If child is extends ScrollView,inner will get the slivers from ScrollView,if not,inner will wrap child into SliverToBoxAdapter.
  /// If your child inner container Scrollable,please consider about converting to Sliver,and use CustomScrollView,or use [builder] constructor
  /// such as AnimatedList,RecordableList,doesn't allow to put into child,it will wrap it into SliverToBoxAdapter
  /// If you don't need pull down refresh ,just enablePullDown = false,
  /// If you  need pull up load ,just enablePullUp = true
  PagedScroll({
    Key? key,
    PageController? controller,
    this.children,
    this.dragStartBehavior,
    this.primary,
    this.cacheExtent,
    this.semanticChildCount,
    this.reverse,
    this.physics,
    this.scrollDirection,
    this.scrollController,
  }) : super(key: key) {
    pageController = controller ?? PageController();
  }
  static PagedScroll? of(BuildContext? context) {
    return context!.findAncestorWidgetOfExactType<PagedScroll>();
  }

  static PagedScrollState? ofState(BuildContext? context) {
    return context!.findAncestorStateOfType<PagedScrollState>();
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PagedScrollState();
  }
}

class PagedScrollState extends State<PagedScroll> {
  bool _updatePhysics = false;
  double viewportExtent = 0;
  PageController get pageController => widget.pageController;
  bool _canDrag = true;
  bool alineFlag = false;
  ScrollPhysics _getScrollPhysics(ScrollPhysics physics) {
    return OverScrollTransferPhysics(
      onOverScroll: (v) async {
        if (pageController.hasClients) {
          pageController.jumpTo(pageController.offset - v);
          var p = pageController.page;
          if (p != null && !alineFlag) {
            var delta = p - p.round();
            print(delta);
            if (delta.abs() > 0.1) {
              alineFlag = true;
              await pageController.animateToPage(
                (delta < 0) ? p.floor() : p.ceil(),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInSine,
              );
              alineFlag = false;
              return;
            }
          }
        }
      },
      onOverScrollEnd: () async {
        var p = pageController.page;
        if (p != null && !alineFlag) {
          var delta = p - p.round();
          print(delta);
          if (delta.abs() > 0.1) {
            alineFlag = true;
            await pageController.animateToPage(
              (delta < 0) ? p.floor() : p.ceil(),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInSine,
            );
            alineFlag = false;
            return;
          }
        }
      },
    );
  }

  //build slivers from child Widget
  List<Widget>? _buildSliversByChild(BuildContext context, Widget? child) {
    List<Widget>? slivers;
    if (child is ScrollView) {
      if (child is BoxScrollView) {
        //avoid system inject padding when own indicator top or bottom
        Widget sliver = child.buildChildLayout(context);
        if (child.padding != null) {
          slivers = [SliverPadding(sliver: sliver, padding: child.padding!)];
        } else {
          slivers = [sliver];
        }
      } else {
        slivers = List.from(child.buildSlivers(context), growable: true);
      }
    } else if (child is! Scrollable) {
      slivers = [SliverRefreshBody(child: child ?? Container())];
    }
    return slivers;
  }

  // build the customScrollView
  Widget? _buildBodyBySlivers(Widget? childView, List<Widget>? slivers) {
    Widget? body;
    if (childView is! Scrollable) {
      bool? primary = widget.primary;
      Key? key;
      double? cacheExtent = widget.cacheExtent;

      Axis? scrollDirection = widget.scrollDirection;
      int? semanticChildCount = widget.semanticChildCount;
      bool? reverse = widget.reverse;
      ScrollController? scrollController = widget.scrollController;
      DragStartBehavior? dragStartBehavior = widget.dragStartBehavior;
      ScrollPhysics? physics = widget.physics;
      Key? center;
      double? anchor;
      ScrollViewKeyboardDismissBehavior? keyboardDismissBehavior;
      String? restorationId;
      Clip? clipBehavior;

      if (childView is ScrollView) {
        primary = primary ?? childView.primary;
        cacheExtent = cacheExtent ?? childView.cacheExtent;
        key = key ?? childView.key;
        semanticChildCount = semanticChildCount ?? childView.semanticChildCount;
        reverse = reverse ?? childView.reverse;
        dragStartBehavior = dragStartBehavior ?? childView.dragStartBehavior;
        scrollDirection = scrollDirection ?? childView.scrollDirection;
        physics = physics ?? childView.physics;
        center = center ?? childView.center;
        anchor = anchor ?? childView.anchor;
        keyboardDismissBehavior =
            keyboardDismissBehavior ?? childView.keyboardDismissBehavior;
        restorationId = restorationId ?? childView.restorationId;
        clipBehavior = clipBehavior ?? childView.clipBehavior;
        scrollController = scrollController ?? childView.controller;
      }
      body = CustomScrollView(
        // ignore: DEPRECATED_MEMBER_USE_FROM_SAME_PACKAGE
        controller: scrollController,
        cacheExtent: cacheExtent,
        key: key,
        scrollDirection: scrollDirection ?? Axis.vertical,
        semanticChildCount: semanticChildCount,
        primary: primary,
        clipBehavior: clipBehavior ?? Clip.hardEdge,
        keyboardDismissBehavior:
            keyboardDismissBehavior ?? ScrollViewKeyboardDismissBehavior.manual,
        anchor: anchor ?? 0.0,
        restorationId: restorationId,
        center: center,
        physics: _getScrollPhysics(physics ?? AlwaysScrollableScrollPhysics()),
        slivers: slivers!,
        dragStartBehavior: dragStartBehavior ?? DragStartBehavior.start,
        reverse: reverse ?? false,
      );
    } else
      body = Scrollable(
        physics: _getScrollPhysics(
          childView.physics ?? AlwaysScrollableScrollPhysics(),
        ),
        controller: childView.controller,
        axisDirection: childView.axisDirection,
        semanticChildCount: childView.semanticChildCount,
        dragStartBehavior: childView.dragStartBehavior,
        viewportBuilder: (context, offset) {
          Viewport viewport =
              childView.viewportBuilder(context, offset) as Viewport;
          return viewport;
        },
      );

    return body;
  }

  void setCanDrag(bool canDrag) {
    if (_canDrag == canDrag) {
      return;
    }
    setState(() {
      _canDrag = canDrag;
    });
  }

  @override
  void didUpdateWidget(PagedScroll oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (c2, cons) {
        viewportExtent = cons.biggest.height;
        return PageView(
          controller: pageController,
          scrollDirection: widget.scrollDirection ?? Axis.vertical,
          children: (widget.children ?? []).map((e) {
            Widget? body;
            List<Widget>? slivers = _buildSliversByChild(context, e);
            body = _buildBodyBySlivers(e, slivers);
            return body!;
          }).toList(),
        );
      },
    );
  }
}
