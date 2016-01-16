'use strict';

var webpack = require('webpack');
var path = require('path');
var node_modules_dir = path.resolve(__dirname, 'node_modules');
var HtmlWebpackPlugin = require('html-webpack-plugin');
var ExtractTextPlugin = require("extract-text-webpack-plugin");

var APP = __dirname + '/app';
var DIST = __dirname + '/dist';

var config = {
	context: APP,
	entry: {
		app: './',
		vendors: [
			'jquery',
			'angular',
			'angular-animate',
			'angular-cookies',
			'angular-resource',
			'angular-sanitize',
			'angular-touch',
			'angular-ui-router',
			'ngstorage'
		]
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
		new HtmlWebpackPlugin({
			template: APP + '/index.html',
			inject: true
		}),
		new webpack.optimize.DedupePlugin(),
		new webpack.optimize.CommonsChunkPlugin('vendors', 'vendors.[hash].js'),
		new ExtractTextPlugin("[name].[hash].css", {
            allChunks: true
        }),
		new webpack.DefinePlugin({
			MODE: {
				production: process.env.NODE_ENV === 'production'
			}
		})
	]
};

module.exports = config;
