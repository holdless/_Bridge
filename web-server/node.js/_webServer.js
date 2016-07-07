var net = require('net');
var webServer = require('http');
var fs = require('fs');
var url = require('url');

var port = 8088;
var formatTag = "text/html";
var filePath = "";
var msgType = 0;
var showDir = 0;
// for authentication procedure state

// Create a server
webServer.createServer( function (request, response) {  
    // Parse the request containing file name
    var fileName = url.parse(request.url).pathname;
	// Parse the request whole message
    var msg = request.url;
	console.log(msg);
    console.log(fileName);
	
	// show remote client's IP address
	//console.log(request.headers['x-forwarded-for']);
	//console.log(request.connection.remoteAddress);
	//console.log(request.socket.remoteAddress);
////	console.log(request.connection.socket.remoteAddress);
	
	// authentication control
	if (msg.endsWith('a.html') || (msg.endsWith('kelia.jpg') || (msg.endsWith('moniz.jpg')))) {
	    filePath = "";
		formatTag = "text/html";
		msgType = 0; // normal
		fileName = "/b.html";
	}
    // handles various request from client
    else if (msg.endsWith(".html")) {
	    filePath = "";
		formatTag = "text/html";
		msgType = 0; // normal
    } else if (msg.endsWith(".ico")) {
		filePath = "/icons/";
        formatTag = "icon/ico";
		msgType = 1; // image
    } else if (msg.endsWith(".jpg")) {
        filePath = "/images/";
        formatTag = "image/jpeg";
		msgType = 1; // image
    } else if (msg.endsWith(".gif")) {
        filePath = "/images/";
        formatTag = "image/gif";
		msgType = 1; // image
    } else if (msg.endsWith(".png")) {
        filePath = "/images/";
        formatTag = "image/png";
		msgType = 1; // image
    } 
	// remote control instruction
	///// 628.4.0707 temp
/*	else if (msg.endsWith("left=")) {
			msgType = 0;
			filePath = "";
			formatTag = "text/html";
			msgType = 0; // normal
			fileName = "/a.html";
	}/////////////*/
    else if (msg.startsWith("/myCmd")) {
		msgType = 2; // cmd
        filePath = "";
        formatTag = "text/html";
		if (msg.endsWith("up")) {
			showDir = 1;
		} else if (msg.endsWith("down")) {
			showDir = 2;
		} else if (msg.endsWith("right")) {
			showDir = 3
		} else if (msg.endsWith("left")) {
			showDir = 4;
		} else {
			showDir = 0;
			console.log("wrong dir cmd!!"); // this shows on srv side only
		}
    } 
	// server-sent events
    else if (msg.endsWith("srvSent")) {
        filePath = "";
        formatTag = "srvSent";
		msgType = 3; // srvSent
    }
	// authentication handler
	else if (msg.indexOf("?username") > -1)
	{
		if (msg.endsWith("?username=jack&password=hiroshi"))
		{
			msgType = 0;
			filePath = "";
			formatTag = "text/html";
			msgType = 0; // normal
			fileName = "/a.html";
		}
		else {
			filePath = "";
			formatTag = "text/html";
			msgType = 0; // normal
			fileName = "/b.html";
			
		}
		console.log("!!")
	}
	else
	{
		console.log("no....");
		msgType = -1;
	}
	   
		
	pathname = filePath + fileName;
   
    // Print the name of the file for which request is made.
    console.log("Request for " + pathname + " received.");


	// 'GET/POST' response to client
	if (msgType == 3)
	{
        response.writeHead(200, {
			'Content-Type': 'text/event-stream',
			'Cache-Control': 'no-cache',
			'Connection': 'keep-alive'
		});	
		
		setInterval(function() {
			var labels = ['message', 'cmdUp'];
			var srvData = [new Date().getTime(), showDir];
			for (var i = 0; i < labels.length; i++)
			{
				response.write('event: ' + labels[i] + '\n');
				response.write('data: ' + srvData[i] + '\n\n');
			}
		}, 1000);
//		response.end(); // if setInterval used, no need to response.end()! 
	}   
	else if (msgType == 0 || msgType == 1)
	{
		// Read the requested file content from file system
		fs.readFile(pathname.substr(1), function (err, data) {
			if (err) 
			{
				console.log(err);
				// HTTP Status: 404 : NOT FOUND
				// Content Type: text/plain
				response.writeHead(404, {'Content-Type': 'text/html'});
			}
			else
			{		
				if (msgType == 0)
				{
					//html found	  
					// HTTP Status: 200 : OK
					// Content Type: text/html
					response.writeHead(200, {'Content-Type': formatTag});	
         
					// Write the content of the file to response body
					response.write(data.toString());
				}
				else if (msgType == 1)
				{
					//image found	  
					// HTTP Status: 200 : OK
					// Content Type: image/*
					response.writeHead(200, {'Content-Type': formatTag});	         
					// Write the content of the file to response body
					response.write(data);
				}
			}
			// Send the response body 
			response.end();
		}); 
	}   
}).listen(port);

// Console will print the message
console.log('Server running at http://127.0.0.1:',port);
