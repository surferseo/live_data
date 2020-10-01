import 'core-js/es6/map'
import 'core-js/es6/set'
import { Socket } from 'phoenix'

import React from 'react'
import ReactDOM from 'react-dom'

import './index.css'
import App from './App/App'

const root = document.getElementById('root')

let reactSocket = new Socket('/react_gen_server')
reactSocket.connect()

ReactDOM.render(<App socket={reactSocket} />, root)
