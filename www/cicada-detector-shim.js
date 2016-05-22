/**
 * Shim class to mimic the API presented by the Native plugin when running in Chrome
 */

console.warn("Using the Codova Shim, don't include this file in production code!!");

window.device = {
	name: 'Test Environment',
	platform: 'Desktop',
	cordova: 'shim',
	uuid: 'ignore-me',
	version: '1.0',
	model: ''
};

window.CicadaDetector = (function() {
	var detector = function() {

	};

	// List of functions to expose
	//var fns = ['initialiseDetector', 'getAmplitude', 'getFrequencies', 'startDetector', 'startWhiteNoise', 'stopDetector', 'startWhiteNoise', 'startSurvey', 'getCicada'];
	var fns = ['initialiseDetector', 'startDetector', 'startWhiteNoise', 'startSurvey', 'stopDetector'];

	// Add functions for each of the plugin methods that are just fire and forget
	for(var i=0; i<fns.length; i++) {
		// Wrap in a closure so that we lock in the value of fnName
		(function() {
			var fnName = fns[i];

			detector.prototype[fnName] = function(win, fail) {
				win = win || function() {};
				fail = fail || function() {};

				setTimeout(function() {
					win();
				}, 10);
			};
		})();
	}
	
	detector.prototype.getFrequencies = function(win, fail) {
		win = win || function() {};
		fail = fail || function() {};
		
		var d = [];
		
		for(var i=0; i<20; i++) {
			d.push(Math.random())
			//d.push(0.5)
		}
		
		setTimeout(function() {
			win(d);
		}, 10);
	};
	
	detector.prototype.getCicada = function(win, fail) {
		win = win || function() {};
		fail = fail || function() {};
		
		setTimeout(function() {
			win(Math.random());
		}, 10);
	};
	
	detector.prototype.writeRecording = function(win, fail, seconds) {
		win = win || function() {};
		fail = fail || function() {};
		seconds = seconds || 60;

		setTimeout(function() {
			win();
		}, 10);
	};
	
	var createInsectArray = function() {
		return [{
			value: Math.random(),
			insect: RL.INSECTS.kCICADA,
			name: 'New Forest Cicada'
		},
		{
			value: Math.random(),
			insect: RL.INSECTS.kFIELDGRASSHOPPER,
			name: 'Common Grasshopper'
		},
		{
			value: Math.random(),
			insect: RL.INSECTS.kDARKBUSHCRICKET,
			name: 'Bush Cricket'
		},
		{
			value: Math.random(),
			insect: RL.INSECTS.kROESELSBUSHCRICKET,
			name: 'Rosel Bush Cricket'
		},
		{
			value: Math.random(),
			insect: RL.INSECTS.kWOODCRICKET,
			name: 'Wood Cricket'
		}];
	};
	
	detector.prototype.stopSurvey = function(width, height, win, fail) {
		win = win || function() {};
		fail = fail || function() {};
		
		var data = {
			"insects": createInsectArray(),
		    keep_recording: true,
		    message: Math.floor(Math.random()*3), // in the range 0-2
			sonogram: 'img/cicada-sonogram.png'
		};
		
		$(data.insects).each(function(i, insect) {
			insect.found = (insect.value > 0.5);
		});
		
		setTimeout(function() {
			win(data);
		}, 10);
	};

	detector.prototype.getInsects = function(win, fail) {
		win = win || function() {};
		fail = fail || function() {};
		
		var insects = createInsectArray();
		
		$(insects).each(function(i, insect) {
			insect.found = insect.value > 0.5;
		});

		setTimeout(function() {
			win(insects);
		}, 10);
	};
	
	detector.prototype.setApplicationIconBadgeNumber = function(count, win, fail) {
		win = win || function() {};
		fail = fail || function() {};
		
		setTimeout(function() {
			win();
		}, 10);
	};
	
	navigator.notification = function(msec) {}
	navigator.notification.vibrate = function(msec) {}

	var d = new detector();
	d.isShim = true;
	
	return d;
})();