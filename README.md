# ShapeConnector  

### A puzzle game. Play at [shapeconnector.com](http://shapeconnector.com)!

ShapeConnector is a simple puzzle game, where the goal is to get from point A to point B in X number of moves.

The caveat: you are only allowed to move up, down, left, or right, and to a shape that is the same color (red, green, blue, yellow) and/or type (square, diamond, triangle, circle).

![game play](https://raw.githubusercontent.com/thalida/ShapeConnector/master/app/assets/images/gameplay.gif)

## The implementation

The game is developed using Angular, and is built by Webpack. All game elements are rendered on HTML5 canvases. In addition, it is written in CoffeeScript and use SCSS for styles. You can play the game offline through ServiceWorkers.

ShapeConnector was designed using Sketch, and if you would like to view the components, they are available here: [ShapeConnector sketch file](https://github.com/thalida/ShapeConnector/blob/master/shapeconnector.sketch).


## Future additions
Checkout the [open issues](https://github.com/thalida/ShapeConnector/issues) for enhancements, features, and bugs of the game.


## Contributing
### Clone ShapeConnector

Clone the ShapeConnector repository using [git](https://git-scm.com/):

```
git clone git@github.com:thalida/ShapeConnector.git
cd ShapeConnector
```

### Install Dependencies

We depend on `npm`, the [node package manager](https://www.npmjs.org/) for *all* of the tools and libraries we need to develop the app.

```
npm install
```
### Running the game

#### In Development
This repo comes with the Webpack build server that is already configured, start the server with:

```
npm run start:dev
```

Run the app at `http://localhost:8080`.

#### In Staging
To replicate what the production environment locally, run:

```
npm run start:staging
```

The above cmd runs `npm run clean` and `npm run build:staging`, then starts a 
python web server using: `python -m SimpleHTTPServer`.

#### In Production
```
npm run build:prod
```


## License
GNU General Public License v3.0


## Resources
**Music:**
"Carefree" by Kevin MacLeod [incompetech.com](http://incompetech.com)
Licensed under Creative Commons: By Attribution 3.0

**Sounds:** 
Generated using [as3sfxr](http://www.superflashbros.net/as3sfxr/)
