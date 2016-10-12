var net = require('net');

var stdin = process.openStdin();// read input from console

var HOST = '127.0.0.1';
var PORT = 6969;

var client = new net.Socket();

//////////////////////
// add a listener to listening console input event!
function input_listener(d) {
    // note:  d is an object, and when converted to a string it will
    // end with a linefeed.  so we (rather crudely) account for that  
    // with toString() and then trim() 
    console.log("you entered: [" + d.toString().trim() + "]");
	console.log("ready to disconnect..");
	client.destroy();
}

stdin.on("data", input_listener);
/////////////////////

client.connect(PORT, HOST, function() {

    console.log('CONNECTED TO: ' + HOST + ':' + PORT);
});

// Write a message to the socket as soon as the client is connected, the server will receive it as message from the client 
client.write('I am Chuck Norris!');
client.write('I am Chuck Jack!');

// Add a 'data' event handler for the client socket
// data is what the server sent to this socket
client.on('data', function(data) {
    
    console.log('DATA: ' + data);
    // Close the client socket completely
    //client.destroy();
    
});

// Add a 'close' event handler for the client socket
client.on('close', function() {
    console.log('Connection closed');
	stdin.removeListener("data", input_listener);
	stdin.destroy();
});
