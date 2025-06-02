// click-away.js (Vue 3 Version)

const clickOutsideDirective = {
  beforeMount(el, binding) {
    el.clickOutsideEvent = function(event) {
      // Check if the click was outside the el and its children
      if (!(el === event.target || el.contains(event.target))) {
        // If it was, call the method provided in the binding's value
        // binding.value is the function to call
        if (binding.value && typeof binding.value === 'function') {
          binding.value(event);
        }
      }
    };
    document.addEventListener('click', el.clickOutsideEvent);
    document.addEventListener('touchstart', el.clickOutsideEvent); // For touch devices
  },
  unmounted(el) {
    document.removeEventListener('click', el.clickOutsideEvent);
    document.removeEventListener('touchstart', el.clickOutsideEvent);
  },
};

export default clickOutsideDirective;