/**
  UI related scripts
 */


/**
  Updates labels on the Radius slider to be more context friendly
  @return {void}
 */
const slider_context_labels = () => {
  console.log("Update slider context labels");
  const labels = document.getElementsByClassName("irs-grid-text");
  for (const label of labels) {
    try {
      const value = parseFloat(label.innerHTML);
      (value < 1) && (label.innerHTML = `${parseInt(value * 1000)} m`);
      (value >= 1) && (label.innerHTML = `${parseInt(value)} km`);
    } catch (error) {
      continue;
    }
  }
}

export {
  slider_context_labels
}