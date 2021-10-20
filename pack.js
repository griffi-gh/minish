//load libs
const fs = require('fs');
const readline = require('readline').createInterface({
  input: process.stdin,
  output: process.stdout
});

const METASTR = '--CONSTANTS;';

function getItems(dir,type='*') {
	let out = [];
	fs.readdirSync(`./${dir}/`).forEach((v,i,a) => {
		if(type=='*') {
			out.push(v);
			return;
		}
		if(v.endsWith('.'+type)) {
			out.push(v.replace(/(\.).+/g,''));
			return;
		}
	});
	return out;
}

let template = 'none'
let srom
readline.question('\nSelect template ('+getItems('templates','lua').join(', ')+') (default: none) => ', option => {
  template = option || template;
  readline.question('Select a ROM ('+getItems('roms').join(', ')+') (default: none) => ', option2 => {
  	srom = option2;
  	readline.close();

  	console.log('\nLoading data...');
  	//load files
	  let core = fs.readFileSync('./minish.lua','utf8');
	  let target = fs.readFileSync('./templates/'+template+'.lua','utf8');

	  let constants = [];
	  let _meta = core.substring(core.indexOf(METASTR),core.length);
	  _meta = _meta.replace(METASTR,'').split(',');
	  _meta.forEach((v,i,a)=>{
	  	[num,char] = v.split(':');
	  	constants[parseInt(num.trim())] = char.trim();
	  });

		//get rom str
		let rom = '';
		if(srom && srom.length>0) {
			let romData = fs.readFileSync('./roms/'+srom);
			for(const byte of romData) {
				let v = constants[byte] || byte.toString();
				rom += v + ',';
			}
			rom = rom.slice(0, -1);
		}

		console.log('Packing...\n');
		
		//combine
		target = target.replace('--[[MINISH]]',core);
		target = target.replace('--[[ROM]]',rom);

		//process
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

		//remove spaces
		out = out.replace(/(\))\s+/g,')');
		out = out.replace(/\s+(\()/g,'(');
		out = out.replace(/(\])\s+/g,']');
		out = out.replace(/\s+(\[)/g,'[');
		out = out.replace(/(\})\s+/g,'}');
		out = out.replace(/\s+(\{)/g,'{');
		out = out.replace(/(=)\s+/g,'=');
		out = out.replace(/\s+(=)/g,'=');

		//print
		console.log(out+'\n');
		console.log('Size: '+out.length+' bytes')

		//copy on windows
		if(process.platform == 'win32') {
			const util = require('util');
			require('child_process').spawn('clip').stdin.end(out);
			console.log('Copied!');
		} else {
			console.warn('Can only copy on Windows')
		}
  });
});