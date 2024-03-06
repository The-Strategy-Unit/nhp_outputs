# ui is created correctly

    Code
      mod_info_home_ui("id")
    Output
      <h1>NHP Model Results</h1>
      <div class="row">
        <div class="col-sm-6">
          <div class="col-sm-12">
            <div class="card bs4Dash">
              <div class="card-header">
                <h3 class="card-title">Notes</h3>
              </div>
              <div class="card-body">
                <p>
                  See
                  <a href="https://connect.strategyunitwm.nhs.uk/nhp/project_information">the model project information site</a>
                  for an overview, user guide and methodology for the model and this app.
                </p>
                <p>
                  Use the multi-choice site selection box (upper left) to filter results by sites.
                  A&amp;E results will not be shown if you select sites.
                </p>
              </div>
            </div>
            <script type="application/json">{"title":"Notes","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
          </div>
          <div class="col-sm-12">
            <div class="card bs4Dash">
              <div class="card-header">
                <h3 class="card-title">Download results data</h3>
              </div>
              <div class="card-body">
                <p>
                  Download a file containing results data for the selected model run.
                  The data is provided for each site and for the overall trust level.
                </p>
                <a class="btn btn-default shiny-download-link  shinyjs-disabled" download href="" id="id-download_results_xlsx" target="_blank">
                  <i class="fas fa-download" role="presentation" aria-label="download icon"></i>
                  Download results (.xlsx)
                </a>
                <a class="btn btn-default shiny-download-link  shinyjs-disabled" download href="" id="id-download_results_json" target="_blank">
                  <i class="fas fa-download" role="presentation" aria-label="download icon"></i>
                  Download results (.json)
                </a>
              </div>
            </div>
            <script type="application/json">{"title":"Download results data","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
          </div>
          <div class="col-sm-12">
            <div class="card bs4Dash">
              <div class="card-header">
                <h3 class="card-title">Download outputs report</h3>
              </div>
              <div class="card-body">
                <p>
                  Download a file containing the input parameters and
                  outputs (charts and tables) for the selected model run and selected sites.
                  This will take a moment.
                </p>
                <a class="btn btn-default shiny-download-link  shinyjs-disabled" download href="" id="id-download_report_html" target="_blank">
                  <i class="fas fa-download" role="presentation" aria-label="download icon"></i>
                  Download report (.html)
                </a>
              </div>
            </div>
            <script type="application/json">{"title":"Download outputs report","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
          </div>
        </div>
        <div class="col-sm-6">
          <div class="col-sm-12">
            <div class="card bs4Dash">
              <div class="card-header">
                <h3 class="card-title">Model run information</h3>
              </div>
              <div class="card-body">
                <p>This is a reminder of the metadata for the model run you selected.</p>
                <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                  <div class="load-container shiny-spinner-hidden load1">
                    <div id="spinner-4c06f33fbefba16ff0bce42ee10ea0e6" class="loader">Loading...</div>
                  </div>
                  <div style="height:400px" class="shiny-spinner-placeholder"></div>
                  <div id="id-params_model_run" class="shiny-html-output"></div>
                </div>
              </div>
            </div>
            <script type="application/json">{"title":"Model run information","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
          </div>
        </div>
      </div>

