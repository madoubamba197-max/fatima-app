import 'package:flutter/material.dart';

import '../config/business_config.dart';
import '../config/business_type.dart';
import '../repository/business_repository.dart';
import 'business_detail_page.dart';
import 'clients_page.dart';
import 'dashboard_page.dart';
import 'new_operation_page.dart';
import '../core/current_business.dart';
import '../shared/widgets/business_header.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../repository/banner_repository.dart';

Widget buildBannerCarousel() {

  final banners = BannerRepository.banners;

  if (banners.isEmpty) {

    return const SizedBox();

  }


  return Column(

    children: [

      CarouselSlider.builder(

        itemCount: banners.length,

        itemBuilder: (context, index, realIndex) {

          final banner = banners[index];


          return Container(

            margin: const EdgeInsets.symmetric(
              horizontal: 5,
            ),

            decoration: BoxDecoration(

              borderRadius: BorderRadius.circular(20),

              image: DecorationImage(

                image: AssetImage(
                  banner.image,
                ),

                fit: BoxFit.contain

              ),

            ),

            child: Container(

              alignment: Alignment.bottomLeft,

              padding: const EdgeInsets.all(15),

              decoration: BoxDecoration(

                borderRadius: BorderRadius.circular(20),

                gradient: LinearGradient(

                  begin: Alignment.topCenter,

                  end: Alignment.bottomCenter,

                  colors: [

                    Colors.transparent,

                    Colors.black54,

                  ],

                ),

              ),

              child: Text(

                banner.title,

                style: const TextStyle(

                  color: Colors.white,

                  fontSize: 22,

                  fontWeight: FontWeight.bold,

                ),

              ),

            ),

          );

        },


        options: CarouselOptions(

          height: 300,

          autoPlay: true,

          autoPlayInterval: const Duration(
            seconds: 4,
          ),

          enlargeCenterPage: true,

          viewportFraction: 0.90,

        ),

      ),


      const SizedBox(height: 15),

    ],

  );

}


class BusinessHomePage extends StatelessWidget {
  const BusinessHomePage({super.key});

  @override
  Widget build(BuildContext context) {

    final items = CurrentBusiness.app?.items ?? [];

    return Scaffold(

      appBar: AppBar(
        title: Text(CurrentBusiness.app?.name ?? BusinessConfig.name,),
      ),

      body: Column(

  children: [

   const BusinessHeader(),

const SizedBox(height: 15),

buildBannerCarousel(),

const SizedBox(height: 10),

    Text(
      "📞 ${CurrentBusiness.app?.phone ?? BusinessConfig.phone}",
      style: const TextStyle(
        fontSize: 16,
      ),
    ),

    const SizedBox(height: 5),

    Text(
      "📍 ${CurrentBusiness.app?.address ?? BusinessConfig.address}",
      style: const TextStyle(
        fontSize: 16,
      ),
    ),

    const SizedBox(height: 20),

    Expanded(

      child: GridView.builder(

              padding: const EdgeInsets.all(15),

              itemCount: items.length,

              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(

                crossAxisCount: 2,

                crossAxisSpacing: 15,

                mainAxisSpacing: 15,

                childAspectRatio: .80,

              ),

            itemBuilder: (_, index) {

  final item = items[index];


  return InkWell(

    onTap: () {

      Navigator.push(

        context,

        MaterialPageRoute(

          builder: (_) => BusinessDetailPage(

            item: item,

          ),

        ),

      );

    },


    child: Card(

      child: Column(

        children: [


          Expanded(

  child: ClipRRect(

    borderRadius: BorderRadius.circular(12),

    child: item.imageBytes != null

        ? Image.memory(

            item.imageBytes!,

            width: double.infinity,

            fit: BoxFit.cover,

          )

        : Container(

            color: Colors.grey.shade300,

            child: const Icon(

              Icons.image,

              size: 60,

            ),

          ),

  ),

),



          Padding(

            padding: const EdgeInsets.all(10),

            child: Column(

              children: [


                Text(

                  item.name,

                  style: const TextStyle(

                    fontWeight: FontWeight.bold,

                  ),

                ),



                Text(

                  item.category,

                  style: const TextStyle(

                    color: Colors.grey,

                  ),

                ),


              ],

            ),

          ),



          Text(

            "${item.price} ${BusinessConfig.currency}",

          ),



          const SizedBox(height: 10),


        ],

      ),

    ),

  );

},
            ),

          ),

        ],

      ),

 floatingActionButton: FloatingActionButton(

  backgroundColor: BusinessConfig.primaryColor,

  onPressed: () {


    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (context) =>
            const NewOperationPage(),

      ),

    );


  },

  child: const Icon(Icons.add),

),

    );
  }
}