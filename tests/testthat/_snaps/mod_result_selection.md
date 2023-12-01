# ui is created correctly

    Code
      mod_result_selection_ui("id")
    Output
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
        <label class="control-label" id="id-create_datetime-label" for="id-create_datetime">Model Run Time</label>
        <div>
          <select id="id-create_datetime" class="shiny-input-select"></select>
          <script type="application/json" data-for="id-create_datetime" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
        </div>
      </div>
      <div class="form-group shiny-input-container">
        <label class="control-label" id="id-site_selection-label" for="id-site_selection">Site</label>
        <div>
          <select id="id-site_selection" class="shiny-input-select"></select>
          <script type="application/json" data-for="id-site_selection" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
        </div>
      </div>
      <a class="btn btn-default shiny-download-link  shinyjs-hide" download href="" id="id-download_results" target="_blank">
        <i class="fas fa-download" role="presentation" aria-label="download icon"></i>
        Download results (.json)
      </a>

