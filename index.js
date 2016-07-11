global.XMLHttpRequest = require('xhr2');
var Elm = require('./build/main');
var midi = require('midi');
var midiHelpers = require('./lib/midiHelpers');

var output = new midi.output();
var input = new midi.input();
if(midiHelpers.openPortByName('Launchpad', output) && midiHelpers.openPortByName('Launchpad', input)) {
  Elm.Main.embed({
    output: output,
    input: input,
  }, {
    slackToken: process.env.SLACK_TEST_TOKEN_ELM,
  });
  console.log('rendering Main program into Launchpad device');
}
