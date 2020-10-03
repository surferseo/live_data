/**
 * LiveData JavaScript client TODO - More docs..
 *
 * ## Connection
 *
 * A single connection is established to the server....
 *
 * ```javascript
 * let ldSocket = new LiveDataSocket({params: {userToken: "123"}})
 * ```
 *
 */

import { Socket } from "phoenix";
import { v4 as uuidv4 } from "uuid";
import { applyPatch } from "fast-json-patch";

/**
 * LiveDataSocketOpts class constructor Opts
 * @typedef {Object} LiveDataSocketOpts
 * @property {string} path - Path to connect to socket, defaults to `/live_data_socket`
 * @property {Object} params - socket connect params
 * @property {Object} context - A context object to attach socket to - defaults to the window.
 */

/**
 * LiveData Class Constructor Opts
 * @typedef {Object} LiveDataOpts
 * @property {Object} socket - live data socket used to connect to channel, falls back to context socket if not supplied.
 * @property {string} name - name of the LiveData component - REQUIRED
 * @property {string} id - unique instance id of LiveData Component - auto generated uuidv4 if not supplied
 * @property {function} onDiff - Callback with single parameter invoked on each diff
 * @property {Object} context - A context object to attach socket to - defaults to the window.
 */

export function uuid() {
  return uuidv4();
}

/** Class for LiveData socket singleton - should only be one of these on the page? */
export class LiveDataSocket extends Socket {
  /**
   * Create a LiveDataSocket Instance
   * @param {LiveDataSocketOpts} opts
   */
  constructor(opts = {}) {
    super(opts.path || "/live_data_socket", opts.params);
    // window is used as
    let context = opts.context || window;
    context.LIVE_DATA_SOCKET = this;
    this.connect();
  }
}

/** Class for LiveData Component instances. */
export class LiveData {
  /**
   * Create a LiveData Component Instance
   * @param {LiveDataOpts} opts
   */
  constructor(opts = {}) {
    // super();
    this.state = {};
    this.onDiff = opts.onDiff || this._defaultCB;
    this.name = opts.name;
    this.id = opts.id || uuid();
    let context = opts.context || window;
    this.socket = opts.socket || context.LIVE_DATA_SOCKET;
    this.channel = this.socket.channel(`${this.name}:${this.id}`, opts.params);
  }

  currentState() {
    return this.state;
  }

  connect() {
    this.channel.on("diff", this._handleDiff);
    this.channel.join().receive("ok", (resp) => {
      console.log(`Joined ${this.name}:${this.id} successfully`, resp);
    });

    return () => {
      this.channel.leave();
    };
  }

  push = (msg, params) => {
    this.channel.push(msg, params);
  };

  _defaultCB = (newState) => {
    console.log(newState);
  };

  _handleDiff = ({ diff }) => {
    const { newDocument } = applyPatch(this.state, diff, false, false);
    this.onDiff(newDocument);
  };
}
