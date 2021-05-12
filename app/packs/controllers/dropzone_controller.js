import Dropzone from "dropzone";
import { Controller } from "stimulus";
import { DirectUpload } from "@rails/activestorage";
import {
  getMetaValue,
  toArray,
  findElement,
  removeElement,
  insertAfter
} from "helpers";

export default class extends Controller {
  static targets = ["input", "previewsContainer", "preview", "template", "feedback", "container"];

  connect() {
    this.dropZone = createDropZone(this, this.templateTarget.innerHTML)
    this.hideFileInput()
    this.fileCount = this.previewTargets.length
    this.validate()
    this.bindEvents()
    this.inputTarget.form.onsubmit = (form) => {
      this.displayValidateMessage()
    }
    Dropzone.autoDiscover = false // necessary quirk for Dropzone error in console
  }

  // Private
  hideFileInput() {
    this.inputTarget.style.display = "none"
  }

  validate() {
    if (this.fileCount == 0) {
      this.disableSubmission()
    }
  }

  displayValidateMessage() {
    // Because the feedback isn't a sibling of the input field, we can't simply
    // rely on the bootstrap selector to display the message
    if (this.inputTarget.checkValidity()) {
      this.containerTarget.classList.remove("is-invalid")
      this.feedbackTarget.style.display = 'none'
    } else {
      this.containerTarget.classList.add("is-invalid")
      this.feedbackTarget.style.display = 'block'
    }
  }

  disableSubmission() {
    this.inputTarget.disabled = false // block the form from submitting
    this.inputTarget.setCustomValidity("you must upload a file")
  }

  enableSubmission() {
    this.inputTarget.disabled = true // don't send the value with the form.
    this.inputTarget.setCustomValidity("")
    this.displayValidateMessage()
  }

  removeAssociation(event) {
    event.preventDefault()
    const item = event.target.closest('.dz-complete')
    item.querySelector("input[name*='_destroy']").value = 1
    item.style.display = 'none'
    this.fileCount--
    this.validate()
    this.displayValidateMessage()
  }

  // Tell the ProgressController to update
  informProgress() {
    this.inputTarget.dispatchEvent(new Event('change'))
  }

  bindEvents() {
    this.dropZone.on("addedfile", file => {
      setTimeout(() => {
        file.accepted && createDirectUploadController(this, file).start();
        this.fileCount++
        this.enableSubmission()
      }, 500);
    });

    this.dropZone.on("removedfile", file => {
      file.controller && removeElement(file.controller.hiddenInput)
      this.informProgress()
    });

    this.dropZone.on("canceled", file => {
      file.controller && file.controller.xhr.abort();
    });

    this.dropZone.on("complete", () => {
      this.informProgress()
    })
  }

  get headers() {
    return { "X-CSRF-Token": getMetaValue("csrf-token") };
  }

  get url() {
    return this.inputTarget.getAttribute("data-direct-upload-url");
  }

  get maxFiles() {
    return this.data.get("maxFiles") || 1;
  }

  get maxFileSize() {
    return this.data.get("maxFileSize") || 256;
  }

  get acceptedFiles() {
    return this.data.get("acceptedFiles");
  }

  get addRemoveLinks() {
    return this.data.get("addRemoveLinks") || false;
  }
}

class DirectUploadController {
  // source is the input element
  // file is the File object from dropzone
  constructor(source, file) {
    this.count = Math.floor(Math.random() * 1_000_000_000)
    this.directUpload = createDirectUpload(file, source.url, this);
    this.source = source;
    this.file = file;
  }

  start() {
    this.file.controller = this;
    this.hiddenInput = this.createHiddenInput();
    this.addDescription();
    this.addHideCheckbox();
    this.directUpload.create((error, attributes) => {
      if (error) {
        removeElement(this.hiddenInput);
        this.emitDropzoneError(error);
      } else {
        this.hiddenInput.value = attributes.signed_id;
        this.emitDropzoneSuccess();
      }
    });
  }

  addDescription() {
    const detail = this.file.previewElement.querySelector('.upload-description')
    detail.innerHTML = detail.innerHTML.replace(/TEMPLATE_RECORD/g, this.count)
  }

  addHideCheckbox() {
    const detail = this.file.previewElement.querySelector('.dz-details')
    detail.innerHTML = detail.innerHTML.replace(/TEMPLATE_RECORD/g, this.count)
  }

  createHiddenInput() {
    const input = document.createElement("input");
    input.type = "hidden";
    input.name = `work[attached_files_attributes][${this.count}][file]`
    insertAfter(input, this.source.previewsContainerTarget);
    return input;
  }

  directUploadWillStoreFileWithXHR(xhr) {
    this.bindProgressEvent(xhr);
    this.emitDropzoneUploading();
  }

  bindProgressEvent(xhr) {
    this.xhr = xhr;
    this.xhr.upload.addEventListener("progress", event =>
      this.uploadRequestDidProgress(event)
    );
  }

  uploadRequestDidProgress(event) {
    const element = this.source.element;
    const progress = (event.loaded / event.total) * 100;
    findElement(
      this.file.previewTemplate,
      ".dz-upload"
    ).style.width = `${progress}%`;
  }

  emitDropzoneUploading() {
    this.file.status = Dropzone.UPLOADING;
    this.source.dropZone.emit("processing", this.file);
  }

  emitDropzoneError(error) {
    this.file.status = Dropzone.ERROR;
    this.source.dropZone.emit("error", this.file, error);
    this.source.dropZone.emit("complete", this.file);
  }

  emitDropzoneSuccess() {
    this.file.status = Dropzone.SUCCESS;
    this.source.dropZone.emit("success", this.file);
    this.source.dropZone.emit("complete", this.file);
  }
}

function createDirectUploadController(source, file) {
  return new DirectUploadController(source, file);
}

function createDirectUpload(file, url, controller) {
  return new DirectUpload(file, url, controller);
}

function createDropZone(controller, template) {
  return new Dropzone(controller.element, {
    url: controller.url,
    headers: controller.headers,
    maxFiles: controller.maxFiles,
    maxFilesize: controller.maxFileSize,
    acceptedFiles: controller.acceptedFiles,
    addRemoveLinks: controller.addRemoveLinks,
    previewTemplate: template,
    previewsContainer: ".dropzone-previews",
    thumbnailHeight: 42,
    thumbnailWidth: 34,
    clickable: '.dz-clickable',

    autoQueue: false
  });
}
