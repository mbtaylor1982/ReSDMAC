// http://wiki.tcl.tk/20339 tcl.js 0.4
/*==================================================== -*- C++ -*-
* tcl.js "A Tcl implementation in Javascript"
*
* Released under the same terms as Tcl itself.
* (BSD license found at <http://www.tcl.tk/software/tcltk/license.html>)
*
* Based on Picol by Salvatore Sanfilippo (<http://antirez.com/page/picol>)
* (c) Stéphane Arnold 2007
* Richard Suchenwirth 2007: cleanup, additions
* vim: syntax=javascript autoindent softtabwidth=4
*/
_step = 0 // set to 1 for debugging

function TclInterp () {
 this.callframe = new Array(new Object());
 this.level     = 0;
 this.commands  = new Object();
 this.procs     = new Array();
 this.OK  = 0;
 this.RET = 1;
 this.BRK = 2;
 this.CNT = 3;
 this.getVar = function(name) {
   var nm = name.toString();
   if (nm.match("^::")) {
     var val = this.callframe[0][nm.substr(2)];
   } else {
     var val = this.callframe[this.level][name];
   }
   if (val == null) throw "No such variable: "+name;
   return val;
 }
 this.setVar = function(name, val) {
   var nm = name.toString();
   if (nm.match("^::")) {
     this.callframe[0][nm.substr(2)] = val;
   } else {
     this.callframe[this.level][name] = val;
   }
   return val;
 }
 this.incrLevel = function() {
   this.callframe[++this.level] = new Object();
   return this.level;
 }
 this.decrLevel = function() {
   this.callframe[this.level] = null;
   this.level--;
   if (this.level<0) throw "Exit application";
   this.result = null;
 }
 this.getCommand = function(name) {
   try {
     return this.commands[name];
   } catch (e) {throw "No such command '"+name+"'";}
 }
 this.registerCommand = function(name, func, privdata) {
   if (func == null) throw "No such function: "+name;
   this.commands[name] = new TclCommand(func, privdata);
 }
 this.renameCommand = function (name, newname) {
   this.commands[newname] = this.commands[name];
   if (this.procs[name]) {
     this.procs[name] = null;
     this.procs[newname] = true;
   }
   this.commands[name] = null;
 }
 this.registerSubCommand = function(name, subcmd, func, privdata) {
   if (func == null) throw "No such subcommand: "+ name +" " + subcmd;
   var path = name.split(" ");
   var ens;
   name = path.shift();
   var cmd = this.commands[name];
   if (cmd == null) {
     ens = new Object();
     ens["subcommands"]  = new TclCommand(Tcl.InfoSubcommands, null);
     this.commands[name] = new TclCommand(Tcl.EnsembleCommand, null, ens);
   }
   ens = this.commands[name].ensemble;
   if (ens == null) throw "Not an ensemble command: '"+name+"'";
   // walks deeply into the subcommands tree
   while (path.length > 0) {
     name = path.shift();
     cmd = ens[name];
     if (cmd == null) {
       cmd = new TclCommand(Tcl.EnsembleCommand, null, new Object());
       ens[name] = cmd;
       ens = cmd.ensemble;
       ens["subcommands"] = new TclCommand(Tcl.InfoSubcommands, null);
     }
   }
   ens[subcmd] = new TclCommand(func, privdata);
 }
 this.eval = function (code) {
   try {
     return this.eval2(code);
   } catch (e) {
     if(!confirm(e+"/" + e.description +
                       "\nwhile evaluating "+code.substr(0,128)+"..."))
       throw(e);
   }
 }
 this.eval2 = function(code) {
   this.code = this.OK;
   var parser = new TclParser(code);
   var args = new Array(0);
   var first = true;
   var text, prevtype, result;
   result = "";
   while (true) {
     prevtype = parser.type;
     try {
       parser.getToken();
     } catch (e) {break;}
     if (parser.type == (parser.EOF)) break;
     text = parser.getText();
     if (parser.type == (parser.VAR)) {
       try {
         text = this.getVar(text);
       } catch (e) {throw "No such variable '" + text + "'";}
     } else if (parser.type == (parser.CMD)) {
       try {
         text = this.eval2(text);
       } catch (e) {throw (e + "\nwhile parsing \"" + text + "\"");}
     } else if (parser.type == (parser.ESC)) {
       // escape handling missing!
     } else if (parser.type == (parser.SEP)) {
       prevtype = parser.type;
       continue;
     }
     text = this.objectify(text);
     if (parser.type ==parser.EOL || parser.type == parser.EOF) {
       prevtype = parser.type;
       if (args.length > 0) {
         result = this.call(args);
         if (this.code != this.OK) return this.objectify(result);
       }
       args = new Array();
       continue;
     }
     if (prevtype == parser.SEP || prevtype == parser.EOL) {
       args.push(text);
     } else {
       args[args.length-1] = args[args.length-1].toString() + text.toString();
     }
   }
   if (args.length > 0) result = this.call(args);
   return this.objectify(result);
 }
 //---------------------------------- Commands in alphabetical order
 this.registerCommand("and", function (interp, args) {
   this.requireExactArgc(args, 3);
   var a = interp.objectify(args[1]).toBoolean();
   var b = interp.objectify(args[2]).toBoolean();
   return (a && b);
 });
 this.registerCommand("append", function (interp, args) {
   this.requireMinArgc(args, 2);
   var vname = args[1].toString();
   if (interp.callframe[interp.level][vname] != null) {
     var str = interp.getVar(vname);
   } else var str = "";
   for (var i = 2; i < args.length; i++) str += args[i].toString();
   interp.setVar(vname, str);
   return str;
 });
 this.registerCommand("break", function (interp, args) {
   interp.code = interp.BRK;
   return;
 });
 this.registerCommand("continue", function (interp, args) {
   interp.code = interp.CNT;
   return;
 });
 this.registerSubCommand("clock", "format", function (interp, args) {
   var now = new Date();
   now.setTime(args[1]);
   return now.toString();
 });
 this.registerSubCommand("clock", "scan", function (interp, args) {
   return Date.parse(args[1]);
  });
 this.registerSubCommand("clock", "seconds", function (interp, args) {
   return (new Date()).valueOf();
 });
 if(typeof(jQuery) != 'undefined') {
   this.registerCommand("dom", function (interp, args) {
     var selector = args[1].toString();
     var fn = args[2].toString();
     args = args.slice(3);
     for (var i in args) args[i] = args[i].toString();
     var q = $(selector);
     q[fn].apply(q,args);
     return "dom  " + selector;
   });
 }
 this.registerCommand("eval",function (interp, args) {
   this.requireMinArgc(args, 2);
   for (var i = 1; i < args.length; i++) args[i] = args[i].toString();
   if (args.length == 2) var code = args[1];
   else                  var code = args.slice(1).join(" ");
   return interp.eval(code);
 });
 sqrt = Math.sqrt; // "publish" other Math.* functions as needed
 this.registerCommand("expr", function (interp, args) {
   return eval(args[1].toString());
 });
 this.registerCommand("for", function (interp, args) {
   this.requireExactArgc(args, 5);
   interp.eval(args[1].toString());
   if(interp.code != interp.OK) return;
   var cond = "set _ "+args[2].toString();
   var step = args[3].toString();
   var body = args[4].toString();
   interp.inLoop = true;
   interp.code = interp.OK;
   while (true) {
     test = interp.objectify(interp.eval(cond));
     if (!test.toBoolean()) break;
     interp.eval(body);
     var ic = interp.code; // tested after step command
     interp.eval(step);
     if(ic == interp.BRK) break;
     if(ic == interp.CNT) continue;
   }
   interp.inLoop = false;
   if(interp.code == interp.BRK || interp.code == interp.CNT)
     interp.code=interp.OK;
   return "";
 });
 this.registerCommand("foreach", function (interp, args) {
   this.requireExactArgc(args, 4);
   var list = args[2].toList();
   var body = args[3].toString();
   var res  = "";
   interp.inLoop = true;
   interp.code = interp.OK;
   for(i in list) {
      interp.setVar(args[1],interp.objectify(list[i]));
      interp.eval(body);
      if(interp.code == interp.BRK) break;
      if(interp.code == interp.CNT) continue;
   }
   interp.inLoop = false;
   if(interp.code == interp.BRK || interp.code == interp.CNT)
     interp.code=interp.OK;
   return "";
 });
 this.registerCommand("gets", function (interp, args) {
   this.requireArgcRange(args, 2, 3);
   var reply = prompt(args[1],"");
   if(args[2] != null) {
     interp.setVar(args[2],interp.objectify(reply));
     return reply.length;
   } else return reply;
 });
 this.registerCommand("if", function (interp, args) {
   this.requireMinArgc(args, 3);
   var test = interp.objectify(interp.eval("set _ "+args[1].toString()));
   if (test.toBoolean()) return interp.eval(args[2].toString());
   if (args.length == 3) return;
   for (var i = 3; i < args.length; ) {
     switch (args[i].toString()) {
     case "else":
       this.requireExactArgc(args, i + 2);
       return interp.eval(args[i+1].toString());
     case "elseif":
       this.requireMinArgc(args, i + 3);
       test = interp.objectify(interp.eval("set _ "+args[i+1].toString()));
       if (test.toBoolean())
         return interp.eval(args[i+2].toString());
       i += 3;
       break;
     default:
       throw "Expected 'else' or 'elseif', got "+ args[i];
     }
   }
 });
 this.registerCommand("incr", function (interp, args) {
   this.requireArgcRange(args, 2, 3);
   var name = args[1];
   if (args.length == 2) var incr = 1;
   else var incr = interp.objectify(args[2]).toInteger();
   incr += interp.getVar(name).toInteger();
   return interp.setVar(name, new TclObject(incr, "INTEGER"));
 });
 this.registerSubCommand("info", "body", function (interp, args) {
   this.requireExactArgc(args, 2);
   var name = args[1].toString();
   if (!interp.procs[name]) throw "Not a procedure: "+name;
   return interp.getCommand(name).privdata[1];
 });
 this.registerSubCommand("info", "commands", function (interp, args) {
   return interp.mkList(interp.commands);
 });
 this.registerSubCommand("info", "globals", function (interp, args) {
   return interp.mkList(interp.callframe[0]);
 });
 this.registerSubCommand("info", "isensemble", function (interp, args) {
   this.requireExactArgc(args, 2);
   var name = args[1].toString();
   return (interp.getCommand(name).ensemble != null);
 });
 this.registerSubCommand("info", "procs", function (interp, args) {
   return interp.mkList(interp.procs);
 });
 this.registerSubCommand("info", "vars", function (interp, args) {
   return interp.mkList(interp.callframe[interp.level]);
 });
 this.registerCommand("jseval", function (interp, args) {
   return eval(args[1].toString());
 });
 this.registerCommand("lappend", function (interp, args) {
   this.requireMinArgc(args, 2);
   var vname = args[1].toString();
   if (interp.callframe[interp.level][vname] != null) {
     var list = interp.getVar(vname);
   } else var list = new TclObject([]);
   list.toList();
   for (var i = 2; i < args.length; i++) {
     list.content.push(interp.objectify(args[i]));
   }
   interp.setVar(vname, list);
   return list;
 });
 this.registerCommand("lindex", function (interp, args) {
   this.requireMinArgc(args, 3);
   var list = interp.objectify(args[1]);
   for (var i = 2; i < args.length; i++) {
     try {
       var index = list.listIndex(args[i]);
     } catch (e) {
       if (e == "Index out of bounds") return "";
       throw e;
     }
     list = list.content[index];
   }
   return interp.objectify(list);
 });
 this.registerCommand("list", function (interp, args) {
   args.shift();
   return new TclObject(args);
 });
 this.registerCommand("llength", function (interp, args) {
   this.requireExactArgc(args, 2);
   return args[1].toList().length;
 });
 this.registerCommand("lrange", function (interp, args) {
   this.requireExactArgc(args, 4);
   var list  = interp.objectify(args[1]);
   var start = list.listIndex(args[2]);
   var end   = list.listIndex(args[3])+1;
   try {
     return list.content.slice(start, end);
   } catch (e) {return new Array();}
 });
 this.registerCommand("lset", function (interp, args) {
   this.requireMinArgc(args, 4);
   var list = interp.getVar(args[1].toString());
   var elt = list;
   for (var i = 2; i < args.length-2; i++) {
     elt.toList();
     elt = interp.objectify(elt.content[elt.listIndex(args[i])]);
   }
   elt.toList();
   i = args.length - 2;
   elt.content[elt.listIndex(args[i])] = interp.objectify(args[i+1]);
   return list;
 });
 this.registerCommand("lsort", function (interp, args) {
   this.requireExactArgc(args, 2);
   return args[1].toList().sort();
 });
 this.registerCommand("not", function (interp, args) {
   this.requireExactArgc(args, 2);
   return !(interp.objectify(args[1]).toBoolean());
 });
 this.registerCommand("or", function (interp, args) {
   this.requireExactArgc(args, 3);
   var a = interp.objectify(args[1]).toBoolean();
   var b = interp.objectify(args[2]).toBoolean();
   return (a || b);
 });
 this.registerCommand("puts", function (interp, args) {
   this.requireExactArgc(args, 2);
   alert(args[1]);
 });
 this.registerCommand("proc", function (interp, args) {
   this.requireExactArgc(args, 4);
   var name = args[1].toString();
   var argl = interp.parseList(args[2]);
   var body = args[3].toString();
   var priv = new Array(argl,body);
   interp.commands[name] = new TclCommand(Tcl.Proc, priv);
   interp.procs[name] = true;
 });
 this.registerCommand("regexp", function (interp, args) {
   this.requireExactArgc(args, 3);
   var re = new RegExp(args[1].toString());
   var str = args[2].toString();
   return (str.search(re) > -1);
 });
 this.registerCommand("rename", function (interp, args) {
   this.requireExactArgc(args, 3);
   interp.renameCommand(args[1], args[2]);
 });
 this.registerCommand("return", function (interp, args) {
   this.requireArgcRange(args, 1, 2);
   var r = args[1];
   interp.code = interp.RET;
   return r;
 });
 this.registerCommand("set", function (interp, args) {
   this.requireArgcRange(args, 2, 3);
   var name = args[1];
   if (args.length == 3) interp.setVar(name, args[2]);
   return interp.getVar(name);
 });
 this.registerCommand("source", function (interp, args) {
   this.requireExactArgc(args, 2);
   return Tcl.Source(interp, args[1]);
 });
 this.registerSubCommand("string", "equal", function (interp, args) {
   this.requireExactArgc(args, 3);
   return (args[1].toString() == args[2].toString());
 });
 this.registerSubCommand("string", "index", function (interp, args) {
   this.requireExactArgc(args, 3);
   var s = args[1].toString();
   try {
     return s.charAt(args[1].stringIndex(args[2]));
   } catch (e) {return "";}
 });
 this.registerSubCommand("string", "range", function (interp, args) {
   this.requireExactArgc(args, 4);
   var s = args[1];
   try {
     var b = s.stringIndex(args[2].toString());
     var e = s.stringIndex(args[3].toString());
     if (b > e) return "";
     return s.toString().substring(b, e + 1);
   } catch (e) {return "";}
 });
 function sec_msec () {
   var t = new Date();
   return t.getSeconds()*1000 + t.getMilliseconds();
 }
 this.registerCommand("time", function (interp, args) {
   this.requireArgcRange(args, 2, 3);
   if (args.length == 3) var n = args[2]; else var n = 1;
   var t0 = sec_msec();
   for(var i = 0; i < n; i++) interp.eval(args[1].toString());
   return (sec_msec()-t0)*1000/n + " microseconds per iteration";
 });
 this.registerCommand("unset", function (interp, args) {
   this.requireExactArgc(args, 2);
   interp.setVar(args[1], null);
 });
 this.registerCommand("while", function (interp, args) {
   this.requireExactArgc(args, 3);
   var cond = "set _ "+args[1].toString();
   var body = args[2].toString();
   var res  = "";
   interp.inLoop = true;
   interp.code = interp.OK;
   while (true) {
     test = interp.objectify(interp.eval(cond));
     if (!test.toBoolean()) break;
     res = interp.eval(body);
     if(interp.code == interp.CNT) continue;
     if(interp.code != interp.OK)  break;
   }
   interp.inLoop = false;
   if(interp.code == interp.BRK || interp.code == interp.CNT)
     interp.code=interp.OK;
   return interp.objectify(res);
 });
 // native cmdname {function(interp, args) {...}}
 this.registerCommand("native", function (interp, args) {
   this.requireExactArgc(args, 3);
   var cmd = args[1].toList();
   var func = eval(args[2].toString());
   //alert("in: "+args[2].toString()+", func: "+ func);
   if (cmd.length == 1) {
     interp.registerCommand(cmd[0].toString(), func);
     return;
   }
   base = cmd[0].toString();
   cmd.shift();
   interp.registerSubCommand(base, cmd.join(" "), eval(args[2].toString()));
   return;
 });
 this.math = function (name, a, b) {
   switch (name) {
     case "+": return a + b;
     case "-": return a - b;
     case "*": return a * b;
     case "/": return a / b;
     case "%": return a % b;
     case "<": return a < b;
     case ">": return a > b;
     case "=": case "==": return a == b;
     case "!=": return a != b;
     default: throw "Unknown operator: '"+name+"'";
   }
 }
 var ops = ["+","-","*","/","%","<",">","=","==","!="];
 for (i in ops)
   this.registerCommand(ops[i],function (interp, args) {
     this.requireExactArgc(args, 3);
     var name = args[0].toString();
     var a = interp.objectify(args[1]);
     var b = interp.objectify(args[2]);
     var x = a.getNumber();
     var y = b.getNumber();
     if (a.isInteger() && b.isInteger())
       return new TclObject(interp.math(name, x, y),"INTEGER");
     if (a.isReal() && b.isReal())
       return new TclObject(interp.math(name, x, y),"REAL");
     return new TclObject(interp.math(name, x, y).toString());
   });
 this.mkList = function(x) {
   var list = new Array();
   for (var name in x) {list.push(name);}
   return list;
 }
 this.objectify = function (text) {
   if (text == null) text = "";
   else if (text instanceof TclObject) return text;
   return new TclObject(text);
 }
 this.parseString = function (text) {
   text = text.toString();
   switch (text.charAt(0)+text.substr(text.length-1)) {
   case "{}":
   case "\"\"":
     text = text.substr(1,text.length-2);
     break;
   }
   return this.objectify(text);
 }
 this.parseList = function (text) {
   text = text.toString();
   switch (text.charAt(0)+text.substr(text.length-1)) {
   case "{}":
   case "\"\"":
     text = new Array(text);
     break;
   }
   return this.objectify(text);
 }
 this.call = function(args) {
   if(_step && !confirm("this.call "+args)) throw "user abort";
   var func = this.getCommand(args[0].toString());
   var r = func.call(this,args);
   switch (this.code) {
   case this.OK:
   case this.RET:
     return r;
   case this.BRK:
     if (!this.inLoop) throw "Invoked break outside of a loop";
     break;
   case this.CNT:
     if (!this.inLoop) throw "Invoked continue outside of a loop";
     break;
   default:
     throw "Unknown return code " + this.code;
   }
   return r;
 }
 if(typeof(jQuery) != 'undefined') {
   this.eval('proc puts s {dom body appendTo \"<div style=\'font-family:Courier\'>$s</div>\";list}');
 }
}
var Tcl = new Object();
Tcl.isReal     = new RegExp("^[+\\-]?[0-9]+\\.[0-9]*([eE][+\\-]?[0-9]+)?$");
Tcl.isDecimal  = new RegExp("^[+\\-]?[1-9][0-9]*$");
Tcl.isHex      = new RegExp("^0x[0-9a-fA-F]+$");
Tcl.isOctal    = new RegExp("^[+\\-]?0[0-7]*$");
Tcl.isHexSeq   = new RegExp("[0-9a-fA-F]*");
Tcl.isOctalSeq = new RegExp("[0-7]*");
Tcl.isList     = new RegExp("[\\{\\} ]");
Tcl.isNested   = new RegExp("^\\{.*\\}$");
Tcl.getVar     = new RegExp("^[a-zA-Z0-9_]+", "g");

