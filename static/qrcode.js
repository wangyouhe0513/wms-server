/**
 * Minimal QR Code Generator — renders as table into #qrcode div
 * Based on qrcode-generator (MIT) by Kazuhiko Arase
 */
(function(){
var _url = window._qr_url;
if (!_url) return;
var el = document.getElementById('qrcode');
if (!el) return;

// ---- QR Code implementation ----
var QRCodeImpl = function() {
  var P=0,P1=1,P2=2,dataList=[],typeNumber=0,errorCorrectLevel=1,dataCache=null,maskPattern=null,modules=[],moduleCount=0;
  var Q=[[],[6,18],[],[6,22],[],[6,26],[],[6,30],[],[6,34],[],[6,22,38],[],[6,24,42],[],[6,26,46],[],[6,28,48],[],[6,30,50],[],[6,32,52],[],[6,34,54],[],[6,26,46,66],[],[6,26,48,68],[],[6,26,50,70],[],[6,30,54,78],[],[6,30,56,82],[],[6,30,58,86],[],[6,34,62,94],[],[6,28,46,72,106],[],[6,32,48,76,110],[],[6,30,50,80,114],[],[6,34,54,90,122],[],[6,28,50,72,94,128],[],[6,26,50,74,98,132],[],[6,30,54,78,108,138],[],[6,32,50,82,110,146],[],[6,30,54,86,118,154],[],[6,34,62,98,142,170]],M=[[],[6],[],[6],[],[6],[],[6],[],[6],[],[7],[],[8],[],[8],[],[8],[],[8],[],[8],[],[9],[],[9],[],[9],[],[9],[],[9],[],[10],[],[10],[],[10],[],[10],[],[10]];

  function bestMask(){var m=0,penalty=0;for(var i=0;i<8;i++){makeMask(i);var p=calcPenalty();if(i===0||p<penalty){penalty=p;m=i;}}return m;}
  function calcPenalty(){var p=0;for(var y=0;y<moduleCount;y++){for(var x=0;x<moduleCount;x++){var r=0;if(x+5<moduleCount&&modules[y][x]&&modules[y][x+1]&&modules[y][x+2]&&modules[y][x+3]&&modules[y][x+4])p+=3;if(y+5<moduleCount&&modules[y][x]&&modules[y+1][x]&&modules[y+2][x]&&modules[y+3][x]&&modules[y+4][x])p+=3;}}return p;}
  function makeMask(m){maskPattern=m;for(var y=0;y<moduleCount;y++){for(var x=0;x<moduleCount;x++){modules[y][x]=null;}}setupPos();mod(0,0,true,true);mod(moduleCount-7,0,true,true);mod(0,moduleCount-7,true,true);setupTiming();setupTypeInfo();for(var i=0;i<dataCache.length;i++){placeData(dataCache[i],(i%2===0));}}
  function setupPos(){for(var r=-1;r<=6;r+=7){for(var c=-1;c<=6;c+=7){for(var y=-1;y<=6;y++){for(var x=-1;x<=6;x++){var ry=r+y,cx=c+x;if(ry>=0&&ry<moduleCount&&cx>=0&&cx<moduleCount){var v=(y===0||y===6||x===0||x===6||(y>=2&&y<=4&&x>=2&&x<=4));modules[ry][cx]=v;}}}}}}
  function setupTiming(){for(var i=8;i<moduleCount-8;i++){if(modules[i][6]===null)modules[i][6]=i%2===0;if(modules[6][i]===null)modules[6][i]=i%2===0;}}
  function setupTypeInfo(){var d=errorCorrectLevel<<3|maskPattern,b=getBCHTypeInfo(d);for(var i=0;i<15;i++){var mod=((i<6)?((i<3)?(8-i):(14-i)):(i<8?7:(moduleCount-15+i)));var row=(i<8)?8:moduleCount-8+i%8;modules[row][mod]=((b>>i)&1)===1;}}
  function getBCHTypeInfo(d){var g=0x537;var b=d<<10;while(getBCHDigit(b)>=getBCHDigit(g)){b^=g<<(getBCHDigit(b)-getBCHDigit(g));}return(d<<10|b)^0x5412;}
  function getBCHDigit(v){var d=0;while(v!==0){d++;v>>>=1;}return d;}
  function mod(y,x,v,d){modules[y][x]=v;d&&(modules[x][y]=v);}
  function placeData(d,rowDir){var y=moduleCount-1,x=y,dir=-1;var i=0;while(y>0){if(x===6)x--;if(modules[y][x]===null){var b=(d>>>(7-i%8))&1;modules[y][x]=b;modules[y][x]===null&&(modules[y][x]=false);i++;}x+=dir;if(x<0){x=0;dir=-dir;y-=2;if(y===6)y--;}if(x>=moduleCount){x=moduleCount-1;dir=-dir;y-=2;if(y===6)y--;}}}
  function createData(){var rsBlocks=Q[typeNumber];if(!rsBlocks)throw new Error('bad type:'+typeNumber);var total=0,ec=0;for(var i=0;i<rsBlocks.length/3;i++){var c=rsBlocks[i*3+0],t=rsBlocks[i*3+1],d=rsBlocks[i*3+2];total+=c*t;ec+=c*d;}var buf=[];for(var i=0;i<total;i++)buf.push(0);var p=0;for(var i=0;i<rsBlocks.length/3;i++){var c=rsBlocks[i*3+0],t=rsBlocks[i*3+1];for(var j=0;j<c;j++){for(var k=0;k<t;k++){buf[p+k]=dataList[i][k];}p+=t;}}var ecBuf=[];for(var i=0;i<rsBlocks.length/3;i++){var c=rsBlocks[i*3+0],t=rsBlocks[i*3+1],d=rsBlocks[i*3+2];for(var j=0;j<c;j++){var db=[];for(var k=0;k<t;k++)db.push(dataList[i][k]);var gb=[];for(var k=0;k<d;k++)gb.push(0);var poly=createPolynomial(db,gb);for(var k=0;k<d;k++)ecBuf.push(poly[k]);}}var result=[];for(var i=0;i<total;i++)result.push(buf[i]);for(var i=0;i<ec;i++)result.push(ecBuf[i]);return result;}
  function createPolynomial(db,gb){var total=db.length+gb.length-1;var poly=[];for(var i=0;i<total;i++)poly.push(0);for(var i=0;i<db.length;i++)poly[i]=db[i];for(var i=0;i<gb.length;i++){var a=gb[i];if(a!==0){for(var j=0;j<db.length;j++){poly[i+j]^=EXP_TABLE[(LOG_TABLE[poly[i+j]]+LOG_TABLE[a])%255];}}}return poly;}
  var EXP_TABLE=[],LOG_TABLE=[];
  (function(){for(var i=0;i<256;i++){EXP_TABLE.push(i<128?i<<1:(i<<1)^285);LOG_TABLE[EXP_TABLE[i]]=i;}})();

  function addData(data){var d=[];for(var i=0;i<data.length;i++){var c=data.charCodeAt(i);if(c<128){d.push(c);}else{var b=encodeURIComponent(data[i]).replace(/%/g,'');d.push(0x80|((c>>6)&0x1f),0x80|(c&0x3f));}}var rs=M[typeNumber];if(!rs)throw new Error('bad type:'+typeNumber);var dc=rs[0],t=0;while(dc*t<d.length){t++;}for(var i=0;i<t;i++){var b=[];for(var j=0;j<dc;j++)b.push(d[i*dc+j]||0);dataList.push(b);}dataCache=createData();moduleCount=4*typeNumber+17;modules=[];for(var y=0;y<moduleCount;y++){modules.push([]);for(var x=0;x<moduleCount;x++)modules[y].push(null);}makeMask(bestMask());}
  this.addData=addData;
  this.getModuleCount=function(){return moduleCount;};
  this.isDark=function(y,x){return y>=0&&y<moduleCount&&x>=0&&x<moduleCount&&modules[y][x];};
};

// Determine best type
function getType(text){
  var len=0;
  for(var i=0;i<text.length;i++){var c=text.charCodeAt(i);len+=c<128?1:2;}
  for(var t=1;t<=40;t++){var r=M[t];if(r&&r[0]*1>=len)return t;}
  return 10;
}

function renderQR(text){
  var qr=new QRCodeImpl();
  try{var t=getType(text);qr.QRCodeImpl=qr;qr.addData(text);qr._typeNumber=t;qr.addData(text);}catch(e){}

  // Render as table
  var count=qr.getModuleCount();
  var size=Math.min(180,Math.floor(180/count)*count);
  var cellSize=Math.floor(size/count);
  var html='<table style="border-collapse:collapse;margin:0 auto;width:'+(cellSize*count)+'px;height:'+(cellSize*count)+'px">';
  for(var y=0;y<count;y++){
    html+='<tr style="height:'+cellSize+'px">';
    for(var x=0;x<count;x++){
      html+='<td style="width:'+cellSize+'px;height:'+cellSize+'px;background:'+(qr.isDark(y,x)?'#1e293b':'#fff')+'"></td>';
    }
    html+='</tr>';
  }
  html+='</table>';
  el.innerHTML=html;
}

// Override type to set directly
var origAddData = QRCodeImpl.prototype.addData;
QRCodeImpl.prototype.addData = function(data){
  var type = getType(data);
  var M_local = M;
  var rs = M_local[type];
  var dc = rs[0], t = 0;
  var d = [];
  for(var i = 0; i < data.length; i++){
    var c = data.charCodeAt(i);
    if (c < 128) { d.push(c); }
    else { var b = encodeURIComponent(data[i]).replace(/%/g, ''); d.push.apply(d, b.split('').map(function(h){return parseInt(h,16);})); }
  }
  while (dc * t < d.length) { t++; }
  for (var i = 0; i < t; i++) {
    var b = [];
    for (var j = 0; j < dc; j++) b.push(d[i * dc + j] || 0);
    dataList.push(b);
  }
  dataCache = createData.call(this);
  moduleCount = 4 * type + 17;
  modules = [];
  for (var y = 0; y < moduleCount; y++) { modules.push([]); for (var x = 0; x < moduleCount; x++) modules[y].push(null); }
  makeMask.call(this, bestMask.call(this));
};

renderQR(_url);
})();
