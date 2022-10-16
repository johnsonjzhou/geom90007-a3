/**
  Scripts used in the Shiny app
 */

import { check_user_agent } from "./user_agent.js";
import { load_event_handlers } from "./events.js";
import { bind_button_actions } from "./buttons";
import { slider_context_labels } from "./ui.js";
import { search_osm } from "./search.js";

(($, L) => {
  
  load_event_handlers();
  
  L.markerClusterGroup = (options) => {
    window.clusters = new L.MarkerClusterGroup(options);
    console.log("Clusters", window.clusters);
    return window.clusters;
  }
  
  window.onload = () => {
    check_user_agent();
    window.search = search_osm
    
    if (window.L.markerClusterGroup) {
      window.L.markerClusterGroup = (options) => {
        window.clusters = new L.MarkerClusterGroup(options);
        console.log("Clusters", window.clusters);
        return window.clusters;
      }
      console.log("L");
      // Object.freeze(window.L);
    }
  }
  
  // When shiny has loaded
  $(document).on("shiny:sessioninitialized", (event) => {
    bind_button_actions();
    slider_context_labels();
  })
  
})($, L)