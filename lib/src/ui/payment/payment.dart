import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lomi/src/Data/Models/enums.dart';

import '../../Blocs/PaymentBloc/payment_bloc.dart';
import '../../Blocs/ThemeCubit/theme_cubit.dart';
import 'subscriptionTypes.dart';

class Payment extends StatefulWidget {
  const Payment({super.key, required this.paymentUi, this.ctx});

  final PaymentUi paymentUi;
  final BuildContext? ctx;

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  int selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    bool isDark = context.read<ThemeCubit>().state == ThemeMode.dark;

    List<String> subIds = ['premium','monthly', 'yearly', '6months'];
    List<String> boostsIds = ['1boost', '5boosts', '10boosts'];
    List<String> likesIds = ['3superlikes','15superlikes', '30superlikes'];

    List<Map<String, String>> subs = [
      {'name': '6', 'description': 'Months', 'price': '\$49.99'},
      {'name': '1', 'description': 'Month', 'price': '\$9.99'},
      {'name': '12', 'description': 'Months', 'price': '\$99.99'},
    ];

    List<Map<String, String>> boosts = [
      {'name': '1', 'description': 'Boosts', 'price': '\$4.99/ea'},
      {'name': '5', 'description': 'Boosts', 'price': '\$3.99/ea'},
      {'name': '10', 'description': 'Boosts', 'price': '\$2.99/ea'},
    ];

    List<Map<String, String>> superLikes = [
      {'name': '3', 'description': 'Super Likes', 'price': '\$2.99/ea'},
      {'name': '15', 'description': 'Super Likes', 'price': '\$1.99/ea'},
      {'name': '30', 'description': 'Super Likes', 'price': '\$1/ea'},
    ];

    switch (widget.paymentUi) {
      case PaymentUi.subscription:
        subs = subs;
        break;
      case PaymentUi.boosts:
        subs = boosts;
        break;
      case PaymentUi.superlikes:
        subs = superLikes;
        break;
    }

    Color bgColor = widget.paymentUi == PaymentUi.subscription
        ? Colors.amber
        : widget.paymentUi == PaymentUi.boosts
            ? Colors.purple
            : Colors.blue;

