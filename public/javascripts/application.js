// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


// from http://www.quirksmode.org/js/cross_dhtml.html
var DHTML = (document.getElementById || document.all || document.layers);

function getObj(name)
{
  if (document.getElementById)
  {
    this.obj = document.getElementById(name);
    this.style = document.getElementById(name).style;
  }
  else if (document.all)
  {
    this.obj = document.all[name];
    this.style = document.all[name].style;
  }
  else if (document.layers)
  {
    this.obj = document.layers[name];
    this.style = document.layers[name];
  }
}

function invi(element,flag)
{
  if (!DHTML) return;
  var x = new getObj(element);
  x.style.visibility = (flag) ? 'hidden' : 'visible'
}

function scrollToContestEditWindow() {
if(Position.page($('contest-edit-window'))[1] < 0) {
    $('contest-edit-window').scrollTo();
  }
}
