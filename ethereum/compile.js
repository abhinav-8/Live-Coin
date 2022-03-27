const path = require("path");
const solc = require("solc");
const fs = require("fs-extra"); //  fs: fs module is part of node standard library,short for "file system",gives access to file system in our local computer
// "fs extra" is a module which has some extra functions and all other same as "fs"

const buildPath = path.resolve(__dirname, "build");
fs.removeSync(buildPath); //For deleting build folder

const campaignPath = path.resolve(__dirname, "contracts", "Campaign.sol");
const source = fs.readFileSync(campaignPath, "utf8");
const output = solc.compile(source, 1).contracts;

fs.ensureDirSync(buildPath); //For making build folder

// console.log(output);
for (let contract in output) {
	let name = contract.replace(":", ""); //If we will not remove : from file names generated into build folder,it will not work in a windows machine
	fs.outputJsonSync(
		//It writes a json file to a specified location
		path.resolve(buildPath, name + ".json"),
		output[contract]
	);
}
