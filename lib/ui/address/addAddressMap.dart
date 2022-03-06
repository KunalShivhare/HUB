import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:ondemandservice/model/localSettings.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/util.dart';
import 'package:ondemandservice/widgets/map.dart';
import 'package:provider/provider.dart';
import '../../strings.dart';
import '../theme.dart';
import 'package:ondemandservice/widgets/appbars/appbar1.dart';
import 'package:ondemandservice/widgets/buttons/button2.dart';
import 'package:ondemandservice/widgets/edit/edit26.dart';
import 'package:ondemandservice/widgets/edit/edit42.dart';

class AddAddressMapScreen extends StatefulWidget {
  @override
  _AddAddressMapScreenState createState() => _AddAddressMapScreenState();
}

class _AddAddressMapScreenState extends State<AddAddressMapScreen> {

  var windowWidth;
  var windowHeight;
  GoogleMapController? _controller;
  double _currentZoom = 12;
  CameraPosition _kGooglePlex = CameraPosition(target: LatLng(0, 0), zoom: 12,);
  var _controllerSearch = TextEditingController();
  var _controllerScroll = ScrollController();
  var _editControllerAddress = TextEditingController();
  late MainModel _mainModel;
  String? _mapStyle;
  bool _isShow = true;
  late GoogleMapsPlaces places;
  List<Widget> _searchResult = [];
  Set<Marker> markers = {};

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context,listen:false);
    places =  GoogleMapsPlaces(apiKey: _mainModel.localAppSettings.googleMapApiKey);
    _kGooglePlex = CameraPosition(target: LatLng(
        localSettings.mapLat != 0 ? localSettings.mapLat: 48.846575206328446,  // paris coordinates by default
        localSettings.mapLng != 0 ? localSettings.mapLng: 2.302420789679285),
        zoom: localSettings.mapZoom,);
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
    super.initState();
  }

  @override
  void dispose() {
    _controllerScroll.dispose();
    _controllerSearch.dispose();
    _editControllerAddress.dispose();
    if (_controller != null)
      _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Directionality(
        textDirection: strings.direction,
        child: Stack(
          children: <Widget>[

            _map(),

            Align(
              alignment: Alignment.centerRight,
              child: Container(
                  margin: EdgeInsets.only(right: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      buttonMyLocation(_getCurrentLocation),
                      buttonPlus(_onMapPlus),
                      buttonMinus(_onMapMinus),
                    ],
                  )
              ),
            ),

            Container(
              margin: EdgeInsets.only(left: 10, right: 10, top: 10+MediaQuery.of(context).padding.top+40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                Edit26(
                  hint: strings.get(122), /// "Search",
                  color: (darkMode) ? Colors.black : Colors.white,
                  radius: 10,
                  style: theme.style14W400,
                  suffixIcon: Icons.cancel,
                  useAlpha: false,
                  icon: Icons.search,
                  onChangeText: _onPressSearch,
                  controller: _controllerSearch,
                  onSuffixIconPress: (){
                    _controllerSearch.text = "";
                    _searchResult = [];
                    setState(() {
                    });
                  }
                ),
                if (_searchResult.isNotEmpty && _isShow)
                  Container(
                    margin: EdgeInsets.only(top: 1),
                    height: 200,
                    width: windowWidth,
                    child: Scrollbar(
                      isAlwaysShown: true,
                      controller: _controllerScroll,
                      child: ListView(
                        controller: _controllerScroll,
                        addAutomaticKeepAlives: false,
                        padding: EdgeInsets.only(top: 0),
                        children: _searchResult,
                    )),
                  )
              ],),
            ),

            Container(
              alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.all(10),
                    color: (darkMode) ? Colors.black : Colors.white,
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 10),
                      edit42(strings.get(119), // "Full address",
                          _editControllerAddress,
                          strings.get(213), /// "Enter address",
                          ),
                      SizedBox(height: 5),
                      Row(children: [
                        Text("${strings.get(207)} ${_mainModel.userAccount.latitude} - " /// "Latitude",
                            "${strings.get(208)} ${_mainModel.userAccount.longitude}", style: theme.style10W400,) /// "Longitude",
                      ],),
                      SizedBox(height: 10),
                      Center(child: button2b(strings.get(121), /// "Pick here",
                            (){
                          if (_editControllerAddress.text.isEmpty)
                            return messageError(context, strings.get(133)); /// "Please enter address"
                          _mainModel.userAccount.address = _editControllerAddress.text;
                          _mainModel.userAccount.openAddAddressDialog();
                        })
                      ),
                    ]))),

            appbar1t((darkMode) ? Colors.black : Colors.white,
                (darkMode) ? Colors.white : Colors.black, strings.get(117), // "Add Address"
                theme.style14W800, context, () {
                  _mainModel.goBack();
            })
          ],
        )
    ));
  }

  _onMapPlus(){
    _controller?.animateCamera(
      CameraUpdate.zoomIn(),
    );
  }

  _onMapMinus(){
    _controller?.animateCamera(
      CameraUpdate.zoomOut(),
    );
  }

  _map(){
    return GoogleMap(
        mapType: MapType.normal,
        zoomGesturesEnabled: true,
        zoomControlsEnabled: false, // Whether to show zoom controls (only applicable for Android).
        myLocationEnabled: true,  // For showing your current location on the map with a blue dot.
        myLocationButtonEnabled: true, // This button is used to bring the user location to the center of the camera view.
        initialCameraPosition: _kGooglePlex,
        markers: Set<Marker>.from(markers),
        onCameraMove:(CameraPosition cameraPosition){
          localSettings.setMap(cameraPosition.target.latitude, cameraPosition.target.longitude, cameraPosition.zoom);
          _currentZoom = cameraPosition.zoom;
        },
        onLongPress: (LatLng pos) {

        },
        onTap: (LatLng pos) {
          _mainModel.userAccount.latitude = pos.latitude;
          _mainModel.userAccount.longitude = pos.longitude;
          _isShow = false;
          _selectPos(pos);
          _onMapTap(pos);
        },
        onMapCreated: (GoogleMapController controller) {
           _controller = controller;
           if (darkMode)
             controller.setMapStyle(_mapStyle);
        });
  }

  _onMapTap(LatLng pos) async {
    var _textAddress = await getAddressFromLatLng(pos, _mainModel);
    if (_textAddress.isNotEmpty)
      _editControllerAddress.text = _textAddress;
    _redraw();
  }

  _redraw(){
    if (mounted)
      setState(() {
      });
  }

  _selectPos(LatLng pos){
    markers.clear();
    var _lastMarkerId = MarkerId("addr${pos.latitude}");
    final marker = Marker(
        markerId: _lastMarkerId,
        position: LatLng(pos.latitude, pos.longitude),
        onTap: () {

        }
    );
    markers.add(marker);
    setState(() {
    });
  }

  Future<Position> _getCurrent() async {
    var _currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation)
        .timeout(Duration(seconds: 10));
    // print("MyLocation::_currentPosition $_currentPosition");
    return _currentPosition;
  }

  _getCurrentLocation() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied)
        return;
    }
    var position = await _getCurrent();
    _controller!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: _currentZoom,
        ),
      ),
    );
  }

  _onPressSearch(String val) async {
    _isShow = true;
    PlacesSearchResponse response = await places.searchByText(val);
    if (!response.isOkay && response.errorMessage != null)
      messageError(context, response.errorMessage!);
    print(response.toString());
    _searchResult = [];
    for (var ret in response.results) {
      if (ret.formattedAddress != null)
        _searchResult.add(
            Stack(
            children: [
              Container(
                  padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                  width: windowWidth,
                  color: (darkMode) ? Colors.black : Colors.white,
                  child: Text(ret.formattedAddress!, style: theme.style14W400,)
              ),
              Positioned.fill(
                child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: Colors.grey[400],
                      onTap: (){
                        _onAddressClick(ret);
                      }, // needed
                    )),
              )

            ],
          )
      );
      _searchResult.add(
          Container(height: 1,
            width: windowWidth,
            color: Colors.grey,
          )
      );
    }
    setState(() {
    });
  }

  _onAddressClick(PlacesSearchResult ret){
    _searchResult = [];
    if (ret.formattedAddress != null)
      _editControllerAddress.text = ret.formattedAddress!;
    var pos = LatLng(ret.geometry!.location.lat, ret.geometry!.location.lng);
    _mainModel.userAccount.latitude = pos.latitude;
    _mainModel.userAccount.longitude = pos.longitude;
    _selectPos(pos);
    _controller!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: pos,
          zoom: _currentZoom,
        ),
      ),
    );
    _isShow = false;
    _redraw();
  }


}
