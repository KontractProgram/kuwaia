import 'package:flutter/material.dart';
import 'package:kuwaia/models/community/freelancer.dart';
import 'package:kuwaia/providers/ai_journal_provider.dart';
import 'package:kuwaia/widgets/custom.dart';
import 'package:kuwaia/widgets/loading.dart';
import 'package:kuwaia/widgets/texts.dart';
import 'package:provider/provider.dart';
import '../../../system/constants.dart';

class FreelancersScreen extends StatefulWidget {
  const FreelancersScreen({super.key});

  @override
  State<FreelancersScreen> createState() => _FreelancersScreenState();
}


class _FreelancersScreenState extends State<FreelancersScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AiJournalProvider>(context, listen: false).fetchFreelancers();
    });
  }

  void _showFreelancerGalleryModal({required BuildContext context, required Size size, required Freelancer freelancer}) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return FreelancerGalleryModalContent(
          freelancer: freelancer,
          size: size,
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Consumer<AiJournalProvider>(
      builder: (context, aiJournalProvider, _) {
        if (aiJournalProvider.isLoading) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) {
              if (index == 0) {
                return promotionCardLoadingWidget(size: size);
              }

              return freelancerCardLoading(size: size);
            }
          );
        }

        if (aiJournalProvider.error != null) {
          return Center(
            child: Text(aiJournalProvider.error!,
                style: TextStyle(color: AppColors.warningColor)),
          );
        }

        final freelancers = aiJournalProvider.freelancers ?? [];
        final promotions = aiJournalProvider.promotions ?? [];
        int count = freelancers.length;
        if(promotions.isNotEmpty) {
          count += 1;
        }

        if(freelancers.isEmpty) {
          return Center(
            child: Column(
              children: [
                Image.asset('assets/kuwaia_icons/main/freelancericon.png', width: size.width*0.6,),
                reusableText(text: 'No freelancers available yet', fontSize: 20, fontWeight: FontWeight.bold)
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: count,
          itemBuilder: (context, index) {
            if(count > freelancers.length) {
              if (index == 0) {
                // First item: promotion carousel
                return PromotionCarousel(
                  promotions: freelancers.take(3).toList(), // example: first 5 as promotions
                  size: size,
                  onTap: (freelancer) => _showFreelancerGalleryModal(
                    context: context,
                    size: size,
                    freelancer: freelancer,
                  ),
                );
              }

              final freelancer = freelancers[index - 1];

              return freelancerCard(
                  context: context,
                  size: size,
                  freelancer: freelancer,
                  onPressed: () => _showFreelancerGalleryModal(context: context, size: size, freelancer: freelancer)
              );
            }
            else {
              return freelancerCard(
                  context: context,
                  size: size,
                  freelancer: freelancers[index],
                  onPressed: () => _showFreelancerGalleryModal(context: context, size: size, freelancer: freelancers[index])
              );
            }
          },
        );
      },
    );
  }
}


class FreelancerGalleryModalContent extends StatefulWidget {
  final Freelancer freelancer;
  final Size size;

  const FreelancerGalleryModalContent({
    super.key,
    required this.freelancer,
    required this.size,
  });

  @override
  State<FreelancerGalleryModalContent> createState() => _FreelancerGalleryModalContentState();
}

class _FreelancerGalleryModalContentState extends State<FreelancerGalleryModalContent> {
  late final PageController _pageController;
  static const double _viewportFraction = 0.85;
  static const double _scaleFactor = 0.9;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: _viewportFraction);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AiJournalProvider>(context, listen: false).fetchGalleryByFreelancerId(widget.freelancer.id);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.size.height * 0.9, // 90% of screen height
      decoration: BoxDecoration(
        color: AppColors.primaryBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Consumer<AiJournalProvider>(
        builder: (context, aiJournalProvider, _) {
          if (aiJournalProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (aiJournalProvider.error != null) {
            return Center(
              child: Text(
                aiJournalProvider.error!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final images = aiJournalProvider.freelancerUrls ?? [];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                images.isEmpty ? SizedBox.shrink() : WeightedImageCarousel(images: images, height: 250,),

                const SizedBox(height: 24,),

                reusableText(text: 'About Me', fontSize: 20, fontWeight: FontWeight.bold),

                SizedBox(height: 16,),

                reusableText(text: widget.freelancer.aboutMe, fontSize: 14, maxLines: 30),
              ],
            ),
          );
        }
      ),
    );
  }
}