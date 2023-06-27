import { Controller } from "@hotwired/stimulus"
import { DataTable } from "simple-datatables"

export default class extends Controller {
  static values = {
    hideDepositor: Boolean
  }

  connect() {
    const columns = [
      { select: 4, sort: "desc" },  // Sort the fifth column in descending order
      { select: [1, 5, 6, 7, 8], sortable: false } // Disable unsortable columns
    ]
    if (this.hideDepositorValue) columns.push({ select: 2, hidden: true})
    const dt = new DataTable("#worksTable", {
      columns: columns,
      searchable: true
    })
    // This scrolls the top of the table into view when paging.
    dt.on('datatable.page', () => {
      dt.table.scrollIntoView()
    })
  }
}
