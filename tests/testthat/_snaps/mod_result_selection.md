# ui is created correctly

    Code
      mod_result_selection_ui("id")
    Output
      <h1>NHP Model Results</h1>
      <div class="col-sm-6">
        <div class="card bs4Dash">
          <div class="card-header">
            <h3 class="card-title">Make selections</h3>
          </div>
          <div class="card-body">
            <div class="form-group shiny-input-container">
              <label class="control-label" id="id-dataset-label" for="id-dataset">Dataset</label>
              <div>
                <select id="id-dataset" class="shiny-input-select"></select>
                <script type="application/json" data-for="id-dataset" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
              </div>
            </div>
            <div class="form-group shiny-input-container">
              <label class="control-label" id="id-scenario-label" for="id-scenario">Scenario</label>
              <div>
                <select id="id-scenario" class="shiny-input-select"></select>
                <script type="application/json" data-for="id-scenario" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
              </div>
            </div>
            <div class="form-group shiny-input-container">
              <label class="control-label" id="id-create_datetime-label" for="id-create_datetime">Model run time</label>
              <div>
                <select id="id-create_datetime" class="shiny-input-select"></select>
                <script type="application/json" data-for="id-create_datetime" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
              </div>
            </div>
            <div class="form-group shiny-input-container">
              <label class="control-label" id="id-site_selection-label" for="id-site_selection">Site (all sites selected if left empty)</label>
              <div>
                <select id="id-site_selection" class="shiny-input-select" multiple="multiple"></select>
                <script type="application/json" data-for="id-site_selection">{"plugins":["selectize-plugin-a11y"]}</script>
              </div>
            </div>
          </div>
        </div>
        <script type="application/json">{"title":"Make selections","solidHeader":true,"width":6,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
      </div>
      <div class="col-sm-6">
        <div class="card bs4Dash">
          <div class="card-header">
            <h3 class="card-title">Download results data</h3>
          </div>
          <div class="card-body">
            <p>
              Download a file containing results for the selected model run.
              The data is provided for each site and for the overall trust level.
            </p>
            <a class="btn btn-default shiny-download-link  shinyjs-hide" download href="" id="id-download_results_xlsx" target="_blank">
              <i class="fas fa-download" role="presentation" aria-label="download icon"></i>
              Download results (.xlsx)
            </a>
            <a class="btn btn-default shiny-download-link  shinyjs-hide" download href="" id="id-download_results_json" target="_blank">
              <i class="fas fa-download" role="presentation" aria-label="download icon"></i>
              Download results (.json)
            </a>
          </div>
        </div>
        <script type="application/json">{"title":"Download results data","solidHeader":true,"width":6,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
      </div>
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
              Note that some data is not available at site level.
              A&amp;E data will be hidden and the 'Impact of Changes' tab is at trust level only.
              Check the notes box in each tab for details.
            </p>
          </div>
        </div>
        <script type="application/json">{"title":"Notes","solidHeader":true,"width":6,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
      </div>

