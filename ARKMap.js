//Create the canvas
var canvas = document.createElement("canvas");
var ctx = canvas.getContext("2d");
canvas.width = 600;
canvas.height = 600;
document.body.appendChild(canvas);

// load background
var bgReady = false;
var bgImage = new Image();
bgImage.onload = function () {
  bgReady = true;
};
bgImage.src = "http://gilgamech.com/ark/TheCenter.jpg";

// load clientClint
var clientClintReady = false;
var clientClintImage = new Image();
clientClintImage.onload = function () {
  clientClintReady = true;
};
clientClintImage.src = "http://gilgamech.com/images/clientClint.png";

// packet image
var packetReady = false;
var packetImage = new Image();
packetImage .onload = function () {
  packetReady = true;
};
packetImage .src = "http://gilgamech.com/images/packet.png";

// Game objects
var text = "";
// var TribeOutput = ""
var TribeO2 = "";

var clientClint = {};
var packet = {};
var packetsCaught = 0;

// keyboard controls
var mousePos = {};

addEventListener('mousemove', function(evt) {
 mousePos = getMousePos(canvas, evt);
}, false);

// addEventListener('mouseclick', function(evt) {
// onClick = getMousePos(canvas, evt);
// }, false);

 
// reset game when player catches packet
var reset = function () {
	// Throw the packet somewhere on the screen randomly
	packet.x = 32 + (Math.random() * (canvas.width - 64));
	packet.y = 32 + (Math.random() * (canvas.height - 64));
	
	load();
	TribeOP(text);
	console.log(TribeO2);

};

//Update game objects
var update = function(modifier) {
 
  //Did Clint catch the packet ?
  if (
    mousePos.x <= ( clientClint.x + 16)
    && packet.x <= (mousePos.x + 16)
    && mousePos.y <= ( clientClint.y + 16)
    && packet.y <= (mousePos.y + 16)
  ) {
    ++ packetsCaught;
    reset();
  }
};


// Load JSON
// https://laracasts.com/discuss/channels/general-discussion/load-json-file-from-javascript
function loadJSON(file, callback) {   

    var xobj = new XMLHttpRequest();
    xobj.overrideMimeType("application/json");
    xobj.open('GET', file, true); // Replace 'my_data' with the path to your file
    xobj.onreadystatechange = function () {
          if (xobj.readyState == 4 && xobj.status == "200") {
            // Required use of an anonymous callback as .open will NOT return a value but simply returns undefined in asynchronous mode
            callback(xobj.responseText);
          }
    };
    xobj.send(null);  
 }
 
// Load...stuff?
// https://laracasts.com/discuss/channels/general-discussion/load-json-file-from-javascript
function load() {
    
    loadJSON("http://gilgamech.com/ark/ARKMap.json", function(response) {
  
        var actual_JSON = JSON.parse(response);
		text = actual_JSON
        // console.log(actual_JSON);
		// actual_JSON
    }); // end loadJSON
    
}

function TribeOP(TribeText) {
// load()

// var TribeOutput = new Array();
// for (i = 0; i < TribeText.length; i++) { TribeOutput += TribeText[i].TribeName + ", " + TribeText[i].Lat + ", " + TribeText[i].Long + " \n"; } 
// for (i = 0; i < TribeText.length; i++) { 
// TribeOutput  += TribeText[i].Lat + ", " + TribeText[i].Long + " \n"; 
// } 
// TribeO2 = TribeOutput;
// console.log ( TribeOutput);
}    


//draw it all
var render = function () {
  if (bgReady) {
    ctx.drawImage(bgImage, 0, 0);
  }
  
  if (clientClintReady) {
    ctx.fillRect((mousePos.x-6), (mousePos.y-6), (5), (5));
    ctx.fillText("Cursor Location", (mousePos.x-6), (mousePos.y+16));

  }
    
  if (packetReady) {
//    ctx.drawImage(packetImage, packet.x, packet.y);
  }
 
  
  //score
  ctx.fillStyle = "rgb(250, 250, 250,)";
  ctx.font = "12px Helvetica";
  ctx.textAlign = "left";
  ctx.textBaseline = "top";
  // ctx.fillText("Base location: " + packetsCaught, 32, 32);

for (i = 0; i < text.length; i++) { 
// TribeOutput += TribeO2[i].Lat + ", " + TribeO2[i].Long + " \n"; 
TribeX = (text[i].Lat*6)
TribeY = (text[i].Long*6)

ctx.fillRect(TribeX,TribeY,5,5); 
ctx.fillText((text[i].TribeName), TribeX, TribeY+5);
}; 


};

// Get mouse position
function getMousePos(canvas, evt) {
  var rect = canvas.getBoundingClientRect();
  return {
    x: evt.clientX - rect.left,
    y: evt.clientY - rect.top
  };
}


// Game loop
var main = function () {
  var now = Date.now();
  var delta = now - then;
  
 
 update(delta/1000);
  render();
  
  then = now;
};

//Play!
reset();
var then = Date.now();
setInterval(main, 1); //run at top speed