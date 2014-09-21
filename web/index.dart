import "package:datgui/gui.dart" as dat;
import "dart:math";
import "dart:html";
//class FizzyText {
//  String message;
//  num speed;
//  bool displayOutline;
//
//  Map factoryArgs;
////  bool explode;
//
//  FizzyText() {
//    this.message = 'dat.gui';
//    this.speed = 0.8;
//    this.displayOutline = false;
//  }
//}

class FizzyText {
  String _message;
  num speed;
  num noiseStrength;
  num maxSize;
  num growthSpeed;
  num framesRendered;
  bool displayOutline;

  num width = 550;
  num height = 200;
  num textAscent = 101;
  num textOffsetLeft = 80;
  num noiseScale = 300;
  num frameTime = 30;

  Random random = new Random();

  List<int> pixels;

  // Stores a list of particles
  List<Particle> particles = [];

  String color="#00aeff";
  List<String> colors = ["#00aeff", "#0fa954", "#54396e", "#e61d5f"];

  // This is the context we use to get a bitmap of text using
  // the getImageData function.
  CanvasElement r = new CanvasElement();
  CanvasRenderingContext2D s;

  // This is the context we actually use to draw.
  CanvasElement c = new CanvasElement();
  CanvasRenderingContext2D g;

  FizzyText(String message) {
    // These are the variables that we manipulate with gui-dat.
    // Notice they're all defined with "this". That makes them public.
    // Otherwise, gui-dat can't see them.
    this.growthSpeed = 0.2; // how fast do particles change size?
    this.maxSize = 5.59; // how big can they get?
    this.noiseStrength = 10; // how turbulent is the flow?
    this.speed = 0.4; // how fast do particles move?
    this.displayOutline = false; // should we draw the message as a stroke?
    this.framesRendered = 0;

    s = r.getContext('2d');
    g = c.getContext('2d');


    r.setAttribute('width', width.toString());
    c.setAttribute('width', width.toString());
    r.setAttribute('height', height.toString());
    c.setAttribute('height', height.toString());

    // Add our demo to the HTML
    //document.getElementById('body').append(c);
    querySelector('body').append(c);
//    // Stores bitmap image
//    var pixels = [];


    // Set g.font to the same font as the bitmap canvas, incase we
    // want to draw some outlines.
    s.font = g.font = "800 82px helvetica, arial, sans-serif";

    // Instantiate some particles
    for (int i = 0; i < 1000; i++) {
      particles.add(new Particle(this, random.nextDouble() * width, random.nextDouble() * height));
    }

    this.message = message;

    // This calls the render function every 30 milliseconds.
    window.requestAnimationFrame(loop);
  }


  // __defineGetter__ and __defineSetter__ makes JavaScript believe that
  // we've defined a variable 'this.message'. This way, whenever we
  // change the message variable, we can call some more functions.

  String get message => _message;


  set message(String value) {
    _message = value;
    createBitmap(_message);
  }


  // We can even add functions to the DAT.GUI! As long as they have
  // 0 arguments, we can call them from the dat-gui panel.

  explode() {

    num mag = random.nextInt(30) + 30;
    for (Particle i in particles) {
      num angle = random.nextDouble() * PI * 2;
      i.vx = cos(angle) * mag;
      i.vy = sin(angle) * mag;
    }
  }


  // This function creates a bitmap of pixels based on your message
  // It's called every time we change the message property.

  createBitmap(String msg) {

    s.fillStyle = "#fff";
    s.fillRect(0, 0, width, height);

    s.fillStyle = "#222";
    s.fillText(msg, textOffsetLeft, textAscent);

    // Pull reference
    ImageData imageData = s.getImageData(0, 0, width, height);
    pixels = imageData.data;

  }

  // Called once per frame, updates the animation.

  render() {

    framesRendered ++;

    g.clearRect(0, 0, width, height);

    if (displayOutline) {
      g.globalCompositeOperation = "source-over";
      g.strokeStyle = "#000";
      g.lineWidth = .5;
      g.strokeText(message, textOffsetLeft, textAscent);
    }

    g.globalCompositeOperation = "darker";

    for (var i = 0; i < particles.length; i++) {
      g.fillStyle = colors[i % colors.length];
      particles[i].render();
    }

  }

