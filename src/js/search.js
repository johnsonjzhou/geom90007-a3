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
  });
  
  console.log(`Response JSON:`, response_json);
  return response_json
}

export {
  search_osm
}