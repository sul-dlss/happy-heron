// Prevent selected fields from submitting the form
(function () {
  'use strict'
  window.addEventListener('turbolinks:load', function() {
    // Fetch all the forms we want to apply custom Bootstrap validation styles to
    var preventSubmittingInputs = document.querySelectorAll('.prevent-submit')

    // Loop over them and prevent submission
    Array.prototype.slice.call(preventSubmittingInputs)
      .forEach(function (input) {
        input.addEventListener('keypress', function (e) {
          // if (e.key === 'Enter') {
          //   e.preventDefault()
            // e.stopPropagation()
            // return false
          // }
        })
      })
  })
})()
