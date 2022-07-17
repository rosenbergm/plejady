import { Elm } from './Hello.elm'

Elm.Hello.init({
  node: document.getElementById('app'),
  flags: "Initial Message"
})
