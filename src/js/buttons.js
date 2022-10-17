/**
  Handling of button clicks in JS
 */
import { activate_panel, deactivate_panel } from "./events.js"
import { search_panel_go, close_search_results } from "./search.js";

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
          close_search_results();
        default:
      }
    }
  )
  
  // Global click events
  document.addEventListener("click", (event) => {
    // Close the SearchResults panel
    const res_panel = document.querySelector("[data-value='SearchResults'].tab-pane");
    (event.target != res_panel) && close_search_results();
  });
}

export {
  bind_button_actions
};
