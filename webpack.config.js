'use strict';

var webpack = require('webpack');
var path = require('path');
var CordovaPlugin = require('webpack-cordova-plugin');

var APP = __dirname + '/app';

module.exports = {
	context: APP,
	entry: {
		app: ['./app.module.coffee']
	},
	output: {
		path: APP,
		filename: 'bundle.js'
	},
	module: {
		loaders: [
			{
				test: /\.scss$/,
				loaders: ['style', 'css', 'sass']
			},
			{
				test: /\.coffee$/,
				loader: "coffee-loader"
			},
			{
				test: /\.(coffee\.md|litcoffee)$/,
				loaders: ["coffee-loader?literate"]
			},
			{
				test: /\.html$/,
				loader: 'ngtemplate?relativeTo=' + APP + '/!html'
				// loader: 'raw'
			},
			{
				test: /\.(woff|woff2|ttf|eot|svg|png|gif|jpg|jpeg)(\?]?.*)?$/,
				loader: 'file-loader?name=res/[name].[ext]?[hash]'
			},
			{
				test: /\.(wav|mp3)(\?]?.*)?$/,
				loader: 'file-loader'
			},
			{
				test: /\.json/,
				loader: 'json'
			}
		]
	},
	resolve: {
		root: APP,
		extensions: ["", ".webpack.js", ".web.js", ".js", ".coffee"]
	},
	plugins: [
		new webpack.HotModuleReplacementPlugin(),
		new webpack.ProvidePlugin({
			jQuery: "jquery",
			$: "jquery"
		}),
		new webpack.DefinePlugin({
			MODE: {
				production: process.env.NODE_ENV === 'production'
			}
		}),
		new CordovaPlugin({
			config: 'config.xml',  // Location of Cordova' config.xml (will be created if not found)
			src: 'app/index.html',     // Set entry-point of cordova in config.xml
			platform: 'android', // Set `webpack-dev-server` to correct `contentBase` to use Cordova plugins.
			version: true,         // Set config.xml' version. (true = use version from package.json)
		})
	]
};
