global.XMLHttpRequest = require('xhr2');
var Elm = require('./build/main-slack');
var midi = require('midi');
var midiHelpers = require('./lib/midiHelpers');
var slackToken = require('./config/slackToken');

var output = new midi.output();
var input = new midi.input();
if(midiHelpers.openPortByName('Launchpad', output) && midiHelpers.openPortByName('Launchpad', input)) {
  Elm.Main.embed({
    output: output,
    input: input,
  }, {
    slackToken: slackToken,
  });
  console.log('rendering Main program into Launchpad device');
}
