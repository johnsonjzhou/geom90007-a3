"use strict";
const webpack = require("webpack");
const path = require("path");
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const CopyPlugin = require('copy-webpack-plugin');
const RemoveEmptyScriptsPlugin = require("webpack-remove-empty-scripts");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");

const copyFiles = [
  {
    from: 'src/img/*.*',
    to: '[name].[ext]'
  },
  {
    from: 'src/md/*.md',
    to: '[name].[ext]'
  }
];

module.exports = {
  entry: {
    "shiny_app": [
      "./src/scss/_build.scss",
      "./src/js/_build.js"
    ]
  },
  output: {
    path: path.resolve("./www/"),
    clean: true
  },
  mode: "production",
  devtool: "source-map",
  module: {
    rules: [
      {
        test: /\.scss$/,
        use: [
          {
            loader: MiniCssExtractPlugin.loader,
          },
          {
            loader: "css-loader",
            options: {
              sourceMap: true,
              url: false,
            },
          },
          {
            loader: "sass-loader",
            options: {
              implementation: require("sass")
            }
          }
        ]
      },
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: "babel-loader"
      },
    ]
  },
  plugins: [
    // delete existing packed assets
    new CleanWebpackPlugin({
      cleanOnceBeforeBuildPatterns: ["./www"]
    }),
    // minify CSS
    new MiniCssExtractPlugin(),
    // static copy of files
    new CopyPlugin({
      patterns: copyFiles
    }),
    // clean up
    new RemoveEmptyScriptsPlugin(),
  ]
};
