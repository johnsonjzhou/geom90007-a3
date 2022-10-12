/**
  Handling of reactive event messages from Shiny
 */

/**
  Opens a tabPanel while adding effects
  @param {DOMElement} panel a DOM element representing a Shiny tabPanel
  @param {boolean} [dimmer=true] whether to toggle dimmer panel
  @return void
 */
const activate_panel = (panel, apply_dimmer = true) => {
  const dimmer = document.querySelector("[data-value='Dimmer'].tab-pane");
  panel && panel.classList.add("active");
  panel && apply_dimmer && dimmer.classList.add("dim");
}

/**
  Closes a tabPanel while adding effects
  @param {DOMElement} panel a DOM element representing a Shiny tabPanel
  @param {boolean} [dimmer=true] whether to toggle dimmer panel
  @return void
 */
const deactivate_panel = (panel, apply_dimmer = true) => {
  const dimmer = document.querySelector("[data-value='Dimmer'].tab-pane");
  panel && panel.classList.remove("active");
  panel && apply_dimmer && dimmer.classList.remove("dim");
}

/**
  Loads and binds event handlers for Shiny custom messages
  @return void
 */
const load_event_handlers = () => {
  // Open the About panel
  Shiny && Shiny.addCustomMessageHandler("filters_panel_toggle", (message) => {
    const panel = document.querySelector("[data-value='Filters'].tab-pane");
    panel.classList.contains("active")
      && deactivate_panel(panel) || activate_panel(panel)
  })
}

export {
  load_event_handlers
};
