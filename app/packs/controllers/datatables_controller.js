import { Controller } from "stimulus"
import { DataTable } from "simple-datatables"

export default class extends Controller {
  static values = { selector: String }
  connect() {
    if (this.selectorValue == 'works') {
      new DataTable("#worksTable", {
        columns: [
          { select: 4, sort: "desc" },  // Sort the fifth column in ascending order
          { select: [1, 5, 6, 7, 8], sortable: false } // Disable unsortable columns
        ]})
    }

    if (this.selectorValue == 'collections') {
      new DataTable("#collectionsTable", {
        columns: [
          { select: 4, sort: "desc" },  // Sort the fifth column in ascending order
          { select: [1, 5, 6, 7, 8], sortable: false } // Disable unsortable columns
        ]})
    }
  }
}
