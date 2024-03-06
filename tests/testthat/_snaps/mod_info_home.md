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
                <h3 class="card-title">About</h3>
              </div>
              <div class="card-body">
                <p>Welcome to this NHP online tool.</p>
                <p>This tool is designed to help facilitate a demand and capacity modelling process to support the development of robust, local NHP proposals.</p>
                <p>The New Hospital Programme requires estimates of future activity levels to inform the design of a new hospital.</p>
                <p>This tool is designed to help determine how hospital activity might change in the years to come (relative to a baseline year) and to provide a high-level view of the physical capacity required to meet that demand.</p>
                <p>
                  For more information or help, please visit the
                  <a href="https://connect.strategyunitwm.nhs.uk/nhp/project_information/">model information site</a>
                  or contact the
                  <a href="mailto:mlcsu.nhpanalytics@nhs.net">MLCSU NHP Analytics mailbox</a>
                  .
                </p>
              </div>
            </div>
            <script type="application/json">{"title":"About","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
          </div>
          <div class="col-sm-12">
            <div class="card bs4Dash">
              <div class="card-header">
                <h3 class="card-title">App notes</h3>
              </div>
              <div class="card-body">
                <p>Select the 'Results' section in the navbar (left) to view outputs from the selected model run.</p>
                <p>
                  Use the multi-choice 'Site selection' box in the navbar to filter results by sites.
                  Note that A&amp;E results will not be shown at site level.
                </p>
                <p>From the 'Information' section you can download the results data for this model run and view the input parameters.</p>
              </div>
            </div>
            <script type="application/json">{"title":"App notes","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
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

