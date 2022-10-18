/**
  Handle search functions
 */

/**
  Query the openstreetmaps nominatim API with the query term
  bounded by Melbourne coordinates
  @param {string} query The search query.
  @return {array} An array of objects returned from the API.
  @note Response will return empty array if non-found or error.
  @see https://nominatim.org/release-docs/develop/api/Search/
 */
const search_osm = async (query) => {
  // The URL endpoint
  const url = new URL("https://nominatim.openstreetmap.org/search");
  
  // Append params to the url
  const params = {
    "format": "json",
    "countrycodes": "au",
    "viewbox": "144.93366,-37.79264,144.97670,-37.82391",
    "bounded": "1",
    "q": query
  }
  
  for (let param in params) {
    url.searchParams.append(param, params[param])
  }
  
  console.log(`Query URL: ${url}`)
  on_search_go();
  
  const response_json = await fetch(url)
  .then((result) => {
    if (result.status != 200) { throw new Error("Bad Server Response"); }
    return result.json();
  })
  .then((json) => {
    return json
  })
  .catch((error) => {
    console.log(`Error in query: ${error}`)
    return []
  })
  .finally(() => {
    on_search_done();
  });
  
  console.log(`Response JSON:`, response_json);
  return response_json
}

/**
  Renders the search results in the SearchResults panel
  @param {array} json the search results as an array of objects
  @return {void}
 */
const render_search_results = (json) => {
  const res_panel = document.querySelector("[data-value='SearchResults'].tab-pane");
  
  res_panel.innerHTML = "";
  const res_elements = json.map((result) => {
    // Wrapper
    const wrapper = document.createElement("div");
    wrapper.classList.add("result-wrapper");
    
    // Wrangle the display_name
    const display_names = osm_display_name(result);
    
    // Bind click event to wrapper
    wrapper.addEventListener("click", (event) => {
      const input = document.getElementById("search-input");
      
      /** @fires set:loc */
      input.dispatchEvent(
        new CustomEvent("set:loc", {"detail": result})
      );
      
      /** @fires close:panel */
      document.querySelector("[data-value='SearchResults'].tab-pane")
        .dispatchEvent(new CustomEvent("close:panel", {"detail": result}));
      
      // Sets the search input box to display the selected name
      input.value = display_names[0] || "Unknown name";
      
      // Close the panel
      close_search_results();
      
      // Clean up any other indicators
      remove_gps_indicator();
    });
    
    // Create internal elements
    const name = document.createElement("div");
    name.classList.add("result-name");
    name.innerHTML = display_names[0] || "Unknown name";
    
    const loc = document.createElement("div");
    loc.classList.add("result-loc");
    loc.innerHTML = display_names[1] && display_names.slice(1).join(" ")
      || "Unknown location";
    
    wrapper.appendChild(name);
    wrapper.appendChild(loc);
    
    return wrapper;
  })
  
  // Check that there are elements in res_elements, if not, add a message
  if (res_elements.length < 1) {
    search_res_alert("No results found, please try again.");
  }
  
  // Add elements to the res_panel
  res_panel.append(... res_elements);
  
  // Open the panel after results have been rendered
  open_search_results();
}

/**
  Renders a contextual message inside the search results panel
  @param {string} message the alert message
  @param {boolean} [open_panel=false] whether or not to trigger the panel opening
  @returns {void}
 */
const search_res_alert = (message, open_panel = false) => {
  const res_panel = document.querySelector("[data-value='SearchResults'].tab-pane");
  
  // Reset panel contents and add the message
  res_panel.innerHTML = "";
  const msg = document.createElement("div");
  msg.classList.add("result-none");
  msg.innerHTML = message;
  res_panel.append(msg);
  
  // Open the panel if required
  open_panel && open_search_results();
}

/**
  Wrangle the display_name from Openstreetmap search results
  @param {object} obj
  @returns {array} of string
 */
const osm_display_name = (obj) => {
  return obj.display_name && obj.display_name.split(",") || [];
}

/**
  Aligns the position of the SearchResults panel and opens it
  @returns {void}
 */
const open_search_results = () => {
  const res_panel = document.querySelector("[data-value='SearchResults'].tab-pane");
  const input_wrapper = document.getElementById("search-input").closest(".wrapper");
  const {
    bottom:y, width
  } = input_wrapper.getBoundingClientRect();
  
  res_panel.style.top = `${y}px`;
  res_panel.style.width = `${width}px`;
  res_panel.classList.add("active");
}

/**
  Closes the SearchResults panel
 */
const close_search_results = () => {
  const res_panel = document.querySelector("[data-value='SearchResults'].tab-pane");
  res_panel.classList.remove("active");
}

/**
  On click event handler for the search box button
 */
const search_panel_go = async () => {
  // Get the search query from the search input box
  const query = document.getElementById("search-input").value;
  
  // Query the API
  const results = await search_osm(query);
  
  // Render the search results
  render_search_results(results);
}

/**
  Task runner for when a search is initiated
  @returns {void}
  @fires search:busy
 */
const on_search_go = () => {
  // Apply styling changes
  const panel = document.querySelector("[data-value='Search'].tab-pane");
  panel && panel.classList.add("busy");
  
  // Dispatch event
  document.getElementById("search-input").dispatchEvent(
    new CustomEvent("search:busy")
  )
}

/**
  Task runner for when a search has been completed
  @returns {void}
  @fires search:done
 */
const on_search_done = () => {
  // Apply styling changes
  const panel = document.querySelector("[data-value='Search'].tab-pane");
  panel && panel.classList.remove("busy");
  
  // Dispatch event
  document.getElementById("search-input").dispatchEvent(
    new CustomEvent("search:done")
  )
}

/**
  Uses the user's geolocation as the map location
 */
const use_geolocation = () => {
  const on_success = (location) => {
    //location.coords.[latitude, longitude]
    const {coords: {
      latitude:lat, longitude:lon
    }} = location;
    const input = document.getElementById("search-input");
      
    /** @fires set:loc */
    input.dispatchEvent(
      new CustomEvent("set:loc", {"detail": {lat, lon}})
    );
    
    search_res_alert("Current GPS location set.", true);
    set_gps_indicator();
  }
  
  const on_failure = (reason) => {
    //reason.message
    search_res_alert(reason.message, true);
  }
  
  // Query the navigator geolocation service
  navigator.geolocation &&
  navigator.geolocation.getCurrentPosition(on_success, on_failure);
}

/**
  Adds styling to the GPS icon
  @returns {void}
 */
const set_gps_indicator = () => {
  const icon = document.getElementById("button-gps");
  icon.classList.add("active");
}

/**
  Removes styling to the GPS icon
  @returns {void}
 */
const remove_gps_indicator = () => {
  const icon = document.getElementById("button-gps");
  icon.classList.remove("active");
}

/**
  Bind tasks related to search events
  @returns {void}
  @listens search:busy
  @listens search:done
  @listens set:loc
 */
const bind_search_events = () => {
  const res_panel = document.querySelector("[data-value='SearchResults'].tab-pane");
  const input = document.getElementById("search-input");
  // On search go
  input.addEventListener("search:busy", (event) => {
    
  })
  
  // On search done
  input.addEventListener("search:done", (event) => {
    // Show ShowResults
  })
  
  // On results selection
  input.addEventListener("set:loc", (event) => {
    const {detail:data} = event
    data && Shiny && Shiny.setInputValue("js_set_loc", data);
  })
}

export {
  search_osm,
  search_panel_go,
  on_search_go,
  on_search_done,
  bind_search_events,
  open_search_results,
  close_search_results,
  use_geolocation
}