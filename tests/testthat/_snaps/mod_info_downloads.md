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
                See details of the content on
                <a href="https://connect.strategyunitwm.nhs.uk/nhp/project_information/user_guide/results.html">the project information site.</a>
              </p>
              <a aria-disabled="true" class="btn btn-default shiny-download-link disabled shinyjs-disabled" download href="" id="id-download_results_xlsx" tabindex="-1" target="_blank">
                <i class="fas fa-download" role="presentation" aria-label="download icon"></i>
                Download results (.xlsx)
              </a>
              <a aria-disabled="true" class="btn btn-default shiny-download-link disabled shinyjs-disabled" download href="" id="id-download_results_json" tabindex="-1" target="_blank">
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
              <h3 class="card-title">Download parameters report (Extract A)</h3>
            </div>
            <div class="card-body">
              <p>
                Download a file containing the input parameters for
                the selected model run.
              </p>
              <a aria-disabled="true" class="btn btn-default shiny-download-link disabled shinyjs-disabled" download href="" id="id-download_report_parameters_html" tabindex="-1" target="_blank">
                <i class="fas fa-download" role="presentation" aria-label="download icon"></i>
                Download parameters report (.html)
              </a>
            </div>
          </div>
          <script type="application/json">{"title":"Download parameters report (Extract A)","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
        </div>
        <div class="col-sm-12">
          <div class="card bs4Dash">
            <div class="card-header">
              <h3 class="card-title">Download summary outputs report (Extract B)</h3>
            </div>
            <div class="card-body">
              <p>
                Download a file containing the outputs (charts and tables) for the
                selected model run and selected sites. This will take a moment.
              </p>
              <a aria-disabled="true" class="btn btn-default shiny-download-link disabled shinyjs-disabled" download href="" id="id-download_report_outputs_html" tabindex="-1" target="_blank">
                <i class="fas fa-download" role="presentation" aria-label="download icon"></i>
                Download outputs report (.html)
              </a>
            </div>
          </div>
          <script type="application/json">{"title":"Download summary outputs report (Extract B)","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
        </div>
      </div>

