# ui is created correctly

    Code
      mod_info_home_ui("id")
    Output
      <h1>NHP Model Results</h1>
      <div class="row">
        <div class="col-sm-6">
          <div class="card bs4Dash">
            <div class="card-header">
              <h3 class="card-title">Notes</h3>
            </div>
            <div class="card-body">
              <p>
                Further information about the model and these results can be found on the
                <a href="https://connect.strategyunitwm.nhs.uk/nhp/project_information">model project information site.</a>
              </p>
              <p>
                Note that some data is presented at trust level even if you make a site selection.
                Check the notes in each tab for details.
              </p>
              <a id="id-download_results_xlsx" class="btn btn-default shiny-download-link " href="" target="_blank" download>
                <i class="fas fa-download" role="presentation" aria-label="download icon"></i>
                Download results (.xlsx)
              </a>
              <a id="id-download_results_json" class="btn btn-default shiny-download-link " href="" target="_blank" download>
                <i class="fas fa-download" role="presentation" aria-label="download icon"></i>
                Download results (.json)
              </a>
            </div>
          </div>
          <script type="application/json">{"title":"Notes","solidHeader":true,"width":6,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
        </div>
        <div class="col-sm-6">
          <div class="card bs4Dash">
            <div class="card-header">
              <h3 class="card-title">Model Run</h3>
            </div>
            <div class="card-body">
              <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                <div class="load-container shiny-spinner-hidden load1">
                  <div id="spinner-4c06f33fbefba16ff0bce42ee10ea0e6" class="loader">Loading...</div>
                </div>
                <div style="height:400px" class="shiny-spinner-placeholder"></div>
                <div id="id-params_model_run" class="shiny-html-output"></div>
              </div>
            </div>
          </div>
          <script type="application/json">{"title":"Model Run","solidHeader":true,"width":6,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
        </div>
      </div>

