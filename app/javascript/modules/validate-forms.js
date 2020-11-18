// Example starter JavaScript for disabling form submissions if there are invalid fields
(function () {
  'use strict'
  window.addEventListener('turbolinks:load', function() {
    // Fetch all the forms we want to apply custom Bootstrap validation styles to
    var forms = document.querySelectorAll('.needs-validation')

    // Loop over them and prevent submission
    Array.prototype.slice.call(forms)
      .forEach(function (form) {
        form.addEventListener('submit', function (event) {
          console.dir(event)
          // if (event.submitter.id === 'save-draft-button') return // do not run client side validation for saving drafts
          // if (!form.checkValidity()) {
          //   event.preventDefault()
          //   event.stopPropagation()
          // }
        }, false)
      })
  })
})()
