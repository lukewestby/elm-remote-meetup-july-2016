//import Native.Json //

var _user$project$Native_Launchpad = (function() {

function button(props) {
  return {
    type: 'button',
    props: props,
  };
}

function group(children) {
  return {
    type: 'group',
    children: children,
  };
}

function map(tagger, node) {
  return {
    type: 'tagger',
    tagger: tagger,
    node: node,
  };
}

function colorToBytes(color) {
  switch (color._0) {
    case 'low-red': return 0x0d;
    case 'red': return 0x0f;
    case 'low-amber': return 0x1d;
    case 'amber': return 0x3f;
    case 'yellow': return 0x3e;
    case 'low-green': return 0x1c;
    case 'green': return 0x3c;
    default: return 0x0c;
  }
}

function positionToBytes(row, col) {
  return (row << 4) | col;
}

function onToBytes(on) {
  return on ? 0x90 : 0x80;
}

function render(tagger, virtualNode, enqueueMidiSend, onMessages, offMessages) {
  switch (virtualNode.type) {
    case 'button':
      var button = virtualNode;
      var position = positionToBytes(button.props.row, button.props.column);
      var velocity = colorToBytes(button.props.color);
      var type = onToBytes(button.props.on);

      if (button.props.onButtonOn.ctor === 'Just') {
        onMessages[position] = function () { tagger(button.props.onButtonOn._0); };
      }

      if (button.props.onButtonOff.ctor === 'Just') {
        offMessages[position] = function () { tagger(button.props.onButtonOff._0); };
      }

      enqueueMidiSend(position, [type, position, velocity]);
      break;

    case 'group':
      var group = virtualNode;
      var currentChild = group.children;
      while (currentChild.ctor !== '[]') {
        render(tagger, currentChild._0, enqueueMidiSend, onMessages, offMessages);
        currentChild = currentChild._1;
      }
      break;

    case 'tagger':
      var mapper = virtualNode.tagger;
      function nextTagger (msg) { tagger(mapper(msg)); }
      render(nextTagger, virtualNode.node, enqueueMidiSend, onMessages, offMessages);
      break;
  }
}

function messageEqual(left, right) {
  if (!left || !right) return false;
  for (var i = left.length - 1; i >= 0; i--) {
    if (left[i] !== right[i]) return false;
  }
  return true;
}

function renderer(io, tagger, initialVirtualNode) {
  var onMessages = {};
  var offMessages = {};
  var midiMessages = {};
  var previousMidiMessages = {};
  var messagesToSend = [];
  var sendEnqueued = false;
  var firstBuffer = true;

  function enqueueMidiSend(position, message) {
    midiMessages[position] = message;
    if (!messageEqual(previousMidiMessages[position], message)) {
      messagesToSend.push(message);
    }

    if (sendEnqueued) return;
    sendEnqueued = true;
    setImmediate(function () {
      sendEnqueued = false;
      if (midiMessages.length === 0) return;
      io.output.sendMessage([176, 0, firstBuffer ? 49 : 52]);
      messagesToSend.forEach(function (message) {
        io.output.sendMessage(message);
      });
      io.output.sendMessage([176, 0, firstBuffer ? 52 : 49]);
      firstBuffer = !firstBuffer;
      previousMidiMessages = midiMessages;
      midiMessages = {};
      messagesToSend = [];
    })
  }

  io.output.sendMessage([176, 0, 0]);

  render(tagger, initialVirtualNode, enqueueMidiSend, onMessages, offMessages);

  io.input.on('message', function (deltaTime, message) {
    var position = message[1];
    var velocity = message[2];
    if (velocity === 127 && onMessages[position]) {
      onMessages[position]();
    } else if (velocity === 0 && offMessages[position]) {
      offMessages[position]();
    }
  });

  return {
    update: function (nextVirtualNode) {
      onMessages = {};
      offMessages = {};
      render(tagger, nextVirtualNode, enqueueMidiSend, onMessages, offMessages);
    }
  };
}

function programWithFlags(details) {
	return {
		init: details.init,
		update: details.update,
		subscriptions: details.subscriptions,
		view: details.view,
		renderer: renderer
	};
}

return {
  button: button,
  group: group,
  map: F2(map),
  programWithFlags: programWithFlags,
};

}());
