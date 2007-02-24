
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
    var element = _gel(lines[i]+".status");
    element.innerHTML = "Checking...";
    element.ts_index = i;
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
      element.ts_message = message;
      if (time) {
        element.ts_message += ' (' + time + ')';
      }
      element.ts_name = name;
      element.ts_status = status;
      if (element.ts_message) {        
        if(element.addEventListener) {//DOM
          element.addEventListener("mouseover", showMessage, false);
          element.addEventListener("mouseout", hideMessage, false);
        } else if (element.attachEvent) {//IE
          element.attachEvent("onmouseover", showMessage);
          element.attachEvent("onmouseout", hideMessage);
        }
      }
    }
  }
}

function showMessage (e) {
  var msg =  _gel(msgWindow);
  var element = e.currentTarget || e.srcElement;
  msg.innerHTML = element.ts_message;
  msg.style.display = "block";
  if (element.ts_index > 5) {
    msg.style.top = e.clientY - (msg.offsetHeight + 10);
  } else {
    msg.style.top = e.clientY + 15;
  }
}

function hideMessage () {
  var msg = _gel(msgWindow);
  msg.style.display = "none"
}

function getData() {
  _IG_FetchContent(dataUrl, parseData);
}