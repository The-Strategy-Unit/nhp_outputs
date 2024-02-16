# if file isn't entered/valid it exits the app

    Code
      mock_args(m)[[1]][[1]]
    Output
      <div class="modal fade" data-backdrop="static" data-bs-backdrop="static" data-bs-keyboard="false" data-keyboard="false" id="shiny-modal" tabindex="-1">
        <div class="modal-dialog">
          <div class="modal-content">
            <div class="modal-header">
              <h4 class="modal-title">Error</h4>
            </div>
            <div class="modal-body">
              No/Invalid file was requested.
              Please return to
              <a href="/nhp/outputs">result selection</a>
            </div>
          </div>
        </div>
        <script>if (window.bootstrap && !window.bootstrap.Modal.VERSION.match(/^4\./)) {
               var modal = new bootstrap.Modal(document.getElementById('shiny-modal'));
               modal.show();
            } else {
               $('#shiny-modal').modal().focus();
            }</script>
      </div>

# it file can't be loaded from azure it exits the app

    Code
      mock_args(m)[[1]][[1]]
    Output
      <div class="modal fade" data-backdrop="static" data-bs-backdrop="static" data-bs-keyboard="false" data-keyboard="false" id="shiny-modal" tabindex="-1">
        <div class="modal-dialog">
          <div class="modal-content">
            <div class="modal-header">
              <h4 class="modal-title">Error</h4>
            </div>
            <div class="modal-body">
              Results not found.
              Please return to
              <a href="/nhp/outputs">result selection</a>
            </div>
          </div>
        </div>
        <script>if (window.bootstrap && !window.bootstrap.Modal.VERSION.match(/^4\./)) {
               var modal = new bootstrap.Modal(document.getElementById('shiny-modal'));
               modal.show();
            } else {
               $('#shiny-modal').modal().focus();
            }</script>
      </div>

