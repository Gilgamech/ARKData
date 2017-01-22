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
bgImage.src = "http://gilgamech.com/ark/TheCenter_Pencil.jpg";

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
var ARKMapJSON = "";
var TribeJSON = ""
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
	
	loadARKMap();

};

var update = function(modifier) {
 
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
function loadARKMap() {
    
    loadJSON("http://gilgamech.com/ark/ARKMap.json", function(response) {
  
        var actual_JSON = JSON.parse(response);
		ARKMapJSON = actual_JSON
    }); // end loadJSON
    
}

function loadTribes() {
    
    loadJSON("http://gilgamech.com/ark/tribe.json", function(response) {
  
        var actual_JSON = JSON.parse(response);
		TribeJSON = actual_JSON
    }); // end loadJSON
    
}


//draw it all
var render = function () {
  if (bgReady) {
    ctx.drawImage(bgImage, 0, 0);
  }
    
  ctx.textBaseline = "top";
for (i = 0; i < ARKMapJSON.length; i++) { 
	// Set up X, Y and Tribe name.
	TribeX = (ARKMapJSON[i].Long * Math.round((canvas.width/100))* 10 ) / 10;
	TribeY = (ARKMapJSON[i].Lat * Math.round((canvas.height/100))* 10 ) / 10;
	TribeName = (ARKMapJSON[i].TribeName)
	Type = (ARKMapJSON[i].Type)
	Comments = (ARKMapJSON[i].Comments)
	
	// Draw up box behind name
	ctx.fillStyle="#aabdb7";
    ctx.font = "10px Helvetica";
	
	// Draw text
    ctx.fillStyle = "#000000";
	ctx.fillRect(TribeX,TribeY,5,5); 
	ctx.fillRect(TribeX,TribeY,(ctx.measureText(TribeName).width), (ctx.measureText(TribeName).height)); 
	ctx.textAlign = "left";
	ctx.fillText((ARKMapJSON[i].TribeName), TribeX, TribeY+5);
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