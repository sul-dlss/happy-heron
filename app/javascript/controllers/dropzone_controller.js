import Dropzone from "dropzone";
import { Controller } from "@hotwired/stimulus";
import { DirectUpload } from "@rails/activestorage";
import {
  getMetaValue,
  findElement,
  removeElement,
} from "../helpers";

export default class extends Controller {
  static targets = ["input", "previewsContainer", "preview", "template", "feedback", "container"];

  connect() {
    this.dropZone = createDropZone(this, this.templateTarget.innerHTML)
    this.hideFileInput()
    this.fileCount = this.previewTargets.length
    this.done = true
    this.validate()
    this.bindEvents()
    Dropzone.autoDiscover = false // necessary quirk for Dropzone error in console
  }

  // Private
  hideFileInput() {
    this.inputTarget.style.display = "none"
  }

  validate() {
    if (this.fileCount == 0 && this.required) {
      this.disableSubmission()
    }
  }

  checkForDuplicates(fileName) {
    // Extract all filenames that are visible
    // Unfortunately, the filename targets are not contained in the scope of the controller.
    // Get them directly from the DOM.
    const filepath = this.dirPath ? `${this.dirPath}/${fileName}` : fileName
    const fileNameNodes = Array.from(document.querySelectorAll('[data-dropzone-path]'))

    const filepaths = fileNameNodes.map(fileNameNode => {
        const path = fileNameNode.getAttribute('data-dropzone-path')
        const filename = fileNameNode.innerText.trim()

        const item = fileNameNode.closest('.dz-complete')
        if(item && item.querySelector("input[name*='_destroy']").value == 1) return null

        return path ? `${path}/${filename}` : filename
    })

    // Remove current fileName
    filepaths.splice(filepaths.indexOf(filepath), 1)

    return filepaths.indexOf(filepath) > -1
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
    item.querySelector('input.hidden-file')?.classList.remove('is-invalid')
    this.fileCount--
    this.validate()
    this.displayValidateMessage()
  }

  // Tell the EditDepositController to update
  informProgress() {
    this.inputTarget.dispatchEvent(new Event('change'))
  }

  bindEvents() {
    this.dropZone.on("addedfile", file => {
      setTimeout(() => {
        file.accepted && createDirectUploadController(this, file).start();
        this.fileCount++
        this.enableSubmission()
        if (this.checkForDuplicates(file.name)) {
          this.dropZone.emit("error", file, 'Duplicate file');
        }
        if(this.maxFiles && this.fileCount > this.maxFiles) {
          this.dropZone.emit("error", file, `Too many files. Maximum is ${this.maxFiles}`);
        }

      }, 500);
      this.done = false
    });

    this.dropZone.on("removedfile", file => {
      file.controller && removeElement(file.controller.hiddenInput)
      this.informProgress()
    });

    this.dropZone.on("canceled", file => {
      file.controller && file.controller.xhr.abort();
    });

    this.dropZone.on("error", (file, error) => {
      file.status = Dropzone.ERROR;
      file.previewElement.querySelector('.upload-description').style.display = 'none'
      file.previewElement.querySelector('.dz-details').style.display = 'none'
      file.previewElement.querySelector('.thumb img').style.display = 'none'
      const feedbackElem = file.previewElement.querySelector('.invalid-feedback')
      feedbackElem.style.display = 'none'
      feedbackElem.innerText = `Unable to upload file due to: ${error}. Delete the file and try again.`
      file.previewElement.querySelector('.invalid-feedback').style.display = 'block'
      file.previewElement.querySelector('.dz-upload').classList.remove('dz-upload-success')
      file.previewElement.querySelector('.dz-upload').classList.add('dz-upload-error')
      file.previewElement.querySelector('.dz-error-mark').style.display = 'block'
      file.previewElement.querySelector('.dz-success-mark').style.display = 'none'
      // is-invalid needs to be on the hidden-file input for validation
      file.previewElement.querySelector('.hidden-file')?.classList?.add('is-invalid')
    })

    this.dropZone.on("complete", () => {
      this.informProgress()
    })

    this.dropZone.on("queuecomplete", () => {
      this.done = true
    })

    this.inputTarget.form.addEventListener('submit', (evt) => {
      if (!this.done) {
        alert("Deposit will be enabled once files have finished uploading")
        evt.preventDefault()
        evt.stopPropagation()
      } else {
        this.displayValidateMessage()
      }
    }, false)
  }

  get headers() {
    return { "X-CSRF-Token": getMetaValue("csrf-token") };
  }

  get url() {
    return this.inputTarget.getAttribute("data-direct-upload-url");
  }

  get required() {
    return this.data.get("required") !== "false";
  }

  get dirPath() {
    return this.data.get("dirPath");
  }

  get maxFiles() {
    return this.data.get("maxFiles");
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

  get clickable() {
    return this.data.get("clickable") || '.dz-clickable';
  }

  get previewsContainer() {
    return this.data.get("previewsContainer") || '.dropzone-previews';
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
    this.hiddenInput = this.createHiddenFileInput();
    this.createHiddenPathInput();
    this.addDescription();
    this.addHideCheckbox();
    this.directUpload.create((error, attributes) => {
      // If the file is named dropzone_error.txt it will trigger an error for testing.
      if (error || attributes['filename'] == 'dropzone_error.txt') {
        // Note that setCustomValidity doesn't invalidate a hidden input, so setting class instead.
        this.hiddenInput.classList.add('is-invalid')
        this.emitDropzoneError(error || 'Test error');
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

  addHideCheckbox()   {
    const detail = this.file.previewElement.querySelector('.dz-details')
    detail.innerHTML = detail.innerHTML.replace(/TEMPLATE_RECORD/g, this.count)
  }

  createHiddenFileInput() {
    const input = document.createElement("input");
    input.type = "hidden";
    input.classList.add('hidden-file')
    input.name = `work[attached_files_attributes][${this.count}][file]`
    input.setAttribute("aria-label", "hidden file");
    this.file.previewElement.appendChild(input);
    return input;
  }

  createHiddenPathInput() {
    const input = document.createElement("input")
    input.type = "hidden"
    input.name = `work[attached_files_attributes][${this.count}][path]`
    input.value = this.source.dirPath ? `${this.source.dirPath}/${this.file.name}` : this.file.name
    input.setAttribute("aria-label", "hidden path");
    this.file.previewElement.appendChild(input)
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
    maxFiles: 1000,
    maxFilesize: controller.maxFileSize,
    acceptedFiles: controller.acceptedFiles,
    addRemoveLinks: controller.addRemoveLinks,
    previewTemplate: template,
    previewsContainer: controller.previewsContainer,
    thumbnailHeight: 42,
    thumbnailWidth: 34,
    clickable: controller.clickable,

    autoQueue: false
  });
}
