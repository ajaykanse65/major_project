import 'package:animated_emoji/animated_emoji.dart';
import 'package:bms/admin/adminbottomdot.dart';
import 'package:bms/widget/custom_search_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class CreatePayment extends StatefulWidget {
  const CreatePayment({Key? key}) : super(key: key);

  @override
  State<CreatePayment> createState() => _CreatePaymentState();
}

class _CreatePaymentState extends State<CreatePayment> {
  @override
  Widget build(BuildContext context) {
    return const MyHomePage();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  Razorpay? _razorpay = Razorpay();
  String? paymentID;
  var total;
  DateTime now = DateTime.now();


  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(
        msg: "SUCCESS PAYMENT: ${response.paymentId}", timeInSecForIosWeb: 4);
    setState(() {
      String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
      total = int.parse(test['bal'].toString()) + int.parse(_controller.text);
      payID = response.paymentId;
      _updateBalance();
      _fetchBalance();
      addPaymentDetails();
      addAllCollection();
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg: "ERROR HERE: ${response.code} - ${response.message}",
        timeInSecForIosWeb: 4);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET IS : ${response.walletName}",
        timeInSecForIosWeb: 4);
  }

  String? _selectedValue;
  List<String> _options = [];
  var test, payID, datetime;
 List details=[];

  List _paymentList = [];
  late Stream<QuerySnapshot> _queryStream;

