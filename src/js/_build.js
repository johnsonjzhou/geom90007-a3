/**
  Scripts used in the Shiny app
 */

import { check_user_agent } from "./user_agent.js"

(() => {
  
  load_event_handlers();
  
  window.onload = () => {
    check_user_agent();
  }
  
})()