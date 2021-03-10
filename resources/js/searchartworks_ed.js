function searchID() {
  var input, filter, table, tr, td, i;
  input = document.getElementById("inputArtworks1");
  filter = input.value.toUpperCase();
  table = document.getElementById("artworks");
  tr = table.getElementsByTagName("tr");
  for (i = 0; i < tr.length; i++) {
    td = tr[i].getElementsByTagName("td")[0];
    if (td) {
      if (td.textContent.toUpperCase().indexOf(filter) > -1) {
        tr[i].style.display = "";
      } else {
        tr[i].style.display = "none";
      }
    }       
  }
}

function searchArtwork() {
  var input, filter, table, tr, td, i;
  input = document.getElementById("inputArtworks2");
  filter = input.value.toUpperCase();
  table = document.getElementById("artworks");
  tr = table.getElementsByTagName("tr");
  for (i = 0; i < tr.length; i++) {
    td = tr[i].getElementsByTagName("td")[1];
    if (td) {
      if (td.innerHTML.toUpperCase().indexOf(filter) > -1) {
        tr[i].style.display = "";
      } else {
        tr[i].style.display = "none";
      }
    }       
  }
}

function searchForename() {
  var input, filter, table, tr, td, i;
  input = document.getElementById("inputArtworks3");
  filter = input.value.toUpperCase();
  table = document.getElementById("artworks");
  tr = table.getElementsByTagName("tr");
  for (i = 0; i < tr.length; i++) {
    td = tr[i].getElementsByTagName("td")[2];
    if (td) {
      if (td.innerHTML.toUpperCase().indexOf(filter) > -1) {
        tr[i].style.display = "";
      } else {
        tr[i].style.display = "none";
      }
    }       
  }
}

function searchSurname() {
  var input, filter, table, tr, td, i;
  input = document.getElementById("inputArtworks4");
  filter = input.value.toUpperCase();
  table = document.getElementById("artworks");
  tr = table.getElementsByTagName("tr");
  for (i = 0; i < tr.length; i++) {
    td = tr[i].getElementsByTagName("td")[3];
    if (td) {
      if (td.innerHTML.toUpperCase().indexOf(filter) > -1) {
        tr[i].style.display = "";
      } else {
        tr[i].style.display = "none";
      }
    }       
  }
}

function searchDate() {
  var input, filter, table, tr, td, i;
  input = document.getElementById("inputArtworks5");
  filter = input.value.toUpperCase();
  table = document.getElementById("artworks");
  tr = table.getElementsByTagName("tr");
  for (i = 0; i < tr.length; i++) {
    td = tr[i].getElementsByTagName("td")[4];
    if (td) {
      if (td.innerHTML.toUpperCase().indexOf(filter) > -1) {
        tr[i].style.display = "";
      } else {
        tr[i].style.display = "none";
      }
    }       
  }
}