  void _fetchOptions() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('collectionPath').get();
    final options =
        snapshot.docs.map((doc) => doc.data()['billing'] as String).toList();
    // print(options);
    setState(() {
      _options = options;
    });
  }

  void _fetchBalance() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('collectionPath')
        .where('billing', isEqualTo: _selectedValue.toString())
        .get()
        .then((QuerySnapshot snapshot) {
      for (var element in snapshot.docs) {
        // print(test['id']);
        setState(() {
          test = element.data();
        });
      }
    });

    _fetchSelectedDetails();
    // print(options);
  }

  void _fetchSelectedDetails() async{
    final snapshot = await FirebaseFirestore.instance.collection('PaymentCollection').where('name',isEqualTo: _selectedValue.toString())
        .get()
        .then((QuerySnapshot snapshot) {
          for (var element in snapshot.docs) {
            setState(() {
              details.add(element.data());
            });
          }
    });
    // print(details);
  }

  void _fetchPaymentDetails() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('PaymentCollection')
        .get()
        .then((data) {
      data.docs.forEach((element) {
        setState(() {
          _paymentList.add(element.data());
        });
      });
    });
    // print(count);
  }

  void _updateBalance() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('collectionPath')
        .doc(test['id'].toString())
        .update({'bal': int.parse(total.toString())})
        .then((v) => debugPrint('success'))
        .catchError((e) => debugPrint(e));
  }

  void addPaymentDetails() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('collectionPath')
        .doc(test['id'].toString())
        .collection("BillingCollection");
    Map<String, dynamic> data = {
      'name': _selectedValue.toString(),
      'payID': payID.toString(),
      'amount': _controller.text,
      'datetime': DateFormat('yyyy-MM-dd – hh:mm').format(now),
      'status': 'Completed'
    };
    snapshot
        .doc()
        .set(data)
        .then((value) => debugPrint("Data Added Successfully"))
        .catchError((e) => debugPrint("error: $e"));
  }

  void addAllCollection() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('PaymentCollection').doc();
    Map<String, dynamic> data = {
      'name': _selectedValue.toString(),
      'payID': payID.toString(),
      'amount': _controller.text,
      'datetime': DateFormat('yyyy-MM-dd – hh:mm').format(now),
      'status': 'Completed'
    };
    snapshot
        .set(data)
        .then((value) => debugPrint("Data Added Successfully"))
        .catchError((e) => debugPrint("error: $e"));
  }

  @override
  void initState() {
    _queryStream = FirebaseFirestore.instance.collection('planDetails').snapshots();
    print(DateFormat('yyyy-MM-dd – hh:mm').format(now));
    super.initState();
    _fetchOptions();
    _fetchPaymentDetails();
    _razorpay = Razorpay();
    _razorpay?.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay?.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay?.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _razorpay?.clear();
  }

  bool testtile = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: AdminBottomDot(selectedIndex: 2),
      backgroundColor: Color.fromRGBO(193, 214, 223, 1),
      extendBody: true,
      appBar: SearchBar(titile: 'Top up'),
      body: Column(
        children: [
          Container(
            color: Color.fromRGBO(193, 214, 223, 1),
            // width: MediaQuery.of(context).size.width,
            child: Card(
                color: Color(0xFF607894),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                elevation: 20,
                margin: const EdgeInsets.only(
                    top: 30.0, right: 30.0, left: 30.0, bottom: 0.0),
                child: Padding(
                  padding: const EdgeInsets.only(top: 30.0, right: 20.0, left: 20.0,),
                  child: Column(
                    children: <Widget>[
                      const Text(
                        'BMS Network',
                        style:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            border: Border.all(),
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(25.0)),
                        child: DropdownButton(
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.black,
                          ),
                          value: _selectedValue,
                          items: _options.map((value) {
                            return DropdownMenuItem(
                              value: value,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 120),
                                child: Text(
                                  value,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedValue = value as String?;
                              _fetchBalance();
                              // print(test['id'].toString());
                              // print(id.toString());
                            });
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      _selectedValue != null
                          ? FittedBox(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 100),
                                child: Text(
                                  "Current Balance: ${test['bal']}",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(left: 80),
                              child: Text(
                                'No account selected...',
                                style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Enter amount',
                          hintStyle:
                              const TextStyle(color: Colors.grey, fontSize: 16.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          prefixIcon: const Icon(Icons.currency_rupee),
                        ),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: ElevatedButton(
                          onPressed: () {
                            openPaymentPortal();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white),
                          child: const Text(
                            "Pay",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ),
          _selectedValue != null
              ?  Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('PaymentCollection').where('name', isEqualTo: _selectedValue.toString()).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Transaction record not found...',style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold),),
                      AnimatedEmoji(AnimatedEmojis.sad,repeat: true,),
                    ],
                  );
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) =>
                      Padding(
                        padding: const EdgeInsets.only(left: 15,right: 15,top: 5,bottom: 5),
                        child: ListTile(
                          style: ListTileTheme.of(context).style,
                          selectedTileColor: Color(0xFF8e9fb3),
                          shape: RoundedRectangleBorder(
                              side: BorderSide(width: 1.5),
                              borderRadius: BorderRadius.circular(25)),
                          selected: testtile,
                          onTap: () {
                            setState(() {

                            });
                          },
                          leading: Icon(
                            Icons.receipt_long_sharp,
                            size: 40,
                            color: Colors.black,
                          ),
                          title: Text('Name: ${doc['name']}',
                            style: TextStyle(
                                letterSpacing: 1,
                                height: 1.2,
                                color: Colors.black),
                          ),
                          subtitle: Text(
                            '${doc['datetime']}\nPayment ID: ${doc['payID']}',
                            style: TextStyle(
                                letterSpacing: 1,
                                height: 1.2,
                                color: Colors.black),
                          ),
                          trailing: Text(
                            'Amount: ${doc['amount']}\nStatus: \n${doc['status']}',
                            style: TextStyle(
                                letterSpacing: 1,
                                height: 1.2,
                                color: Colors.black),
                          ),
                        ),
                      )
                  ).toList(),
                );
              },
            ),
          )
          // Expanded(child: StreamBuilder<QuerySnapshot>(
          //   stream: FirebaseFirestore.instance.collection('collectionPath').doc(test['id'].toString()).collection('planDetails').where('name',isEqualTo: _selectedValue).snapshots(),
          //   builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          //     if (snapshot.hasError) {
          //       return Text('Error: ${snapshot.error}');
          //     }
          //
          //     if (snapshot.connectionState == ConnectionState.waiting) {
          //       return Center(child: CircularProgressIndicator());
          //     }
          //
          //     if (snapshot.data!.docs.isEmpty) {
          //       return Text('No items found.');
          //     }
          //
          //     return ListView(
          //       children: snapshot.data!.docs.map((doc) =>
          //           ListView.separated(
          //             scrollDirection: Axis.vertical,
          //             shrinkWrap: true,
          //             itemCount: details.length,
          //             itemBuilder: (BuildContext context, int index) {
          //               return
          //                 ListTile(
          //                   style: ListTileTheme.of(context).style,
          //                   selectedTileColor: Color(0xFF8e9fb3),
          //                   shape: RoundedRectangleBorder(
          //                       side: BorderSide(width: 1.5),
          //                       borderRadius: BorderRadius.circular(25)),
          //                   selected: testtile,
          //                   onTap: () {
          //                     setState(() {
          //
          //                     });
          //                   },
          //                   leading: Icon(
          //                     Icons.receipt_long_sharp,
          //                     size: 40,
          //                     color: Colors.black,
          //                   ),
          //                   title: Text(
          //                     doc['name'],
          //                     style: TextStyle(
          //                         letterSpacing: 1,
          //                         height: 1.2,
          //                         color: Colors.black),
          //                   ),
          //                   subtitle: Text(
          //                     doc['datetime'],
          //                     style: TextStyle(
          //                         letterSpacing: 1,
          //                         height: 1.2,
          //                         color: Colors.black),
          //                   ),
          //                   trailing: Text(
          //                     '${doc['amount']}\n ${doc['status']}',
          //                     style: TextStyle(
          //                         letterSpacing: 1,
          //                         height: 1.2,
          //                         color: Colors.black),
          //                   ),
          //                 );
          //             },
          //             separatorBuilder: (context,index){
          //               return Divider(height: 10,);
          //             },
          //           ),
          //       ).toList(),
          //     );
          //   },
          // ))

          // Expanded(child: StreamBuilder<QuerySnapshot>(
          //     stream: _queryStream,
          //     builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          //       if (snapshot.hasError) {
          //         return Text('Error: ${snapshot.error}');
          //       }
          //
          //       if (snapshot.connectionState == ConnectionState.waiting) {
          //         return Center(child: CircularProgressIndicator());
          //       }
          //
          //       if (snapshot.data!.docs.isEmpty) {
          //         return Text('No items found.');
          //       }
          //
          //       return ListView(
          //         children: snapshot.data!.docs.map((doc) =>
          //           ListView.separated(
          //                 scrollDirection: Axis.vertical,
          //                 shrinkWrap: true,
          //                 itemCount: details.length,
          //                 itemBuilder: (BuildContext context, int index) {
          //                   return
          //                     ListTile(
          //                     style: ListTileTheme.of(context).style,
          //                     selectedTileColor: Color(0xFF8e9fb3),
          //                     shape: RoundedRectangleBorder(
          //                         side: BorderSide(width: 1.5),
          //                         borderRadius: BorderRadius.circular(25)),
          //                     selected: testtile,
          //                     onTap: () {
          //                       setState(() {
          //
          //                       });
          //                     },
          //                     leading: Icon(
          //                       Icons.receipt_long_sharp,
          //                       size: 40,
          //                       color: Colors.black,
          //                     ),
          //                     title: Text(
          //                       doc['name'],
          //                       style: TextStyle(
          //                           letterSpacing: 1,
          //                           height: 1.2,
          //                           color: Colors.black),
          //                     ),
          //                     subtitle: Text(
          //                       doc['datetime'],
          //                       style: TextStyle(
          //                           letterSpacing: 1,
          //                           height: 1.2,
          //                           color: Colors.black),
          //                     ),
          //                     trailing: Text(
          //                       '${doc['amount']}\n ${doc['status']}',
          //                       style: TextStyle(
          //                           letterSpacing: 1,
          //                           height: 1.2,
          //                           color: Colors.black),
          //                     ),
          //                   );
          //                 },
          //                 separatorBuilder: (context,index){
          //                   return Divider(height: 10,);
          //                 },
          //               ),
          //         ).toList(),
          //       );
          //     },
          //   ))
          
            // Padding(
            //   padding: const EdgeInsets.all(10.0),
            //   child: ListView.separated(
            //     scrollDirection: Axis.vertical,
            //     shrinkWrap: true,
            //     itemCount: details.length,
            //     itemBuilder: (BuildContext context, int index) {
            //       return
            //         ListTile(
            //         style: ListTileTheme.of(context).style,
            //         selectedTileColor: Color(0xFF8e9fb3),
            //         shape: RoundedRectangleBorder(
            //             side: BorderSide(width: 1.5),
            //             borderRadius: BorderRadius.circular(25)),
            //         selected: testtile,
            //         onTap: () {
            //           setState(() {
            //
            //           });
            //         },
            //         leading: Icon(
            //           Icons.receipt_long_sharp,
            //           size: 40,
            //           color: Colors.black,
            //         ),
            //         title: Text(
            //           details[index]['name'],
            //           style: TextStyle(
            //               letterSpacing: 1,
            //               height: 1.2,
            //               color: Colors.black),
            //         ),
            //         subtitle: Text(
            //           details[index]['datetime'],
            //           style: TextStyle(
            //               letterSpacing: 1,
            //               height: 1.2,
            //               color: Colors.black),
            //         ),
            //         trailing: Text(
            //           '${details[index]['amount']}\n ${details[index]['status']}',
            //           style: TextStyle(
            //               letterSpacing: 1,
            //               height: 1.2,
            //               color: Colors.black),
            //         ),
            //       );
            //     },
            //     separatorBuilder: (context,index){
            //       return Divider(height: 10,);
            //     },
            //   ),
            // ),
              : Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('PaymentCollection').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return Text('No items found.');
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) =>
                      Padding(
                        padding: const EdgeInsets.only(left: 15,right: 15,top: 5,bottom: 5),
                        child: ListTile(
                          style: ListTileTheme.of(context).style,
                          selectedTileColor: Color(0xFF8e9fb3),
                          shape: RoundedRectangleBorder(
                              side: BorderSide(width: 1.5),
                              borderRadius: BorderRadius.circular(25)),
                          selected: testtile,
                          onTap: () {
                            setState(() {

                            });
                          },
                          leading: Icon(
                            Icons.receipt_long_sharp,
                            size: 40,
                            color: Colors.black,
                          ),
                          title: Text('Name: ${doc['name']}',
                            style: TextStyle(
                                letterSpacing: 1,
                                height: 1.2,
                                color: Colors.black),
                          ),
                          subtitle: Text(
                            '${doc['datetime']}\nPayment ID: ${doc['payID']}',
                            style: TextStyle(
                                letterSpacing: 1,
                                height: 1.2,
                                color: Colors.black),
                          ),
                          trailing: Text(
                            'Amount: ${doc['amount']}\nStatus: \n${doc['status']}',
                            style: TextStyle(
                                letterSpacing: 1,
                                height: 1.2,
                                color: Colors.black),
                          ),
                        ),
                      )
                  ).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void openPaymentPortal() async {
    var options = {
      'key': 'rzp_test_YjOu38M2dxdNJ5',
      'amount': int.parse(_controller.text) * 100,
      'name': 'BMS Network',
      'description': 'Payment',
      'prefill': {'contact': '9999999999', 'email': 'jhon@razorpay.com'},
      // 'external': {
      //   'wallets': ['paytm']
      // }
    };
    try {
      _razorpay?.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
