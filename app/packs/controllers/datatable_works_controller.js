import { Controller } from "stimulus"
import { DataTable } from "simple-datatables"

export default class extends Controller {
  connect() {
    new DataTable("#worksTable", {
      columns: [
        { select: 4, sort: "desc" },  // Sort the fifth column in descending order
        { select: [1, 5, 6, 7, 8], sortable: false } // Disable unsortable columns
      ]})
  }
}
