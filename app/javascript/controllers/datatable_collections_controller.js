import { Controller } from "stimulus"
import { DataTable } from "simple-datatables"

export default class extends Controller {
  connect() {
    new DataTable("#collectionsTable", {
      paging: false,
      searchable: false,
      columns: [
        { select: 0, sort: "asc" },  // Sort the first column in ascending order
      ]
    })
  }
}