    return 
            BlocBuilder<PaymentBloc, PaymentState>(
              builder: (context, state) {
                List<ProductDetails> productDetails = [];
                if(widget.paymentUi == PaymentUi.subscription){
            
                  for(var product in state.productDetails){
                    if(subIds.contains(product.id)) productDetails.add(product);
                  }
                }
                
                if(widget.paymentUi == PaymentUi.boosts){
                  for(var product in state.productDetails){
                    if(boostsIds.contains(product.id)) productDetails.add(product);
                  }
                }

                if(widget.paymentUi == PaymentUi.superlikes){
                  for(var product in state.productDetails){
                    if(likesIds.contains(product.id)) productDetails.add(product);
                  }
                }
                return Container(
      color: Colors.transparent,
      child: Container(
        width: width * 0.9,
        height: 
        450.h,
        //height * 0.65,
        // color: Colors.transparent,
        child: Column(
          children: [ Container(
                  //height: height * 0.22,
                  // width: 600,
                  padding: EdgeInsets.zero,
                  decoration: BoxDecoration(
                      color: widget.paymentUi == PaymentUi.subscription
                          ? !isDark
                              ? Colors.amber
                              : Colors.amber[700]
                          : bgColor,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(15),
                      )),
                  child: widget.paymentUi == PaymentUi.subscription
                      ? Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Get HabeshaWe Premium',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge),
                            ),
                            Container(
                              height: 155.h,
                              child: PageView(
                                physics: BouncingScrollPhysics(),
                                children: [
                                  pageViewItem(
                                      context: context,
                                      image: 'assets/icons/likeIconPayment.png',
                                      title: 'View Profile',
                                      description:
                                          'see profile of users who liked you and decide to like or ignore'),
                                  pageViewItem(
                                      context: context,
                                      image: 'assets/icons/googleTransp.png',
                                      title: 'Chat With Match',
                                      description:
                                          'get to know with your match today liked you and decide to like or ignore'),
                                  pageViewItem(
                                      context: context,
                                      image: 'assets/icons/likeIconPayment.png',
                                      title: 'Become Kings',
                                      description:
                                          'Increase you match by becoming king you will get as match as many matchs, your profile will be showed to normal users ')
                                ],
                              ),
                            ),
                          ],
                        )
                      : Container(
                          height: 200.h,
                          width: double.infinity,
                          child: Column(
                            //crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 30.h,
                              ),
                              Icon(
                                widget.paymentUi == PaymentUi.superlikes
                                    ? Icons.star_border_purple500
                                    : Icons.electric_bolt_sharp,
                                size: 55.h,
                                color: Colors.white,
                              ),
                              SizedBox(
                                height: 30.h,
                              ),
                              Text(
                                widget.paymentUi == PaymentUi.superlikes
                                    ? 'Stand out with Super Like'
                                    : 'Be Seen',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.sp
                                ),
                              ),
                              SizedBox(
                                height: 7.h,
                              ),
                              Text(
                                widget.paymentUi == PaymentUi.superlikes
                                    ? 'You are 3X more likely to get a\n match!'
                                    : "Be a top profile in your area for 30 minutes\n to get more matches!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300,
                                    fontSize: 10.sp),
                              )
                            ],
                          ),
                        ),
                ),
              
            //SizedBox(height: 25,),
            state.productDetails.isNotEmpty?
            SizedBox(
              //height: 100,
              child: Row(
                //crossAxisCount: 3,
                mainAxisSize: MainAxisSize.max,
                // mainAxisAlignment: MainAxisAlignment.spaceAround,

                children: List.generate(
                    productDetails.length,
                    (index) => SubscriptionType(
                        context: context,
                        name: productDetails[index].title,
                        //subs[index]['name']!,
                        description: productDetails[index].description,
                        //subs[index]['description']!,
                        price: productDetails[index].price,
                        //subs[index]['price']!,
                        isSelected: selectedIndex == index,
                        bgColor: bgColor,
                        rawPrice: productDetails[index].rawPrice,
                        paymentUi: widget.paymentUi,
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        })),
              ),
            )
            :Container(
              margin: EdgeInsets.only(top: 55.h),
              child: Center(
                child: Padding(
                  padding:  EdgeInsets.all(23.0.h),
                  child: Text('please check your play/App store, \nNO products available... ',textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 10.sp),),
                ),
              ),
            ),

            

            // SizedBox(height: 45,),
            Spacer(
              flex: 2,
            ),
            state.productDetails.isNotEmpty?
            SizedBox(
              width: width * 0.5,
              child: ElevatedButton(
                onPressed: () {
                  if(widget.paymentUi == PaymentUi.subscription)  context.read<PaymentBloc>().add(Subscribe(product: productDetails[selectedIndex]));

                  if(widget.paymentUi == PaymentUi.boosts) context.read<PaymentBloc>().add(BuyBoosts(product: productDetails[selectedIndex]));

                  if(widget.paymentUi == PaymentUi.superlikes) context.read<PaymentBloc>().add(BuySuperLikes(product: productDetails[selectedIndex]));


                },
                child:  Text('CONTINUE'),
                style: ElevatedButton.styleFrom(
                  shape:const StadiumBorder(),
                  backgroundColor: bgColor,
                  //!isDark?bgColor: Colors.amber[700]
                ),
              ),
            ):SizedBox(),

            Spacer()
          ],
        ),
      )
      );
      },
            );
    
  }

  Column pageViewItem(
      {required BuildContext context,
      required String image,
      required String title,
      required String description}) {
    return Column(
      //mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        //         SizedBox(height: 20,),
        //         Text(
        //   'Get HabeshaWe Premium',
        //   textAlign: TextAlign.center,
        //   style: Theme.of(context).textTheme.bodyLarge,

        // ),

        SizedBox(
          height: 8.h,
        ),

        Image.asset(
          image,
          height: 57.h,
        ),
        SizedBox(
          height: 17.h,
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Padding(
          padding:  EdgeInsets.all(5.0.sp),
          child: Text(
            description,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 10.h),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
