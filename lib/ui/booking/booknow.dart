import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/localSettings.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/model/user.dart';
import 'package:ondemandservice/util.dart';
import 'package:ondemandservice/widgets/dialogs/easyDialog2.dart';
import 'package:provider/provider.dart';
import '../../strings.dart';
import '../theme.dart';
import 'package:ondemandservice/widgets/appbars/appbar1.dart';
import 'package:ondemandservice/widgets/buttons/button1.dart';
import 'package:ondemandservice/widgets/buttons/button2.dart';
import 'package:ondemandservice/widgets/checkbox/checkbox43.dart';
import 'package:ondemandservice/widgets/clippath/clippath23.dart';
import 'package:ondemandservice/widgets/edit/edit42.dart';

class BookNowScreen extends StatefulWidget {
  @override
  _BookNowScreenState createState() => _BookNowScreenState();
}

class _BookNowScreenState extends State<BookNowScreen> {

  var windowWidth;
  var windowHeight;
  double windowSize = 0;
  ScrollController _scrollController = ScrollController();
  var _editControllerHint = TextEditingController();
  ScrollController _scrollController2 = ScrollController();
  double _show = 0;
  late MainModel _mainModel;

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    _scrollController.addListener(_scrollListener);
    _editControllerHint.text = localSettings.hint;
    super.initState();
  }

  double _scroller = 20;
  _scrollListener() {
    var _scrollPosition = _scrollController.position.pixels;
    _scroller = 20-(_scrollPosition/(windowHeight*0.1/20));
    if (_scroller < 0)
      _scroller = 0;
    setState(() {
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollController2.dispose();
    _editControllerHint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    windowSize = min(windowWidth, windowHeight);
    return Scaffold(
      backgroundColor: (darkMode) ? blackColorTitleBkg : colorBackground,
      body: Directionality(
      textDirection: strings.direction,
      child: Stack(
          children: [
            NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                      expandedHeight: windowHeight*0.2,
                      automaticallyImplyLeading: false,
                      pinned: true,
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      flexibleSpace: ClipPath(
                        clipper: ClipPathClass23((_scroller < 5) ? 5 : _scroller),
                        child: Container(
                            child: Stack(
                              children: [
                                FlexibleSpaceBar(
                                    collapseMode: CollapseMode.pin,
                                    background: _title(),
                                    titlePadding: EdgeInsets.only(bottom: 10, left: 20, right: 20),
                                )
                              ],
                            )),
                      ))
                ];
              },
              body: Container(
                width: windowWidth,
                height: windowHeight,
                child: _body(),
              ),
            ),

            appbar1((_scroller > 1) ? Colors.transparent :
                  (darkMode) ? Colors.black : Colors.white,
                (darkMode) ? Colors.white : Colors.black,
                (_scroller > 5) ? "" : getTextByLocale(_mainModel.currentService.name), context,
                    () {_mainModel.goBack();}),

            Container(
              alignment: Alignment.bottomCenter,
              child: button1a(strings.get(46), /// "CONTINUE"
                  theme.style16W800White,
                  mainColor, _book, true),
            ),

            IEasyDialog2(setPosition: (double value){_show = value;}, getPosition: () {return _show;}, color: Colors.grey,
              getBody: _getDialogBody, backgroundColor: (darkMode) ? Colors.black : Colors.white,),

          ])),
    );
  }

  _title() {
    var _data = _mainModel.getTitleImage();
    if (_data.serverPath.isEmpty)
      return Container();
    return Container(
      color: (darkMode) ? blackColorTitleBkg : colorBackground,
      height: windowHeight * 0.3,
      width: windowWidth,
      child: Stack(
        children: [
          Container(
                alignment: Alignment.bottomRight,
                child: Container(
                  width: windowWidth,
                  margin: EdgeInsets.only(bottom: 10),
                  child: CachedNetworkImage(
                      imageUrl: _data.serverPath,
                      imageBuilder: (context, imageProvider) => Container(
                        width: double.maxFinite,
                        alignment: Alignment.bottomRight,
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              )),
                        ),
                      )
                  ),
                )),
        ],
      ),
    );
  }

  _body(){
    List<Widget> list = [];

    list.add(Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: (darkMode) ? Colors.black : Colors.white,
          borderRadius: new BorderRadius.circular(10),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(strings.get(103), /// "Your address",
                  style: theme.style13W800, textAlign: TextAlign.start,)),
                SizedBox(width: 10,),
                _mainModel.getSubvalue()?
                _mainModel.userAddress.length<1?
                button2b(strings.get(104), (){  /// "Add new",
                  _mainModel.route("address_add");
                }):Container():button2b(strings.get(104), (){  /// "Add new",
                  _mainModel.route("address_add");
                }),
              ],
            ),
            Divider(color: (darkMode) ? Colors.white : Colors.black),
            SizedBox(height: 5,),
            Row(
              children: [
                Icon(Icons.location_on_outlined, color: Colors.orange),
                SizedBox(width: 10,),
                Expanded(child: _addresses())
              ],
            ),
            //SizedBox(height: 10,),
          ],
        )
    ));

    // if (!_mainModel.userAccount.ifUserAddressInProviderRoute())
    //   list.add(Container(
    //     margin: EdgeInsets.all(10),
    //     child: Row(
    //       children: [
    //         Expanded(child: Text(strings.get(217), style: theme.style12W600Red,)), /// "Your address is outside provider work area"
    //         SizedBox(width: 10,),
    //         button2b(strings.get(218), (){  /// "See details",
    //           _mainModel.route("booking_map_details");
    //         })
    //       ],
    //     )
    //     )
    //   );

    list.add(SizedBox(height: 10,));

    list.add(Container(
      color: (darkMode) ? Colors.black : Colors.white,
      padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
      child: edit42(strings.get(219), /// "Special Requests",
          _editControllerHint,
          strings.get(106), /// "Is there anything else",
          ),
    ));

    list.add(SizedBox(height: 20,));

    list.add(Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
      decoration: BoxDecoration(
        color: (darkMode) ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: checkBox43("Within 24 Hours", /// "Any Time",
          theme.booking1CheckBoxColor, "",
          theme.style14W800, localSettings.anyTime, (val) {
            if (val) {
              localSettings.anyTime = val;
              localSettings.scheduleTime = false;
              _redraw();
            }
          }),
    ));

    list.add(SizedBox(height: 10,));

    // list.add(Container(
    //   margin: EdgeInsets.only(left: 10, right: 10),
    //   padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
    //   decoration: BoxDecoration(
    //     color: (darkMode) ? Colors.black : Colors.white,
    //     borderRadius: BorderRadius.circular(10),
    //   ),
    //   child: checkBox43(strings.get(110), /// "Schedule an Order",
    //       theme.booking1CheckBoxColor, "",
    //       theme.style14W800, localSettings.scheduleTime, (val) {
    //           if (val) {
    //             localSettings.scheduleTime = val;
    //             localSettings.anyTime = false;
    //             _redraw();
    //           }
    //       }),
    // ));

    list.add(SizedBox(height: 20,));

    if (localSettings.scheduleTime)
      list.add(Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          child: Row(
        children: [
          Expanded(child: button2(strings.get(112),
              (){
                _show = 1;
                _redraw();
              }
          //    _dateTime
          )), /// "Select a Date & Time",
        ],
      )));

    list.add(SizedBox(height: 10,));

    if (localSettings.scheduleTime)
      list.add(Container(
        margin: EdgeInsets.only(left: 10, right: 10),
        padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        decoration: BoxDecoration(
          color: (darkMode) ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(strings.get(111), style: theme.style14W800,), /// "Requested Service on",
            SizedBox(height: 10,),
            Text(_mainModel.localAppSettings.getDateTimeString(localSettings.selectTime),
              style: theme.style18W800,),
          ],
        ),
      ));

    list.add(SizedBox(height: 150,));
    return Container(
        child: ListView(
          padding: EdgeInsets.only(top: 0),
          children: list,
        )
    );
  }

  Widget _getDialogBody(){
    var widget = CupertinoDatePicker(
        onDateTimeChanged: (DateTime picked) {
          localSettings.selectTime = picked;
          print(picked.toString());
          _redraw();
        },
        mode: CupertinoDatePickerMode.dateAndTime,
        use24hFormat: _mainModel.localAppSettings.timeFormat == "24h",
        initialDateTime: DateTime.now().add(Duration(minutes: 1)),
        minimumDate: DateTime.now()
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: windowHeight*0.4,
          child: widget,
        ),
      Container(
        margin: EdgeInsets.only(left: 20, right: 20),
        child: button2(strings.get(46), (){ /// "CONTINUE",
          _show = 0;
          _redraw();
        })),
    ]);
  }

  _redraw(){
    if (mounted)
      setState(() {
      });
  }

  _oneItem(List<Widget> list, AddressData item){
    list.add(
        InkWell(onTap: (){
          _mainModel.userAccount.setCurrentAddress(item.id);
          _scrollController2.jumpTo(0);
          _redraw();
        },
        child: Container(
          decoration: BoxDecoration(
            color: _mainModel.userAccount.getCurrentAddress() == item ? Colors.blue.withAlpha(50) : Colors.transparent,
            border: Border.all(color: _mainModel.userAccount.getCurrentAddress() != item ? Colors.blue.withAlpha(50) : Colors.transparent),
            borderRadius: BorderRadius.circular(theme.radius),
          ),
          padding: EdgeInsets.all(10),
          child: Text(item.address, style: theme.style14W400,),
        )));
    list.add(SizedBox(width: 10,));
  }

  Widget _addresses(){
    List<Widget> list = [];
    // first - current address
    for (var item in _mainModel.userAddress)
      if (item == _mainModel.userAccount.getCurrentAddress())
        _oneItem(list, item);

    for (var item in _mainModel.userAddress)
      if (item != _mainModel.userAccount.getCurrentAddress())
        _oneItem(list, item);

    list.add(SizedBox(width: 10,));
    return Container(
      height: 40,
      child: ListView(
        controller: _scrollController2,
        scrollDirection: Axis.horizontal,
        children: list,
      ),
    );
  }

  _book(){
    if (_mainModel.userAccount.getCurrentAddress().id.isEmpty)
      return messageError(context, strings.get(134));  /// "Please select address",

    localSettings.setHint(_editControllerHint.text);

    _mainModel.route("book1");
  }

}
