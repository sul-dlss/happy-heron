import Dropzone from "dropzone";
import { Controller } from "stimulus";
import { DirectUpload } from "@rails/activestorage";
import {
  getMetaValue,
  findElement,
  removeElement,
} from "../helpers";

export default class extends Controller {
  static targets = ["input", "previewsContainer", "preview", "template", "feedback", "container", "fileName"];

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
    if (this.fileCount == 0) {
      this.disableSubmission()
    }
  }

  checkForDuplicates(file) {
    const fileName = file.fullPath || file.webkitRelativePath || file.name
    // Extract all filenames that are visible
    const fileNames = this.fileNameTargets.map(target => {
      if (target.offsetParent !== null) return target.innerText.trim().split(": ")[0]
    })

    // Remove current fileName
    fileNames.splice(fileNames.indexOf(fileName), 1)
    return fileNames.indexOf(fileName) > -1
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
      // No hidden files
      if(file.name.startsWith('.')) {
        this.dropZone.removeFile(file)
        return
      }
      setTimeout(() => {        
        file.accepted && createDirectUploadController(this, file).start();
        this.fileCount++
        this.enableSubmission()
        if (this.checkForDuplicates(file)) {
          this.dropZone.emit("error", file, 'Duplicate file');
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
      file.previewElement.querySelector('.hidden-file').classList.add('is-invalid')
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

  get folders() {
    return this.data.get("folders") || false;
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
    this.overrideDisplayedFileName();
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

  overrideDisplayedFileName() {
    const fullpath = this.file.fullPath || this.file.webkitRelativePath
    if (fullpath) {
      findElement(
        this.file.previewTemplate,
        "[data-dz-name]"
      ).innerText = fullpath
    }
  }

  addDescription() {
    const detail = this.file.previewElement.querySelector('.upload-description')
    detail.innerHTML = detail.innerHTML.replace(/TEMPLATE_RECORD/g, this.count)
  }

  addHideCheckbox()   {
    const detail = this.file.previewElement.querySelector('.dz-details')
    detail.innerHTML = detail.innerHTML.replace(/TEMPLATE_RECORD/g, this.count)
  }

  createHiddenPathInput() {
    const input = document.createElement("input")
    input.type = "hidden"
    input.name = `work[attached_files_attributes][${this.count}][path]`
    input.value = this.file.fullPath || this.file.webkitRelativePath 
    this.file.previewElement.appendChild(input)
  }

  createHiddenFileInput() {
    const input = document.createElement("input");
    input.type = "hidden";
    input.classList.add('hidden-file')
    input.name = `work[attached_files_attributes][${this.count}][file]`
    this.file.previewElement.appendChild(input);
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
    clickable: controller.folders ? '.dz-clickable-folders' : '.dz-clickable',
    autoQueue: false,
    init: function() {
      if(controller.folders) this.hiddenFileInput.setAttribute("webkitdirectory", true);
    }
  });
}
