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

    dt.on('datatable.init', () => {
      applyTablePaginationLabels()
      // }
    })

    dt.on('datatable.update', () => {
      applyTablePaginationLabels()
    })

    dt.on('datatable.sort', function(column, direction) {
      const searchColHeader = document.querySelector("table.dataTable-table > thead > tr")

      for (var i = 0; i < searchColHeader.cells.length; i++) {
        var dir = direction == "asc" ? "ascending" : "descending"
        if (i == column) {
          searchColHeader.cells[i].setAttribute("aria-sort", dir)
        } else {
          searchColHeader.cells[i].removeAttribute("aria-sort")
        }
      }

      // Make sure the table maintains focus when interacting with sort
      const tableElement = document.querySelector("table.dataTable-table")
      tableElement.focus()
    })
  }
}

function applyTablePaginationLabels() {
  const paginationList = document.querySelectorAll("ul.dataTable-pagination-list > li > a")
  for (var i = 0; i < paginationList.length; i++) {
    // If the text of the page link is a number, set the label to "Go to {page}
    // else if the first button set "Go to previous page" else set "Go to next page"
    var value = Number(paginationList[i].text);
    if (Math.floor(value) == value) {
      paginationList[i].setAttribute("aria-label", "Go to page " + value)
    } else {
      if (i == 0) {
        paginationList[i].setAttribute("aria-label", "Go to previous page")
      } else {
        paginationList[i].setAttribute("aria-label", "Go to next page")
      }
    }
  }
}