  // Returns x, y coordinates for a given index in the pixel array.

  getPosition(i) {
    return {
        'x': (i - (width * 4) * (i / (width * 4)).floor()) / 4,
        'y': (i / (width * 4)).floor()
    };
  }


  // This calls the setter we've defined above, so it also calls
  // the createBitmap function.
  //

  loop(num dt) {
    // Don't render if we don't see it.
    // Would be cleaner if I dynamically acquired the top of the canvas.
    if (document.body.scrollTop < height + 20) {
      render();
    }
    window.requestAnimationFrame(loop);
  }


}

// This class is responsible for drawing and moving those little
// colored dots.
class Particle {
  num x, y, r, vx, vy;
  FizzyText ft;

  Particle(FizzyText ft, num x, num y) {

    // Position
    this.x = x;
    this.y = y;

    // Size of particle
    this.r = 0;

    // This velocity is used by the explode function.
    this.vx = 0;
    this.vy = 0;

    this.ft = ft;

  }

  // Returns a color for a given pixel in the pixel array.

  String getColor(num x, num y) {
    if (x < 0 || y < 0 || x > ft.width || y > ft.height) return '';
    num base = (y.floor() * ft.width + x.floor()) * 4;
    Map c = {
        'r': (ft.pixels[base]),
        'g': (ft.pixels[base + 1]),
        'b': (ft.pixels[base + 2]),
        'a': (ft.pixels[base + 3])
    };

    return "rgb(" + c['r'].toString() + "," + c['g'].toString() + "," + c['b'].toString() + ")";
  }

  // Called every frame

  render() {

    // What color is the pixel we're sitting on top of?
    String c = getColor(this.x, this.y);

    // Where should we move?
    //var angle = noise(this.x / ft.noiseScale, this.y / ft.noiseScale) * ft.noiseStrength;
    num angle = ft.random.nextDouble() * 360;
    // Are we within the boundaries of the image?
    bool onScreen = this.x > 0 && this.x < ft.width &&
                    this.y > 0 && this.y < ft.height;

    bool isBlack = c != "rgb(255,255,255)" && onScreen;

    // If we're on top of a black pixel, grow.
    // If not, shrink.
    if (isBlack) {
      this.r += ft.growthSpeed;
    } else {
      this.r -= ft.growthSpeed;
    }

    // This velocity is used by the explode function.
    this.vx *= 0.5;
    this.vy *= 0.5;

    // Change our position based on the flow field and our
    // explode velocity.
    this.x += cos(angle) * ft.speed + this.vx;
    this.y += -sin(angle) * ft.speed + this.vy;

    this.r = max(0, min(this.r, ft.maxSize));

    // If we're tiny, keep moving around until we find a black
    // pixel.
    if (this.r <= 0) {
      this.x = ft.random.nextDouble() * ft.width;
      this.y = ft.random.nextDouble() * ft.height;
      return;
      // Don't draw!
    }

    // Draw the circle.
    ft.g.beginPath();
    ft.g.arc(this.x, this.y, this.r, 0, PI * 2, false);
    ft.g.fill();

  }
}

main() {
  FizzyText text = new FizzyText("DATGUI");
  dat.GUI gui = new dat.GUI();
  //gui.add(text, 'message');
  //gui.add(text, 'speed', -5, 5);
  gui.add(text, 'displayOutline');
  gui.add(text, 'explode');

  gui.add(text, 'noiseStrength').step(5); // Increment amount
  gui.add(text, 'growthSpeed', -5, 5); // Min and max
  gui.add(text, 'maxSize').min(0).step(0.25); // Mix and match
  dat.GUI f1=gui.addFolder("Folder");
  f1.add(text, 'message', [ 'pizza', 'chrome', 'hooray' ] );
  var c1=f1.add(text, 'speed', { 'Stopped': 0, 'Slow': 0.1, 'Fast': 5 } );
  f1.open();

  gui.addColor(text,'color');

  gui.closed=true;
  //f1.remove(c1);
}
