const path = require("path");

module.exports = {
  entry: "./src/liveData.js",
  output: {
    filename: "liveData.js",
    path: path.resolve(__dirname, "../priv/static"),
    library: "LiveData",
    libraryTarget: "umd",
    globalObject: "this",
  },
  module: {
    rules: [
      {
        test: path.resolve(__dirname, "./src/liveData.js"),
        use: [
          {
            loader: "expose-loader",
            options: "LiveData",
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
