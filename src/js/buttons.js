/**
  Handling of button clicks in JS
 */
import { activate_panel, deactivate_panel } from "./events.js"

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
}

export {
  bind_button_actions
};
