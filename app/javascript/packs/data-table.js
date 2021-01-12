/**
 * Inject hyperlinks, into the column headers of sortable tables, which sort
 * the corresponding column when clicked.
 */
var tables = document.querySelectorAll("table.sortable"),
    table,
    thead,
    headers,
    i,
    j;

var disabledColumns = [1, 5, 6, 7, 8]

for (i = 0; i < tables.length; i++) {
  setTableHeaders(tables[i], true);
}

function setTableHeaders(table, withEvent) {
  if (thead = table.querySelector("thead")) {
    headers = thead.querySelectorAll("th");

    for (j = 0; j < headers.length; j++) {
      if (disabledColumns.includes(j)) { continue; }
      else { headers[j].innerHTML = "<a href='#'>" + headers[j].innerText + "</a>"; }
    }

    if (withEvent) {
      console.log("1")
      thead.addEventListener("click", sortTableFunction(table));
    }
  }
}

/**
 * Create a function to sort the given table.
 */
function sortTableFunction(table) {
  return function(ev) {
    if (ev.target.tagName.toLowerCase() == 'a') {
      target = ev.target
      indicator = getNextIndicator(target)
      sortRows(table, siblingIndex(target.parentNode), reverseSort(indicator));
      // clearIndicators(table); // restetting table headers here causes a null exception
      setIndicator(target.parentNode, indicator)
      ev.preventDefault();
    }
  };
}

// function clearIndicators(table) {
//   var headers = table.getElementsByTagName("th")
//   for (i = 0; i < headers.length; i++) {
//     icon = headers[i].getElementsByTagName("i")
//       console.log("ICON");
//       console.dir(icon[0]);
//     }
// }

/**
 * Get the existing sort indicator, used to determin sort direction
 */
function getNextIndicator(target) {
  if(target.innerHTML.includes('fa-angle-down')) {
    return 'up';
  } else {
    return 'down';
  }
}

 /**
 * Uses existing sort indicastor to set the proper font-awesome indicator based on sort direction
 */
function setIndicator(target, indicator) {
  target.innerHTML = "<a href='#'>" + target.innerText + " <i class=\"fa fa-angle-" + indicator + "\"></i></a>";
}

function reverseSort(direction) {
  if(direction == 'up') {
    return true;
  }
  return false;
}

/**
 * Get the index of a node relative to its siblings — the first (eldest) sibling
 * has index 0, the next index 1, etc.
 */
function siblingIndex(node) {
    var count = 0;

    while (node = node.previousElementSibling) {
        count++;
    }

    return count;
}

/**
 * Sort the given table by the numbered column (0 is the first column, etc.)
 */
function sortRows(table, columnIndex, desc) {
    var rows = table.querySelectorAll("tbody tr"),
        sel = "thead th:nth-child(" + (columnIndex + 1) + ")",
        sel2 = "td:nth-child(" + (columnIndex + 1) + ")",
        classList = table.querySelector(sel).classList,
        values = [],
        cls = "",
        allNum = true,
        val,
        index,
        node;

    if (classList) {
        if (classList.contains("date")) {
            cls = "date";
        } else if (classList.contains("number")) {
            cls = "number";
        }
    }

    for (index = 0; index < rows.length; index++) {
        node = rows[index].querySelector(sel2);
        val = node.innerText;

        if (isNaN(val)) {
            allNum = false;
        } else {
            val = parseFloat(val);
        }

        values.push({ value: val, row: rows[index] });
    }

    if (cls == "" && allNum) {
        cls = "number";
    }

    if (cls == "number") {
        values.sort(sortNumberVal);
        values = values.reverse();
    } else if (cls == "date") {
        values.sort(sortDateVal);
    } else {
        values.sort(sortTextVal);
    }

    if (desc) { // sort ascending
      for (var idx = values.length-1; idx >= 0; idx--) {
        table.querySelector("tbody").appendChild(values[idx].row);
      }
    } else {
      for (var idx = 0; idx < values.length; idx++) {
          table.querySelector("tbody").appendChild(values[idx].row);
      }
    }
}

/**
 * Compare two 'value objects' numerically
 */
function sortNumberVal(a, b) {
    return sortNumber(a.value, b.value);
}

/**
 * Numeric sort comparison
 */
function sortNumber(a, b) {
    return a - b;
}

/**
 * Compare two 'value objects' as dates
 */
function sortDateVal(a, b) {
    var dateA = Date.parse(a.value),
        dateB = Date.parse(b.value);

    return sortNumber(dateA, dateB);
}

/**
 * Compare two 'value objects' as simple text; case-insensitive
 */
function sortTextVal(a, b) {
    var textA = (a.value + "").toUpperCase();
    var textB = (b.value + "").toUpperCase();

    if (textA < textB) {
        return -1;
    }

    if (textA > textB) {
        return 1;
    }

    return 0;
}

