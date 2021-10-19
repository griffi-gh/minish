const fs = require('fs');
let core = fs.readFileSync('./minish.lua','utf8');
let target = fs.readFileSync('./stormworks.lua','utf8');
//get rom str
let rom = '';
let romData = fs.readFileSync('./rom.ch8');
for(const byte of romData) {
	rom += byte.toString()+','
}
rom = rom.slice(0, -1);
//combine
target = target.replace('--[[MINISH]]',core);
target = target.replace('--[[ROM]]',rom);
let lines = [];
for(let line of target.split('\n')) {
	line = line.trim();
	if(line.startsWith('--')) continue;
	const comment = line.indexOf('--');
	if(comment > 0) line = line.substring(0, comment);
	line = line.trim();
	if(line.length > 0) lines.push(line);
}
let out = lines.join(' ');

out = out.replace(/(\))\s+/g,')');
out = out.replace(/\s+(\()/g,'(');
out = out.replace(/(\])\s+/g,']');
out = out.replace(/\s+(\[)/g,'[');
out = out.replace(/(\})\s+/g,'}');
out = out.replace(/\s+(\{)/g,'{');
out = out.replace(/(=)\s+/g,'=');
out = out.replace(/\s+(=)/g,'=');

console.log(out+'\n');
console.log('Size: '+out.length+' bytes')
//copy on windows
if(process.platform == 'win32') {
	const util = require('util');
	require('child_process').spawn('clip').stdin.end(out);
	console.log('Copied!');
} else {
	console.log('Can only copy on Windows')
}