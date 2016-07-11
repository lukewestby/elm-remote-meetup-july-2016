function enumeratePortNames(device) {
  var count = device.getPortCount();
  var output = [];
  for(var i = count - 1; i >= 0; i--) {
    output.unshift(device.getPortName(i));
  }
  return output;
}

function openPortByName(name, device) {
  var count = device.getPortCount();
  for(var i = count - 1; i >= 0; i--) {
    if(device.getPortName(i) === name) {
      device.openPort(i);
      return true;
    }
  }
  return false;
}

module.exports = {
  enumeratePortNames,
  openPortByName,
};
