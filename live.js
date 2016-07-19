var Elm = require('./build/main-live');
var midi = require('midi');
var midiHelpers = require('./lib/midiHelpers');

var output = new midi.output();
var input = new midi.input();
if (
  midiHelpers.openPortByName('Launchpad', output) &&
  midiHelpers.openPortByName('Launchpad', input)
) {
  Elm.Main.embed({
    output: output,
    input: input,
  });
  console.log('rendering Main program into Launchpad device');
}
