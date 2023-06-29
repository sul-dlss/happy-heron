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

    // This removes the pagination list and if it is empty, and adds an aria
    // label for its parent nav, which is done to improve accessibility.
    dt.on('datatable.init', () => {
      const paginationList = document.querySelector("ul.dataTable-pagination-list")
      if (paginationList === null) return

      paginationList.parentNode.setAttribute("aria-label", "Pagination Controls for Deposits")

      if (!paginationList.hasChildNodes()) paginationList.remove()
    })

    // This adds a label for the datatables search input, which is done to improve accessibility.
    dt.on('datatable.init', () => {
      const searchInput = document.querySelector("input.dataTable-input")
      searchInput.setAttribute("id", "dataTable-search")
      searchInput.insertAdjacentHTML("afterend", '<label for="dataTable-search" class="visually-hidden">Search for works</label>')
    })
  }
}
