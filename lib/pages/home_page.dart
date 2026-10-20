import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/site_theme.dart';
import '../widgets/reviews_section.dart';
import '../widgets/sections.dart';
import '../widgets/site_scaffold.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final c = s.content;
    final rooms = s.publishedRooms;
    final brands = s.activeBrands;
    return SiteScaffold(
      location: '/',
      overHero: true,
      children: [
        HeroCarousel(
          photos: s.heroPhotos,
          kicker: c.heroKicker,
          title: c.heroTitle,
          subtitle: c.heroSubtitle,
        ),
        IntroSection(content: c),
        if (rooms.isNotEmpty) RoomsSequence(content: c, rooms: rooms),
        if (s.gallery.isNotEmpty)
          ImageCarousel(
            kicker: c.showcaseKicker,
            title: c.showcaseTitle,
            number: '03',
            photos: s.gallery,
          ),
        if (brands.isNotEmpty) BrandsBand(content: c, brands: brands),
        if (c.process.isNotEmpty)
          ProcessSection(
            title: c.processTitle,
            steps: c.process,
            number: '05',
            color: context.st.bg,
          ),
        ReviewsSection(
          kicker: c.reviewsKicker,
          title: c.reviewsTitle,
          number: '06',
          reviews: s.publishedReviews,
        ),
        CtaBanner(
          title: c.bannerTitle,
          text: c.bannerText,
          button: c.bannerButton,
          image: c.bannerImage.trim().isNotEmpty
              ? c.bannerImage
              : (s.heroPhotos.isEmpty ? '' : s.heroPhotos.first.url),
        ),
      ],
    );
  }
}
