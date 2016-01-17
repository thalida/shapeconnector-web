'use strict'


var webpack = require('webpack');
var merge = require('webpack-merge');
var path = require('path');
var HtmlWebpackPlugin = require('html-webpack-plugin');
var ExtractTextPlugin = require("extract-text-webpack-plugin");
var OfflinePlugin = require('offline-plugin');

var isProduction = process.env.NODE_ENV === 'production'

var APP = __dirname + '/app';
var DIST = __dirname + '/dist';


var common = {
	context: APP,
	entry: {
		app: './'
	},
	output: {
		path: DIST,
        filename: "[name].[hash].js",
        chunkFilename: "[id].js",
		publicPath: ''
	},
	module: {
		loaders: [
			{
				test: require.resolve("jquery"),
				loader: "expose?$!expose?jQuery"
			},
			{
				test: require.resolve('angular'),
				loader: "expose?angular"
			},
			{
				test: /\.scss$/,
				loader: ExtractTextPlugin.extract("style-loader", "css-loader!resolve-url-loader!sass-loader?sourceMap")
			},
			{
				test: /\.coffee$/,
				loader: "coffee-loader"
			},
			{
				test: /\.html$/,
				loader: 'ngtemplate?relativeTo=' + APP + '/!html'
			},
			{
				test: /\.(woff|woff2|ttf|eot|svg|png|gif|jpg|jpeg|wav|mp3)(\?]?.*)?$/,
				loader: 'file-loader?name=[path][name].[hash].[ext]'
			},
			{
				test: /\.(json)(\?]?.*)?$/,
				loader: 'file-loader?name=[path][name].[ext]'
			}
		]
	},
	resolve: {
		root: APP,
		extensions: ["", ".webpack.js", ".web.js", ".js", ".coffee"]
	},
	plugins: [
		new HtmlWebpackPlugin({
			template: APP + '/index.html',
			inject: true
		}),
		new ExtractTextPlugin("[name].[hash].css", {
            allChunks: true
        }),
		new webpack.DefinePlugin({
			MODE: {
				production: isProduction
			}
		}),
		new OfflinePlugin({
			caches: 'all',
			scope: '/',
			updateStrategy: 'hash',
			ServiceWorker: {
				output: 'sw.js'
			},
			AppCache: null
		})
	]
};

var productionConfig = {};
var devConfig = {
	plugins: [
		new webpack.HotModuleReplacementPlugin()
 	]
};

var config = ( isProduction ) ? productionConfig : devConfig;
module.exports = merge(common, config);
