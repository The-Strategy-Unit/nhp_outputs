# ui is created correctly

    Code
      mod_info_downloads_ui("id")
    Output
      <h1>Information: downloads</h1>
      <div class="row">
        <div class="col-sm-12">
          <div class="card bs4Dash">
            <div class="card-header">
              <h3 class="card-title">Notes</h3>
            </div>
            <div class="card-body">
              <p>These files will download one at a time and may take a moment to be generated.</p>
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
              <h3 class="card-title">Download parameters report</h3>
            </div>
            <div class="card-body">
              <p>
                Download a file containing the input parameters for
                the selected model run.
              </p>
              <a class="btn btn-default shiny-download-link  shinyjs-disabled" download href="" id="id-download_report_parameters_html" target="_blank">
                <i class="fas fa-download" role="presentation" aria-label="download icon"></i>
                Download parameters report (.html)
              </a>
            </div>
          </div>
          <script type="application/json">{"title":"Download parameters report","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
        </div>
        <div class="col-sm-12">
          <div class="card bs4Dash">
            <div class="card-header">
              <h3 class="card-title">Download outputs report</h3>
            </div>
            <div class="card-body">
              <p>
                Download a file containing the outputs (charts and tables) for the
                selected model run and selected sites. This will take a moment.
              </p>
              <a class="btn btn-default shiny-download-link  shinyjs-disabled" download href="" id="id-download_report_outputs_html" target="_blank">
                <i class="fas fa-download" role="presentation" aria-label="download icon"></i>
                Download outputs report (.html)
              </a>
            </div>
          </div>
          <script type="application/json">{"title":"Download outputs report","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
        </div>
      </div>

