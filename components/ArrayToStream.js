const noflo = require('noflo');

exports.getComponent = function() {
  const c = new noflo.Component({
    description: 'Convert input array to a NoFlo stream',
    inPorts: {
      in: {
        datatype: 'array',
        description: 'data we want to send',
        required: true
      }
    },
    outPorts: {
      out: {
        datatype: 'string',
        description: 'the data wrapped in brackets',
        required: true
      }
    }
  });

  c.process((input, output) => {
    if (!input.hasData('in')) { return; }

    output.send({out: new noflo.IP('openBracket')});

    let datas = input.getData('in');
    if (!Array.isArray(datas)) {
      datas = [datas];
    }
    datas.forEach((data) => {
      output.send({out: new noflo.IP('data', data)});
    });

    output.send({out: new noflo.IP('closeBracket')});
    output.done();
  });

  return c;
};
