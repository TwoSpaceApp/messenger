import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:two_space_app/core/config/app_colors.dart';
import 'package:two_space_app/core/utils/responsive.dart';

class SkeletonShimmer extends StatelessWidget {
  const SkeletonShimmer({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.skeletonBase(context),
      highlightColor: AppColors.skeletonHighlight(context),
      child: child,
    );
  }
}

class PeopleListSkeleton extends StatelessWidget {
  const PeopleListSkeleton({
    super.key,
    this.itemCount = 4,
    this.padding,
  });

  final int itemCount;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final outerPadding = padding ?? EdgeInsets.only(bottom: 110.s(context));
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: outerPadding,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16.s(context),
            index == 0 ? 8.s(context) : 0,
            16.s(context),
            10.s(context),
          ),
          child: const _PersonTileSkeleton(),
        );
      },
    );
  }
}

class PeopleInlineSkeleton extends StatelessWidget {
  const PeopleInlineSkeleton({
    super.key,
    this.itemCount = 3,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => Padding(
          padding: EdgeInsets.fromLTRB(
            16.s(context),
            index == 0 ? 8.s(context) : 0,
            16.s(context),
            10.s(context),
          ),
          child: const _PersonTileSkeleton(),
        ),
      ),
    );
  }
}

class CallsListSkeleton extends StatelessWidget {
  const CallsListSkeleton({
    super.key,
    this.itemCount = 4,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        16.s(context),
        8.s(context),
        16.s(context),
        110.s(context),
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 10.s(context)),
          child: const _CallTileSkeleton(),
        );
      },
    );
  }
}

class _PersonTileSkeleton extends StatelessWidget {
  const _PersonTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Container(
        height: 88.s(context),
        padding: EdgeInsets.symmetric(
          horizontal: 14.s(context),
          vertical: 12.s(context),
        ),
        decoration: BoxDecoration(
          color: AppColors.skeletonBase(context),
          borderRadius: BorderRadius.circular(22.s(context)),
        ),
        child: Row(
          children: [
            Container(
              width: 48.s(context),
              height: 48.s(context),
              decoration: BoxDecoration(
                color: AppColors.skeletonHighlight(context),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12.s(context)),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonLine(width: 128.s(context), height: 14.s(context)),
                  SizedBox(height: 8.s(context)),
                  _SkeletonLine(width: 172.s(context), height: 11.s(context)),
                ],
              ),
            ),
            SizedBox(width: 12.s(context)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (_) => Padding(
                  padding: EdgeInsets.only(left: 6.s(context)),
                  child: Container(
                    width: 16.s(context),
                    height: 16.s(context),
                    decoration: BoxDecoration(
                      color: AppColors.skeletonHighlight(context),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallTileSkeleton extends StatelessWidget {
  const _CallTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Container(
        height: 92.s(context),
        padding: EdgeInsets.symmetric(
          horizontal: 14.s(context),
          vertical: 12.s(context),
        ),
        decoration: BoxDecoration(
          color: AppColors.skeletonBase(context),
          borderRadius: BorderRadius.circular(22.s(context)),
        ),
        child: Row(
          children: [
            Container(
              width: 48.s(context),
              height: 48.s(context),
              decoration: BoxDecoration(
                color: AppColors.skeletonHighlight(context),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12.s(context)),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonLine(width: 120.s(context), height: 14.s(context)),
                  SizedBox(height: 8.s(context)),
                  _SkeletonLine(width: 156.s(context), height: 11.s(context)),
                ],
              ),
            ),
            SizedBox(width: 16.s(context)),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _SkeletonLine(width: 38.s(context), height: 10.s(context)),
                SizedBox(height: 10.s(context)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    2,
                    (_) => Padding(
                      padding: EdgeInsets.only(left: 8.s(context)),
                      child: Container(
                        width: 16.s(context),
                        height: 16.s(context),
                        decoration: BoxDecoration(
                          color: AppColors.skeletonHighlight(context),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.skeletonHighlight(context),
        borderRadius: BorderRadius.circular(height),
      ),
    );
  }
}
