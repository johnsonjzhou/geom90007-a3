/**
  Scripts handling the behaviour for Intro page
 */

const on_intro_btn_click = (event) => {
  console.log(event);
  const direction = event.target.attributes.direction.nodeValue;
  const intro_pane = document.querySelector("[data-value='Intro'].tab-pane");
  const page_limit = intro_pane.getElementsByClassName("page").length;
  
  // Get current page number
  let page = 1;
  intro_pane.classList.forEach((cls) => {
    if (cls.startsWith("page")) {
      page = parseInt(cls.split("-")[1]);
    }
  });
  
  // Change the page
  switch (direction) {
    case "left":
      if (page > 1) {
        intro_pane.classList.remove(`page-${page}`);
        intro_pane.classList.add(`page-${page - 1}`);
      }
    break;
    case "right":
      if (page < page_limit)  {
        intro_pane.classList.remove(`page-${page}`);
        intro_pane.classList.add(`page-${page + 1}`);
      }
      
      if (page == 3) {
        intro_pane.classList.remove("active");
      }
    break;
  }
}

/**
  Binds click events to buttons
  @returns {void}
 */
const bind_intro_actions = () => {
  const btn_left = document.getElementById("intro-left");
  const btn_right = document.getElementById("intro-right");
  
  btn_left.addEventListener("click", on_intro_btn_click);
  btn_right.addEventListener("click", on_intro_btn_click);
}

/**
  Show the intro panel on first run
  @return {void}
 */
const on_first_run = () => {
  const firstrun =
      window.localStorage && window.localStorage.getItem('firstrun');
    
  if (firstrun) return;
  
  const intro_pane = document.querySelector("[data-value='Intro'].tab-pane");
  intro_pane.classList.add("active");
  window.localStorage && window.localStorage.setItem('firstrun', 'shown');
}

export {
  bind_intro_actions,
  on_first_run
}