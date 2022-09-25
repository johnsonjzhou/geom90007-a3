/**
  Checks the user agent and loads a helpful message
 */
const check_user_agent = () => {
  // pop up message for WebQTEngine browsers (built in)
  navigator.userAgent.includes("QtWebEngine") &&
    window.alert("For best effect, please use an external browser.");
};

export {
  check_user_agent
};