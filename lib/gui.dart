import "dart:js";
import "dart:mirrors";

final JsObject _dat = context['dat'];

class GUI {

  JsObject _gui;

  //{bool autoPlace:true,scrollable:false,resizable:true}
  GUI() {
    _gui = new JsObject(_dat['GUI']);
  }

  GUI._fromGUI(this._gui){

  }



  Controller add(Object object, String property, [arg1, arg2=null]) {
    Object value = reflect(object).getField(new Symbol(property)).reflectee;
    Map data = {
        property:value
    };
    JsObject cont;
    if (arg1 is List) {
      //cont = _gui.callMethod("add", [new JsObject.jsify(data), property, arg1]);
      arg1 = new JsArray.from(arg1);
    }
    else if (arg1 is Map) {
      arg1 = new JsObject.jsify(arg1);
    }
    cont = _gui.callMethod("add", [new JsObject.jsify(data), property, arg1, arg2]);
    return new Controller._(data, cont, object, property, value);
  }

  Controller addColor(Object object, String property) {
    Object value = reflect(object).getField(new Symbol(property)).reflectee;
    Map data = {
        property:value
    };
    JsObject cont = _gui.callMethod("addColor", [new JsObject.jsify(data), property]);
    return new Controller._(data, cont, object, property, value);
  }

  GUI addFolder(String name){
    return new GUI._fromGUI(_gui.callMethod("addFolder", [name]));
  }

  open(){
    _gui.callMethod("open");
  }

  close(){
    _gui.callMethod("close");
  }

  destroy(){
    _gui.callMethod("destroy");
  }

  remove(Controller controller){
    _gui.callMethod("remove",[controller._cont]);
  }

  GUI getRoot(){
    return new GUI._fromGUI(_gui.callMethod("getRoot"));
  }

  save(){
    _gui.callMethod("save");
  }

  saveAs(){
    _gui.callMethod("saveAs");
  }

  revert([GUI gui]){
    if(gui != null){
      _gui.callMethod("revert",[gui._gui]);
    }
    else{
      _gui.callMethod("revert");
    }

  }

  listen(Controller controller){
    _gui.callMethod("listen",[controller._cont]);
  }

//  remember(Object obj){
//    _gui.callMethod("remember",[]);
//  }

  bool get closed{
    return _gui['closed'];
  }

  set closed (bool value){
    _gui['closed']=value;
  }

  String get name{
    return _gui['name'];
  }

  set name (String value){
    _gui['name']=value;
  }

  num get width{
    return _gui['width'];
  }

  set width (num value){
    _gui['width']=value;
  }

  String get preset{
    return _gui['preset'];
  }

  set preset (String value){
    _gui['preset']=value;
  }

  bool get autoPlace{
    return _gui['autoPlace'];
  }

  bool get scrollable{
    return _gui['scrollable'];
  }

  GUI get parent {
    return new GUI._fromGUI(_gui.callMethod("parent"));
  }


}

class Controller {
  var data;
  JsObject _cont;
  Object _object;
  String _property;

  Controller._(this.data, this._cont, this._object, this._property, Object dv){
    if (dv is! Function) {
      _cont.callMethod('onChange', [(Object value) {
        if (dv is String && value is num) {
          value = value.toString();
        }
        else if (dv is num && value is String) {
          value = num.parse(value);
        }
        reflect(_object).setField(new Symbol(_property), value);
      }]);
    }
  }

  Controller step(num value) {
    _cont.callMethod('step', [value]);
    return this;
  }

  Controller max(num value) {
    _cont.callMethod('max', [value]);
    return this;
  }

  Controller min(num value) {
    _cont.callMethod('min', [value]);
    return this;
  }

}
