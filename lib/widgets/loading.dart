import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';

import '../system/constants.dart';


Widget toolCardLoadingWidget({required Size size}) {
  return Shimmer.fromColors(
    baseColor: AppColors.secondaryBackgroundColor.withAlpha(150),
    highlightColor: AppColors.bodyTextColor.withAlpha(50),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.secondaryBackgroundColor,
      ),
      padding: const EdgeInsets.all(4),
      margin: const EdgeInsets.only(top: 10, left: 7, right: 7),
      child: SizedBox(
        height: 70, // approximate height of a card
        child: Row(
          children: [
            // Circle avatar placeholder
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            // Title + subtitle placeholder
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, width: double.infinity, color: Colors.white),
                  const SizedBox(height: 6),
                  Container(height: 12, width: 120, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Trailing icons placeholder
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(height: 20, width: 20, color: Colors.white),
                const SizedBox(height: 10),
                Container(height: 20, width: 20, color: Colors.white),
              ],
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    ),
  );
}

Widget singleTrailCardLoadingWidget() {
  return Shimmer.fromColors(
    baseColor: AppColors.secondaryBackgroundColor.withAlpha(150),
    highlightColor: AppColors.bodyTextColor.withAlpha(50),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.secondaryBackgroundColor,
      ),
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: SizedBox(
        height: 50, // approximate height of your tile
        child: Row(
          children: [
            // Leading icon placeholder
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            // Title + subtitle placeholders
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, width: 120, color: Colors.white),
                  const SizedBox(height: 6),
                  Container(height: 12, width: 80, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Trailing icon placeholder
            Container(width: 14, height: 14, color: Colors.white),
          ],
        ),
      ),
    ),
  );
}

Widget trendingToolsLoadingWidget({required Size size}) {
  return Shimmer.fromColors(
    baseColor: AppColors.secondaryBackgroundColor.withAlpha(150),
    highlightColor: AppColors.bodyTextColor.withAlpha(50),
    child: Container(
      width: size.width * 0.9,
      padding: const EdgeInsets.all(4),
      margin: const EdgeInsets.only(top: 10, left: 7, right: 7),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        height: size.height * 0.09, // approximate height
        child: Row(
          children: [
            // Title/subtitle placeholder
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, width: double.infinity, color: Colors.white),
                  const SizedBox(height: 6),
                  Container(height: 12, width: size.width * 0.5, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Trailing button placeholder
            Container(
              width: size.width * 0.33,
              height: size.height * 0.06,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget latestCardLoadingWidget({required Size size}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
    child: Shimmer.fromColors(
      baseColor: AppColors.secondaryBackgroundColor.withAlpha(150),
      highlightColor: AppColors.bodyTextColor.withAlpha(50),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 6,
        clipBehavior: Clip.hardEdge,
        color: AppColors.secondaryBackgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fake image placeholder
            Container(
              height: size.height * 0.25,
              width: double.infinity,
              color: Colors.white,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // release date placeholder
                  Container(
                    height: 10,
                    width: size.width * 0.4,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),

                  // title placeholder
                  Container(
                    height: 16,
                    width: size.width * 0.6,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),

                  // description placeholder (3 lines)
                  Container(height: 10, width: size.width * 0.9, color: Colors.white),
                  const SizedBox(height: 4),
                  Container(height: 10, width: size.width * 0.8, color: Colors.white),
                  const SizedBox(height: 4),
                  Container(height: 10, width: size.width * 0.7, color: Colors.white),

                  const SizedBox(height: 10),

                  // tags placeholder
                  Row(
                    children: List.generate(
                      3,
                          (_) => Container(
                        height: 20,
                        width: 60,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // buttons placeholder (2 buttons)
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: size.height * 0.06,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: size.height * 0.06,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget newsCardLoadingWidget({required Size size}) {
  return Card(
    margin: EdgeInsets.symmetric(horizontal: size.width * 0.05),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    elevation: 6,
    clipBehavior: Clip.hardEdge,
    color: AppColors.secondaryBackgroundColor,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image skeleton
        Container(
          height: size.height * 0.25,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.bodyTextColor.withAlpha(25),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Release date shimmer
              Container(
                width: size.width * 0.4,
                height: 10,
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.bodyTextColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),

              // Owner shimmer
              Container(
                width: size.width * 0.3,
                height: 10,
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccentColor.withAlpha(40),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),

              // Title shimmer
              Container(
                width: size.width * 0.7,
                height: 14,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.bodyTextColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              // Description shimmer (3 lines)
              Column(
                children: List.generate(
                  3,
                      (i) => Container(
                    width: double.infinity,
                    height: 10,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.bodyTextColor.withAlpha(20 + (i * 10)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Read More button placeholder
              Center(
                child: Container(
                  width: size.width * 0.4,
                  height: size.height * 0.05,
                  decoration: BoxDecoration(
                    color: AppColors.bodyTextColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget promotionCardLoadingWidget({required Size size}) {
  return Shimmer.fromColors(
    baseColor: AppColors.bodyTextColor.withAlpha(40),
    highlightColor: AppColors.bodyTextColor.withAlpha(10),
    child: Container(
      height: size.height * 0.25,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.secondaryBackgroundColor.withAlpha(80),
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}

Widget freelancerCardLoading({required Size size}) {
  return Shimmer.fromColors(
    baseColor: AppColors.bodyTextColor.withAlpha(40),
    highlightColor: AppColors.bodyTextColor.withAlpha(10),
    child: Container(
      width: size.width * 0.9,
      padding: const EdgeInsets.all(4),
      margin: const EdgeInsets.only(top: 10, left: 7, right: 7),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(0),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.bodyTextColor.withAlpha(30),
        ),
        title: Container(
          width: size.width * 0.4,
          height: 12,
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            color: AppColors.bodyTextColor.withAlpha(30),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        subtitle: Container(
          width: size.width * 0.3,
          height: 10,
          decoration: BoxDecoration(
            color: AppColors.bodyTextColor.withAlpha(30),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        trailing: SizedBox(
          width: 50,
          height: 50,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 35,
                height: 8,
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: AppColors.bodyTextColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                width: 25,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.bodyTextColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget journalPromptLoadingWidget() {
  return Shimmer.fromColors(
    baseColor: AppColors.bodyTextColor.withAlpha(40),
    highlightColor: AppColors.bodyTextColor.withAlpha(10),
    child: Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Owner shimmer
          Container(
            width: 80,
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.bodyTextColor.withAlpha(30),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 8),

          // Description shimmer
          Container(
            width: 160,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.bodyTextColor.withAlpha(30),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 10),

          // Prompt content shimmer
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: AppColors.secondaryBackgroundColor,
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 8,
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.bodyTextColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 8,
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.bodyTextColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 8,
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.bodyTextColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Icons row shimmer
          Row(
            children: List.generate(3, (index) => Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.bodyTextColor.withAlpha(30),
                  shape: BoxShape.circle,
                ),
              ),
            ))
              ..add(Container(
                width: 25,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.bodyTextColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
          ),

          const SizedBox(height: 8),

          Divider(color: AppColors.bodyTextColor.withAlpha(53), thickness: 1),
        ],
      ),
    ),
  );
}