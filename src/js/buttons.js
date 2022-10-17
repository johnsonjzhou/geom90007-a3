/**
  Handling of button clicks in JS
 */
import { activate_panel, deactivate_panel } from "./events.js"
import { search_osm } from "./search.js";

/**
  Shows and hides the Filters panel
  @return void
 */
const filters_show_hide = () => {
  const panel = document.querySelector("[data-value='Filters'].tab-pane");
    panel.classList.contains("active")
      && deactivate_panel(panel) || activate_panel(panel)
}

/**
  On click event handler for the search box button
 */
const search_panel_go = async () => {
  // Get the search query from the search input box
  const query = document.getElementById("search-input").value;
  
  // Query the API
  const results = await search_osm(query);
  
  // Send the results to Shiny
  Shiny && Shiny.setInputValue("search_result", results);
}

/**
  Binds actions to custom buttons
  @return void
 */
const bind_button_actions = () => {
  // Filters panel toggle
  document.getElementById("filters-show-hide").addEventListener(
    "click", filters_show_hide
  )
  
  // Search panel go button
  document.getElementById("button-search").addEventListener(
    "click", search_panel_go
  )
  
  // Keypress events at the search input
  document.getElementById("search-input").addEventListener(
    "keydown",
    (event) => {
      switch(event.key) {
        case "Enter":
          event.preventDefault();
          event.stopPropagation();
          search_panel_go();
        break;
        case "Escape":
          event.preventDefault();
          event.stopPropagation();
          event.target.blur();
        default:
      }
    }
  )
}

export {
  bind_button_actions
};
