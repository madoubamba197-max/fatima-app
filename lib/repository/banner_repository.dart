import '../models/banner_image.dart';

class BannerRepository {

  static final List<BannerImage> banners = [

    BannerImage(
      id: "1",
      image: "assets/images/banner1.jpg",
      title: "Tresses modernes",
    ),

    BannerImage(
      id: "2",
      image: "assets/images/banner2.jpg",
      title: "Perruques élégantes",
    ),

    BannerImage(
      id: "3",
      image: "assets/images/banner3.jpg",
      title: "Coiffures de cérémonie",
    ),

  ];

}