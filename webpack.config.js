'use strict';

var webpack = require('webpack');
var path = require('path');
var HtmlWebpackPlugin = require('html-webpack-plugin');
var ExtractTextPlugin = require("extract-text-webpack-plugin");

var APP = __dirname + '/app';
var DIST = __dirname + '/dist';

module.exports = {
	context: APP,
	entry: {
		app: './'
	},
	output: {
		path: DIST,
        filename: "[name].js",
        chunkFilename: "[id].js",
		publicPath: '',
		hash: true
	},
	module: {
		loaders: [
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
				test: /\.(woff|woff2|ttf|eot|svg|png|gif|jpg|jpeg)(\?]?.*)?$/,
				loader: 'file-loader?name=[path][name].[ext]'
			},
			{
				test: /\.(wav|mp3)(\?]?.*)?$/,
				loader: 'file-loader?name=[path][name].[ext]'
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
		new HtmlWebpackPlugin({
			template: APP + '/index.html',
			inject: true
		}),
		new ExtractTextPlugin("[name].css", {
            allChunks: true
        }),
		new webpack.DefinePlugin({
			MODE: {
				production: process.env.NODE_ENV === 'production'
			}
		})
	]
};
