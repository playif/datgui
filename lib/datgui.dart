library datgui;

import "dart:js";
@MirrorsUsed(targets: const ['datgui'], override: '*')
import "dart:mirrors";


final JsObject _dat = context['dat'];

class GUI {

  JsObject _gui;
  List<GUI> _folders = [];
  List<Controller> _controllers = [];

  //{bool autoPlace:true,scrollable:false,resizable:true}

  GUI() {
    _gui = new JsObject(_dat['GUI']);
  }

  GUI._fromGUI(this._gui);

  Controller add(Object object, String property, [arg1, arg2 = null]) {
    Object value;

    if (object is Map) {
      if (!object.containsKey(property)) {
        if (arg1 is List) {
          object[property] = arg1.first;
        } else if (arg1 is Map) {
          object[property] = arg1.values.first;
        } else {
          object[property] = arg1;
        }
      }

      value = object[property];
    } else {
      value = reflect(object).getField(new Symbol(property)).reflectee;
    }

    Map data = {
      property: value
    };
    JsObject cont;
    if (arg1 is List) {
      arg1 = new JsArray.from(arg1);
      arg1 = new JsObject.jsify(arg1);
    }
    cont =
        _gui.callMethod("add", [new JsObject.jsify(data), property, arg1, arg2]);

    Controller controller =
        new Controller._(data, cont, object, property, value);
    controllers.add(controller);
    return controller;
  }

  Controller addColor(Object object, String property) {
    Object value = reflect(object).getField(new Symbol(property)).reflectee;
    Map data = {
      property: value
    };
    JsObject cont =
        _gui.callMethod("addColor", [new JsObject.jsify(data), property]);

    Controller controller =
        new Controller._(data, cont, object, property, value);
    controllers.add(controller);
    return controller;
  }

  GUI addFolder(String name) {
    GUI folder = new GUI._fromGUI(_gui.callMethod("addFolder", [name]));
    folders.add(folder);
    return folder;
  }

  List<GUI> get folders {
    return _folders;
//    Map fs = JSON.decode(context['JSON'].callMethod('stringify', [_gui['__folders']]));
//
//    //JsObject fs = _gui['__folders'];
//    List result = [];
//    for (JsObject f in fs.values) {
//      result.add(new GUI._fromGUI(f));
//    }
//    return result;
  }

  List<Controller> get controllers {
    return _controllers;
//    JsArray cs = _gui['__controllers'];
//    List result = [];
//    for (JsObject c in cs) {
//      result.add(new Controller._fromCont(c));
//    }
//    return result;
  }

  open() {
    _gui.callMethod("open");
  }

  close() {
    _gui.callMethod("close");
  }

  destroy() {
    _gui.callMethod("destroy");
  }

  remove(Controller controller) {
    controllers.remove(controller);
    _gui.callMethod("remove", [controller._cont]);
  }

  GUI getRoot() {
    return new GUI._fromGUI(_gui.callMethod("getRoot"));
  }

  save() {
    _gui.callMethod("save");
  }

  saveAs() {
    _gui.callMethod("saveAs");
  }

  revert([GUI gui]) {
    if (gui != null) {
      _gui.callMethod("revert", [gui._gui]);
    } else {
      _gui.callMethod("revert");
    }

  }

  listen(Controller controller) {
    _gui.callMethod("listen", [controller._cont]);
  }

//  remember(Object obj){
//    _gui.callMethod("remember",[]);
//  }

  bool get closed {
    return _gui['closed'];
  }

  set closed(bool value) {
    _gui['closed'] = value;
  }

  String get name {
    return _gui['name'];
  }

  set name(String value) {
    _gui['name'] = value;
  }

  num get width {
    return _gui['width'];
  }

  set width(num value) {
    _gui['width'] = value;
  }

  String get preset {
    return _gui['preset'];
  }

  set preset(String value) {
    _gui['preset'] = value;
  }

  bool get autoPlace {
    return _gui['autoPlace'];
  }

  bool get scrollable {
    return _gui['scrollable'];
  }

  GUI get parent {
    return new GUI._fromGUI(_gui.callMethod("parent"));
  }


}

typedef void ChangeFunc(var value);

class Controller {
  var _data;
  JsObject _cont;
  // Object or Map
  var _object;
  String _property;
  Object _dv;
  Function _onChange;

  Controller._(this._data, this._cont, this._object, this._property, this._dv) {
    _cont.callMethod('onChange', [_onChangeProxy]);
  }

  Controller._fromCont(this._cont);

  Controller onChange(ChangeFunc func) {
    _onChange = func;
    return this;
  }

  // Proxy the onchange method so dart values can be changed.
  void _onChangeProxy(Object value) {
    if (_dv is! Function) {
      if (_dv is String && value is num) {
        value = value.toString();
      } else if (_dv is num && value is String) {
        value = num.parse(value);
      }
      if (_object is Map) {
        _object[_property] = value;
      } else {
        reflect(_object).setField(new Symbol(_property), value);
      }
    }
    if (_onChange != null) {
      _onChange(value);
    }
  }

  Controller onFinishChange(ChangeFunc func) {
    _cont.callMethod("onFinishChange", [func]);
    return this;
  }

  Controller updateDisplay() {
    _cont.callMethod('updateDisplay');
    return this;
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