Tcl.Source = function (interp, url) {
 var xhr_object = null;
 if(window.ActiveXObject)       // Internet Explorer
 xhr_object = new ActiveXObject("Microsoft.XMLHTTP");
 else if(window.XMLHttpRequest) // Firefox
 xhr_object = new XMLHttpRequest();
 else { // XMLHttpRequest non supporté par le navigateur
   alert("Your browser does not support XMLHTTP requests. " +
         "Sorry that we cannot deliver this page.");
   return;
 }
 xhr_object.open("GET", url, false);
 xhr_object.send(null);
 return interp.eval(xhr_object.responseText);
}
Tcl.Proc = function (interp, args) {
 var priv = this.privdata;
 interp.incrLevel();
 var arglist = priv[0].toList();
 var body    = priv[1];
 args.shift();
 for (var i = 0; i < arglist.length; i++) {
   var name = arglist[i].toString();
   if (i >= args.length) {
     if (name == "args") {
       interp.setVar("args", Tcl.empty);
       break;
     }
   }
   if (Tcl.isList.test(name)) {
     name = interp.parseString(name).toList();
     if (name[0] == "args") throw "'args' defaults to the empty string";
     if (i >= args.length)
       interp.setVar(name.shift(), interp.parseString(name.join(" ")));
     else interp.setVar(name[0], interp.objectify(args[i]));
   } else if (name == "args") {
     interp.setVar("args", new TclObject(args.slice(i, args.length)));
     break;
   }
   interp.setVar(name, interp.objectify(args[i]));
 }
 if (name == "args" && i+1 < arglist.length)
   throw "'args' should be the last argument";
 try {
   var r = interp.eval(body);
   interp.code = interp.OK;
   interp.decrLevel();
   return r;
 } catch (e) {
   interp.decrLevel();
   throw "Tcl.Proc exception "+e;
 }
}
/** Manage subcommands */
Tcl.EnsembleCommand = function (interp, args) {
 var sub  = args[1].toString();
 var main = args.shift().toString()+sub;
 args[0] = main;
 var ens = this.ensemble;
 if (ens == null || ens[sub] == null) {
   throw "Not an ensemble command: "+main;
 }
 return ens[sub].call(interp, args);
}
/** Get subcommands of the current ensemble command. */
Tcl.InfoSubcommands = function(interp, args) {
 var r = new Array();
 for (var i in this.ensemble) r.push(i);
 return interp.objectify(r);
}
function TclObject(text) {
 this.TEXT    = 0;
 this.LIST    = 1;
 this.INTEGER = 2;
 this.REAL    = 3;
 this.BOOL    = 4;
 switch (arguments[0]) {
 case "LIST":
 case "INTEGER":
 case "REAL":
 case "BOOL":
   this.type = this[arguments[0]];
   break;
 default:
   this.type = this.TEXT;
   if (text instanceof Array) this.type = this.LIST;
   else text = text.toString();
   break;
 }
 this.content = text;
 this.stringIndex = function (i) {
   this.toString();
   return this.index(i, this.content.length);
 }
 this.listIndex = function (i) {
   this.toList();
   return this.index(i, this.content.length);
 }
 this.index = function (i, len) {
   var index = i.toString();
   if (index.substring(0,4) == "end-")
     index = len - parseInt(index.substring(4)) - 1;
   else if (index == "end") index = len-1;
   else index = parseInt(index);
   if (isNaN(index)) throw "Bad index "+i;
   if (index < 0 || index >= len) throw "Index out of bounds";
   return index;
 }
 this.isInteger = function () {return (this.type == this.INTEGER);}
 this.isReal    = function () {return (this.type == this.REAL);}
 this.getString = function (list, nested) {
   var res = new Array();
   for (var i in list) {
     res[i] = list[i].toString();
     if (Tcl.isList.test(res[i]) && !Tcl.isNested.test(res[i]))
       res[i] = "{" + res[i] + "}";
   }
   if (res.length == 1) return res[0];
   return res.join(" ");
 }
 this.toString = function () {
   if (this.type != this.TEXT) {
     if (this.type == this.LIST)
       this.content = this.getString(this.content);
     else this.content = this.content.toString();
     this.type = this.TEXT;
   }
   return this.content;
 }
 this.getList = function (text) {
   if (text.charAt(0) == "{" && text.charAt(text.length-1) == "}")
     text = text.substring(1, text.length-1);
   if (text == "") return [];
   var parser = new TclParser(text.toString());
   var content = new Array();
   for (var i = 0; ; i++) {
     parser.parseList();
     content[i] = new TclObject(parser.getText());
     if (parser.type == parser.EOL || parser.type == parser.ESC)
       break;
   }
   return content;
 }
 this.toList = function () {
   if (this.type != this.LIST) {
     if (this.type != this.TEXT) this.content[0] = this.content;
     else this.content = this.getList(this.content);
     this.type = this.LIST;
   }
   return this.content;
 }
 this.toInteger = function () {
   if (this.type == this.INTEGER) return this.content;
   this.toString();
   if (this.content.match(Tcl.isHex))
     this.content = parseInt(this.content.substring(2), 16);
   else if (this.content.match(Tcl.isOctal))
     this.content = parseInt(this.content, 8);
   else if (this.content.match(Tcl.isDecimal))
     this.content = parseInt(this.content);
   else throw "Not an integer: '"+this.content+"'";
   if (isNaN(this.content)) throw "Not an integer: '"+this.content+"'";
   this.type = this.INTEGER;
   return this.content;
 }
 this.getFloat = function (text) {
   if (!text.toString().match(Tcl.isReal))
   throw "Not a real: '"+text+"'";
   return parseFloat(text);
 }
 this.toReal = function () {
   if (this.type == this.REAL)
   return this.content;
   this.toString();
   // parseFloat doesn't control all the string, so need to check it
   this.content = this.getFloat(this.content);
   if (isNaN(this.content)) throw "Not a real: '"+this.content+"'";
   this.type = this.REAL;
   return this.content;
 }
 this.getNumber = function () {
   try {
     return this.toInteger();
   } catch (e) {return this.toReal();}
 }
 this.toBoolean = function () {
   if (this.type == this.BOOL) return this.content;
   try {
     this.content = (this.toInteger() != 0);
   } catch (e) {
     var t = this.content;
     if (t instanceof Boolean) return t;
     switch (t.toString().toLowerCase()) {
     case "yes":case "true":case "on":
       this.content = true;
       break;
     case "false":case "off":case "no":
       this.content = false;
       break;
     default:
       throw "Boolean expected, got: '"+this.content+"'";
     }
   }
   this.type = this.BOOL;
   return this.content;
 }
}
function TclCommand(func, privdata) {
 if (func == null) throw "No such function";
 this.func = func;
 this.privdata = privdata;
 this.ensemble = arguments[2];

 this.call = function(interp, args) {
   var r = (this.func)(interp, args);
   r = interp.objectify(r);
   if (r != null) interp.setVar("_", r);
   return r;
 }
 this.requireExactArgc = function (args, argc) {
   if (args.length != argc) {
     throw argc+" arguments expected, got "+args.length;
   }
 }
 this.requireMinArgc = function (args, argc) {
   if (args.length < argc) {
     throw argc+" arguments expected at least, got "+args.length;
   }
 }
 this.requireArgcRange = function (args, min, max) {
   if (args.length < min || args.length > max) {
     throw min+" to "+max+" arguments expected, got "+args.length;
   }
 }
}
function TclParser(text) {
 this.OK  = 0;
 this.SEP = 0;
 this.STR = 1;
 this.EOL = 2;
 this.EOF = 3;
 this.ESC = 4;
 this.CMD = 5;
 this.VAR = 6;
 this.text  = text;
 this.start = 0;
 this.end   = 0;
 this.insidequote = false;
 this.index = 0;
 this.len = text.length;
 this.type = this.EOL;
 this.cur = this.text.charAt(0);
 this.getText = function () {
   return this.text.substring(this.start,this.end+1);
 }
 this.parseString = function () {
   var newword = (this.type==this.SEP ||
                  this.type == this.EOL || this.type == this.STR);
   if (newword && this.cur == "{") return this.parseBrace();
   else if (newword && this.cur == '"') {
     this.insidequote = true;
     this.feedchar();
   }
   this.start = this.index;
   while (true) {
     if (this.len == 0) {
       this.end = this.index-1;
       this.type = this.ESC;
       return this.OK;
     }
     if (this.cur == "\\") {
       if (this.len >= 2)
         this.feedSequence();
     }
     else if ("$[ \t\n\r;".indexOf(this.cur)>=0) {
       if ("$[".indexOf(this.cur)>=0 || !this.insidequote) {
         this.end = this.index-1;
         this.type = this.ESC;
         return this.OK;
       }
     }
     else if (this.cur == '"' && this.insidequote) {
       this.end  = this.index-1;
       this.type = this.ESC;
       this.feedchar();
       this.insidequote = false;
       return this.OK;
     }
     this.feedchar();
   }
   return this.OK;
 }
 this.parseList = function () {
   level = 0;
   this.start = this.index;
   while (true) {
     if (this.len == 0) {
       this.end = this.index;
       this.type = this.EOL;
       return;
     }
     switch (this.cur) {
     case "\\":
       if (this.len >= 2) this.feedSequence();
       break;
     case " ": case "\t": case "\n": case "\r":
       if (level > 0) break;
       this.end  = this.index - 1;
       this.type = this.SEP;
       this.feedchar();
       return;
     case '{':
       level++;
       break;
     case '}':
       level--;
       break;
     }
     this.feedchar();
   }
   if (level != 0) throw "Not a list";
   this.end = this.index;
   return;
 }
 this.parseSep = function () {
   this.start = this.index;
   while (" \t\r\n".indexOf(this.cur)>=0) this.feedchar();
   this.end  = this.index - 1;
   this.type = this.SEP;
   return this.OK;
 }
 this.parseEol = function () {
   this.start = this.index;
   while(" \t\n\r;".indexOf(this.cur)>=0) this.feedchar();
   this.end  = this.index - 1;
   this.type = this.EOL;
   return this.OK;
 }
 this.parseCommand = function () {
   var level = 1;
   var blevel = 0;
   this.feedcharstart();
   while (true) {
     if (this.len == 0) break;
     if (this.cur == "[" && blevel == 0)
       level++;
     else if (this.cur == "]" && blevel == 0) {
       level--;
       if (level == 0) break;
     } else if (this.cur == "\\") {
       this.feedSequence();
     } else if (this.cur == "{") {
       blevel++;
     } else if (this.cur == "}") {
       if (blevel != 0) blevel--;
     }
     this.feedchar();
   }
   this.end  = this.index-1;
   this.type = this.CMD;
   if (this.cur == "]")
   this.feedchar();
   return this.OK;
 }
 this.parseVar = function () {
   this.feedcharstart();
   this.end = this.index
   + this.text.substring(this.index).match(Tcl.getVar).toString().length-1;
   if (this.end == this.index-1) {
     this.end = --this.index;
     this.type = this.STR;
   } else this.type = this.VAR;
   this.setPos(this.end+1);
   return this.OK;
 }
 this.parseBrace = function () {
   var level = 1;
   this.feedcharstart();
   while (true) {
     if (this.len > 1 && this.cur == "\\") {
       this.feedSequence();
     } else if (this.len == 0 || this.cur == "}") {
       level--;
       if (level == 0 || this.len == 0) {
         this.end = this.index-1;
         if (this.len > 0) this.feedchar();
         this.type = this.STR;
         return this.OK;
       }
     } else if (this.cur == "{") level++;
     this.feedchar();
   }
   return this.OK; // unreached
 }
 this.parseComment = function () {
   while (this.cur != "\n" && this.cur != "\r") this.feedchar();
 }
 this.getToken = function () {
   while (true) {
     if (this.len == 0) {
       if (this.type == this.EOL) this.type = this.EOF;
       if (this.type != this.EOF) this.type = this.EOL;
       return this.OK;
     }
     switch (this.cur) {
       case ' ':
       case '\t':
       if (this.insidequote) return this.parseString();
       return this.parseSep();
       case '\n':
       case '\r':
       case ';':
       if (this.insidequote) return this.parseString();
       return this.parseEol();
       case '[':
       return this.parseCommand();
       case '$':
       return this.parseVar();
     }
     if (this.cur == "#" && this.type == this.EOL) {
       this.parseComment();
       continue;
     }
     return this.parseString();
   }
   return this.OK; // unreached
 }
 this.feedSequence = function () {
   if (this.cur != "\\") throw "Invalid escape sequence";
   var cur = this.steal(1);
   var specials = new Object();
   specials.a = "\a";
   specials.b = "\b";
   specials.f = "\f";
   specials.n = "\n";
   specials.r = "\r";
   specials.t = "\t";
   specials.v = "\v";
   switch (cur) {
   case 'u':
     var hex = this.steal(4);
     if (hex != Tcl.isHexSeq.exec(hex))
       throw "Invalid unicode escape sequence: "+hex;
     cur = String.fromCharCode(parseInt(hex,16));
     break;
   case 'x':
     var hex = this.steal(2);
     if (hex != Tcl.isHexSeq.exec(hex))
       throw "Invalid unicode escape sequence: "+hex;
     cur = String.fromCharCode(parseInt(hex,16));
     break;
   case "a": case "b": case "f": case "n":
   case "r": case "t": case "v":
     cur = specials[cur];
     break;
   default:
     if ("0123456789".indexOf(cur) >= 0) {
       cur = cur + this.steal(2);
       if (cur != Tcl.isOctalSeq.exec(cur))
         throw "Invalid octal escape sequence: "+cur;
       cur = String.fromCharCode(parseInt(cur, 8));
     }
     break;
   }
   this.text[index] = cur;
   this.feedchar();
 }
 this.steal = function (n) {
   var tail = this.text.substring(this.index+1);
   var word = tail.substr(0, n);
   this.text = this.text.substring(0, this.index-1) + tail.substring(n);
   return word;
 }
 this.feedcharstart = function () {
   this.feedchar();
   this.start = this.index;
 }
 this.setPos = function (index) {
   var d = index-this.index;
   this.index = index;
   this.len -= d;
   this.cur = this.text.charAt(this.index);
 }
 this.feedchar = function () {
   this.index++;
   this.len--;
   if (this.len < 0) throw "End of file reached";
   this.cur = this.text.charAt(this.index);
 }
}

var TI = new TclInterp();

