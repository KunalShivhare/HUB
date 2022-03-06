import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/localSettings.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/model/offers.dart';
import 'package:ondemandservice/model/service.dart';
import 'package:ondemandservice/model/settings.dart';
import 'package:ondemandservice/ui/rating.dart';
import 'package:ondemandservice/util.dart';
import 'package:ondemandservice/widgets/loader/loader7.dart';
import 'package:provider/provider.dart';
import '../strings.dart';
import 'booking/pricingTable.dart';
import 'theme.dart';
import 'package:ondemandservice/widgets/appbars/appbar1.dart';
import 'package:ondemandservice/widgets/buttons/button1.dart';
import 'package:ondemandservice/widgets/cards/card43.dart';
import 'package:ondemandservice/widgets/cards/card44.dart';
import 'package:ondemandservice/widgets/clippath/clippath23.dart';

class JobInfoScreen extends StatefulWidget {
  @override
  _JobInfoScreenState createState() => _JobInfoScreenState();
}

class _JobInfoScreenState extends State<JobInfoScreen>
    with TickerProviderStateMixin {
  var windowWidth;
  var windowHeight;
  late MainModel _mainModel;
  String servicemanname = "";
  String servicemanphone = "";

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context, listen: false);
    _mainModel.setJobInfoListen(_redraw);
    if (localSettings.jobInfo.servicemanid.isNotEmpty) _loadserviceman();
    super.initState();
  }

  _loadserviceman() async {
    try {
      var sm = await FirebaseFirestore.instance
          .collection("serviceman")
          .doc(localSettings.jobInfo.servicemanid)
          .get();
      var smdata = sm.data();
      if (smdata != null) {
        setState(() {
          servicemanname = (smdata['name'] != null) ? smdata['name'] : "";
          servicemanphone = (smdata['phone'] != null) ? smdata['phone'] : "";
        });
      }
    } catch (e) {
      print("Job Serviceman: " + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    print(servicemanname + servicemanphone);
    var _date = strings.get(109);

    /// "Any Time",
    if (!localSettings.jobInfo.anyTime)
      _date = _mainModel.localAppSettings
          .getDateTimeString(localSettings.jobInfo.selectTime);

    StatusData _currentStatus = StatusData.createEmpty();
    StatusData _last = StatusData.createEmpty();
    var _found = false;
    for (var item in _mainModel.localAppSettings.statuses) {
      if (_found) {
        _currentStatus = item;
        _found = false;
      }
      if (item.id == localSettings.jobInfo.status) {
        _found = true;
      }
      if (!item.cancel) _last = item;
    }

    var _needReview = false;
    if (localSettings.jobInfo.status == _last.id) _needReview = true;

    return Scaffold(
        backgroundColor: (darkMode) ? blackColorTitleBkg : colorBackground,
        body: Directionality(
            textDirection: strings.direction,
            child: Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 220,
                      left: 0,
                      right: 0),
                  child: ListView(
                    children: _getList(),
                  ),
                ),
                ClipPath(
                    clipper: ClipPathClass23(20),
                    child: Container(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 50,
                          left: 20,
                          right: 20,
                          bottom: 20),
                      width: windowWidth,
                      color: (darkMode) ? Colors.black : Colors.white,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              margin: EdgeInsets.only(left: 10, right: 10),
                              child: Card43(
                                  image: localSettings.jobInfo.providerAvatar,
                                  text1: getTextByLocale(
                                      localSettings.jobInfo.provider),
                                  text2: getTextByLocale(
                                      localSettings.jobInfo.service),
                                  text3: _date,
                                  date: _mainModel.localAppSettings
                                      .getStatusName(
                                          localSettings.jobInfo.status),
                                  dateCreating: _mainModel.localAppSettings
                                      .getDateTimeString(
                                          localSettings.jobInfo.time),
                                  bookingId: localSettings.jobInfo.id,
                                  icon: Icon(
                                    Icons.calendar_today_outlined,
                                    color: mainColor,
                                    size: 15,
                                  ),
                                  bkgColor: Colors.transparent)),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                              margin: EdgeInsets.only(left: 20, right: 20),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.phone,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      callMobile(
                                          localSettings.jobInfo.providerPhone);
                                    },
                                    child: Text(strings.get(64),

                                        /// "Call now",
                                        style: theme.style14W800MainColor),
                                  ),
                                  SizedBox(
                                    width: 30,
                                  ),
                                  Icon(
                                    Icons.message,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      var item = _mainModel.customersChat
                                          .firstWhere((element) {
                                        if (element.role.compareTo("owner") ==
                                            0)
                                          return true;
                                        else
                                          return false;
                                      });
                                      _mainModel.setChatData(
                                          item.name,
                                          item.unread,
                                          item.logoServerPath,
                                          item.id);
                                      _mainModel.route("chat2");
                                    },
                                    child: Text(strings.get(65),

                                        /// "Message",
                                        style: theme.style14W800MainColor),
                                  )
                                ],
                              )),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    )),
                if (_currentStatus.byCustomerApp && !_currentStatus.cancel)
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: button1a(
                        _currentStatus.cancel
                            ? ""
                            : getTextByLocale(_currentStatus.name),

                        /// button
                        theme.style16W800White,
                        mainColor, () {
                      _continue(_currentStatus);
                    }, _currentStatus.byCustomerApp && !_currentStatus.cancel),
                  ),
                if (_needReview && !localSettings.jobInfo.rated)
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: button1a(
                        strings.get(161),

                        /// "Rate this provider",
                        theme.style16W800White,
                        mainColor, () {
                      _rate();
                    }, true),
                  ),
                appbar1(
                    Colors.transparent,
                    (darkMode) ? Colors.white : Colors.black,
                    "${strings.get(66)} ${localSettings.jobInfo.id}",
                    context, () {
                  // Booking ID
                  _mainModel.goBack();
                }),
                if (_wait)
                  Center(
                      child: Container(
                          child: Loader7(
                    color: mainColor,
                  ))),
              ],
            )));
  }

  _getList() {
    List<Widget> list = [];

    if (servicemanphone.isNotEmpty)
      list.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: EdgeInsets.all(8.0),
          margin: EdgeInsets.only(
            left: 10,
            right: 10,
          ),
          decoration: BoxDecoration(
              borderRadius: new BorderRadius.circular(10.0),
              color: Colors.white),
          child: Column(
            children: [
              Text(
                "Serviceman Assigned:",
                style: theme.style16W800,
              ),
              SizedBox(
                height: 10.0,
              ),
              Text(servicemanname,
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
              SizedBox(
                height: 10.0,
              ),
              InkWell(
                onTap: () {
                  callMobile(servicemanphone);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                      Icon(
                        Icons.phone,
                        color: Colors.blue,
                        size: 30,
                      ),
                    SizedBox(width: 5.0,),
          Text(strings.get(64),
                /// "Call now",
                style: theme.style14W800MainColor),
                  ],
                ),
              )
            ],
          ),
        ),
      ));

    bool _current = false;
    for (var item in _mainModel.localAppSettings.statuses) {
      // date
      var _date = "";
      if (!_current) {
        DateTime _time = localSettings.jobInfo.getHistoryDate(item.id).time;
        String _text = _mainModel.localAppSettings.getDateTimeString(_time);
        _date = "${strings.get(78)}:\n$_text";

        /// Requested on
      }
      //
      var passed = _mainModel.isPassed(item);
      if (item.cancel && !passed && !localSettings.jobInfo.finished)
        list.add(Container(
            margin: EdgeInsets.only(top: 15, bottom: 15),
            child: button1a(
                getTextByLocale(item.name),

                /// cancel button
                theme.style16W800White,
                mainColor, () {
              _continue(item);
            }, true)));

      if (item.cancel && passed) {
        var t = strings.get(210); // "by administrator",
        var _itemCancel = _mainModel.cancelItem(item);
        if (_itemCancel != null) {
          if (_itemCancel.byProvider) t = strings.get(211); // by provider
          if (_itemCancel.byCustomer) t = strings.get(212); // by customer
          _date = "$_date\n$t";
        }
      }

      list.add(
        Card44(
          image: item.serverPath,
          text1: getTextByLocale(item.name),
          style1: theme.style16W800,
          text2: passed ? _date : "",
          style2: TextStyle(fontSize: 16, color: Colors.grey),
          bkgColor: passed
              ? (darkMode)
                  ? Color(0xff404040)
                  : Colors.white
              : Colors.transparent,
          iconColor: !_current ? Colors.green : Colors.grey,
        ),
      );
      if (item.id == localSettings.jobInfo.status) _current = true;
    }

    list.add(SizedBox(
      height: 20,
    ));

    localSettings.price = PriceData(
        localSettings.jobInfo.priceName,
        localSettings.jobInfo.price,
        localSettings.jobInfo.discPrice,
        localSettings.jobInfo.priceUnit,
        ImageData());
    localSettings.count = localSettings.jobInfo.count;
    localSettings.coupon = OfferData(
        localSettings.jobInfo.couponId, localSettings.jobInfo.couponName,
        discount: localSettings.jobInfo.discount,
        discountType: localSettings.jobInfo.discountType,
        services: [],
        providers: [],
        category: [],
        expired: DateTime.now(),
        desc: []);
    _mainModel.currentService.tax = localSettings.jobInfo.tax;
    _mainModel.currentService.addon = localSettings.jobInfo.addon;
    list.add(pricingTable(context, _mainModel));

    list.add(SizedBox(
      height: 150,
    ));

    return list;
  }

  bool _wait = false;

  _waits(bool value) {
    _wait = value;
    _redraw();
  }

  _redraw() {
    if (mounted) setState(() {});
  }

  _continue(StatusData currentItem) async {
    _waits(true);
    var ret = await _mainModel.nextStep(currentItem);
    _waits(false);
    if (ret != null) return messageError(context, ret);
  }

  _rate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RatingScreen(), //ReviewsScreen(),
      ),
    );
  }
}
