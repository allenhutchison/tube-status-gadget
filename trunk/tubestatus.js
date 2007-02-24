
/* This code is based on the Mac OS X London Tube Widget found at http://bremford.org/widgets/tube/index.html
Thanks to the author for allowing me to port his code to a google gadget.
*/

var dataUrl = "http://bremford.org/widgets/tube/tube.xml?rand=" + (new Date().getTime());
var lines = [ "bakerloo", "central", "circle", "district", "eastlondon", "hammersmithandcity", "jubilee", "metropolitan", "northern", "piccadilly", "victoria", "waterlooandcity" ];

function xmlError (e) {
  alert(e);
}

function parseData(root) {
  var objDom = new XMLDoc(root, xmlError);

  for (var i=0;i<lines.length;i++) {
    _gel(lines[i]+".status").innerHTML = "Checking...";
  }

  var reslines = objDom.docNode.getElements("line");

  for (var i=0; i<reslines.length; i++) {
    var name = reslines[i].getAttribute("name");
    var status = reslines[i].getAttribute("status");
    var message = reslines[i].getText()
    var time = reslines[i].getAttribute("time");

    if (_gel(name+".status")!=null) {
      var element = _gel(name+".status");
      if (status.toLowerCase()=="severe delays") {
        status = "<span class='severe'>"+status+"</span>";
      } else if (status.indexOf("suspended")>=0) {
        status = "<span class='suspended'>"+status+"</span>";
      } else if (status.toLowerCase()=="minor delays") {
        status = "<span class='minor'>"+status+"</span>";
      }
      element.innerHTML = status;
      if (message) {
        if (time) {
          message = message + ' (' + time + ')';
        }
        element.onmouseover = new Function('showMessage("' + message + '")');
        element.onmouseout = new Function('hideMessage()');
      }
    }
  }
}

function showMessage (text) {
  var msg =  _gel(msgWindow);
  var lft = findPos(msg);
  alert(lft);
  msg.innerHTML = text;
  msg.style.display = "block";
//      msg.style.top = event.y+30;
}

function hideMessage () {
  var msg = _gel(msgWindow);
  msg.style.display = "none"
}

function findPos(obj) {
	var curleft = curtop = 0;
	if (obj.offsetParent) {
		curleft = obj.offsetLeft
		curtop = obj.offsetTop
		while (obj = obj.offsetParent) {
			curleft += obj.offsetLeft
			curtop += obj.offsetTop
		}
	}
	return [curleft,curtop];
}

function getData() {
  _IG_FetchContent(dataUrl, parseData);
}