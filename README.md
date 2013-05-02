# Protagonist
### API Blueprint Parser for Node.js

Protagonist is a Node.js wrapper for the [Snow Crash](https://github.com/apiaryio/snowcrash) library.

Full API Blueprint documentation can be found on the [API Blueprint site](http://apiblueprint.org).

## Install
The best way to install Protagonist is by using its [NPM package](https://npmjs.org/package/protagonist).

	$ npm install protagonist

## Getting started

	```js
	var protagonist = require('protagonist');
	var blueprint = "# My API"
	protagonist.parse(blueprint, function(error, ast) {
		if (error) {
    		console.log(error);
		    return;
  		}
  
	  console.log(ast);
	}
	```

## Hacking
You are welcome to contribute. Use following steps to build & test Protagonist.

### Build
Protagonist uses [node-gyp](https://github.com/TooTallNate/node-gyp) build tool. 

1. Clone the repo + fetch the submodules:

		$ git clone git://github.com/apiaryio/protagonist.git
		$ cd protagonist
		$ git submodule update --init --recursive

2. If needed, install node-gyp:

		$ npm install -g node-gyp
    
3. Build:

	    $ node-gyp configure
    	$ node-gyp build

### Test

	$ TODO

## License
See LICENSE file.
