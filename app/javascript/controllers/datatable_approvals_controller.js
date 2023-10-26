import { Controller } from '@hotwired/stimulus'
import { DataTable } from 'simple-datatables'

export default class extends Controller {
  connect () {
    return new DataTable(this.element, {
      paging: false,
      searchable: false,
      columns: [
        { select: 0, sort: 'asc' }, // Sort the first column in ascending order
        { select: [3], sortable: false } // Disable unsortable columns
      ]
    })
  }
}
