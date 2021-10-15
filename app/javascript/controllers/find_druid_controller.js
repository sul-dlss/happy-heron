import { Controller } from "stimulus";

export default class extends Controller {
  onFailure(e) {
    alert("Druid was not found")
  }
}
