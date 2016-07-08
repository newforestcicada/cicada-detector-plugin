/*
 * Cicada Hunt Detector Plugin
 * 
 * Created by Davide Zilli on 18/05/2016
 * Copyright (c) 2014 University of Southampton. All rights reserved.
 *
 * // usage:
 * Undoucumented
 *
 * // structure:
 * https://github.com/phonegap/phonegap-plugins/wiki/Defining-Your-Cordova-Plugin-As-A-Cordova-Module
 */
	
var exec = require("cordova/exec");
var CicadaDetectorPlugin = function() {};

// List of functions to expose
var fns = ['initialiseDetector', 'getAmplitude', 'getFrequencies', 'startDetector', 'startWhiteNoise', 'stopDetector', 'startWhiteNoise', 'startSurvey', 'getCicada'];

// Add functions for each of the plugin callbacks we want to expose
for(var i=0; i<fns.length; i++) {
	// Wrap in a closure so that we lock in the value of fnName
	(function() {
		var fnName = fns[i];

		CicadaDetectorPlugin.prototype[fnName] = function(win, fail) {
			win = win || function() {};
			fail = fail || function() {};
			
			var w = function(data) {
				setTimeout(function() {
					win(data);
				}, 10);
			};

			//console.log('CicadaDetector.'+fnName+'()');
			cordova.exec(w, fail, "CicadaDetector", fnName, [null]);
		};
	})();
}

CicadaDetectorPlugin.prototype.stopSurvey = function(width, height, win, fail) {
	win = win || function() {};
	fail = fail || function() {};
	
	// Android plugin falls over with null values for w/h
	width = width || 10;
	height = height || 10;

	//console.log('CicadaDetector.'+fnName+'()');
	cordova.exec(win, fail, "CicadaDetector", "stopSurvey", [width, height]);
}

CicadaDetectorPlugin.prototype.writeRecording = function(win, fail, seconds) {
	win = win || function() {};
	fail = fail || function() {};
	seconds = seconds || 60;

	//console.log('CicadaDetector.'+fnName+'()');
	cordova.exec(win, fail, "CicadaDetector", "writeRecording", [seconds]);
}

CicadaDetectorPlugin.prototype.getInsects = function(win, fail) {
	win = win || function() {};
	fail = fail || function() {};
	
	var w = function(data) {
		// Bug fix for iOS plugin sending the data as a serialized string
		if(typeof data == "string")
			data = JSON.parse(data) || [];
		
		if(!(data instanceof Array))
			data = [data];
		
		//console.log(JSON.stringify(data));
			
		// Hack to workaround the Cordova Plugin returning the wrong data structure
		// Ensure the data is in the correct format (check that insect id is 'insect' and not 'id' which is how the server expects it)
		if(data.length > 0 && data[0].id !== undefined) {
			//console.log("Cordova Plugin returned insects array with 'id' instead of 'insect'.");
			
			for(var i=0; i<data.length; i++) {
				data[i].insect = data[i].id;
				delete data[i].id;
			}
		}
		
		//console.log(JSON.stringify(data));
		
		win(data);
	};
	
	//console.log('CicadaDetector.'+fnName+'()');
	cordova.exec(w, fail, "CicadaDetector", "getInsects", [null]);
}

CicadaDetectorPlugin.prototype.setApplicationIconBadgeNumber = function(count, win, fail) {
	win = win || function() {};
	fail = fail || function() {};
	
	if(window.device.platform == 'Android') {
		setTimeout(function() {
			fail();
		}, 10);
		
		return;
	}
	
	cordova.exec(win, fail, "CicadaDetector", "setApplicationIconBadgeNumber", [count]);
}

var CicadaDetector = new CicadaDetectorPlugin();
module.exports = CicadaDetector;
