/**
  Scripts used in the Shiny app
 */

import { check_user_agent } from "./user_agent.js"
import { load_event_handlers } from "./events.js"
import { bind_button_actions } from "./buttons"

(($) => {
  
  load_event_handlers();
  
  window.onload = () => {
    check_user_agent();
  }
  
  // When shiny has loaded
  $(document).on("shiny:sessioninitialized", (event) => {
    bind_button_actions();
  })
  
})($)