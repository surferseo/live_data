const path = require("path");

module.exports = {
  entry: "./src/live-data.js",
  output: {
    filename: "live-data.js",
    path: path.resolve(__dirname, "../priv/static"),
    library: "@live-data/core",
    libraryTarget: "umd",
    globalObject: "this",
  },
  module: {
    rules: [
      {
        test: path.resolve(__dirname, "./src/live-data.js"),
        use: [
          {
            loader: "expose-loader",
            options: "@live-data/core",
          },
        ],
      },
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: "babel-loader",
        },
      },
    ],
  },
  plugins: [],
};
