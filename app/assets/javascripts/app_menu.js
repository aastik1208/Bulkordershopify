var eventName = typeof(Turbolinks) !== 'undefined' ? 'turbolinks:load' : 'DOMContentLoaded';

if (!document.documentElement.hasAttribute("data-turbolinks-preview")) {
  document.addEventListener(eventName, function flash() {
    var titleDiv = document.getElementById('shopify-app-page-title');
    var TitleBar = window['app-bridge'].actions.TitleBar;

    if(titleDiv)
    {
      TitleBar.create(app, {
        title: titleDiv.dataset.title
      });
    }

  });
}
