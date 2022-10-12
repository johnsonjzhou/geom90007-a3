/**
  Scripts used in the Shiny app
 */

import { check_user_agent } from "./user_agent.js"
import { load_event_handlers } from "./events.js"

(() => {
  
  load_event_handlers();
  
  window.onload = () => {
    check_user_agent();
  }
  
})()