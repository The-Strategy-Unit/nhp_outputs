# ui is created correctly

    Code
      mod_principal_change_factor_effects_ui("id")
    Output
      <h1>Principal projection: impact of changes</h1>
      <div class="row">
        <div class="col-sm-4">
          <div class="form-group shiny-input-container">
            <label class="control-label" id="id-activity_type-label" for="id-activity_type">Activity Type</label>
            <div>
              <select id="id-activity_type"></select>
              <script type="application/json" data-for="id-activity_type" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
            </div>
          </div>
        </div>
        <div class="col-sm-4">
          <div class="form-group shiny-input-container">
            <label class="control-label" id="id-measure-label" for="id-measure">Measure</label>
            <div>
              <select id="id-measure"></select>
              <script type="application/json" data-for="id-measure" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
            </div>
          </div>
        </div>
        <div class="form-group shiny-input-container">
          <div class="checkbox">
            <label>
              <input id="id-include_baseline" type="checkbox" checked="checked"/>
              <span>Include baseline?</span>
            </label>
          </div>
        </div>
      </div>
      <div class="shiny-spinner-output-container shiny-spinner-hideui ">
        <div class="load-container shiny-spinner-hidden load1">
          <div id="spinner-f41453cad54686886ab641b6c7248b65" class="loader">Loading...</div>
        </div>
        <div class="plotly html-widget html-widget-output shiny-report-size shiny-report-theme html-fill-item-overflow-hidden html-fill-item" id="id-change_factors" style="width:100%;height:600px;"></div>
      </div>
      <div id="id-individual_change_factors" class="shinyjs-hide">
        <h2>Individual Change Factors</h2>
        <div class="form-group shiny-input-container">
          <label class="control-label" id="id-sort_type-label" for="id-sort_type">Sort By</label>
          <div>
            <select id="id-sort_type"><option value="alphabetical" selected>alphabetical</option>
      <option value="descending value">descending value</option></select>
            <script type="application/json" data-for="id-sort_type" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
          </div>
        </div>
        <div class="shiny-spinner-output-container shiny-spinner-hideui ">
          <div class="load-container shiny-spinner-hidden load1">
            <div id="spinner-53d8ac16818d391f4c50de11cab26acc" class="loader">Loading...</div>
          </div>
          <div class="row">
            <div class="col-sm-6">
              <div class="plotly html-widget html-widget-output shiny-report-size shiny-report-theme html-fill-item-overflow-hidden html-fill-item" id="id-admission_avoidance" style="width:100%;height:600px;"></div>
            </div>
            <div class="col-sm-6">
              <div class="plotly html-widget html-widget-output shiny-report-size shiny-report-theme html-fill-item-overflow-hidden html-fill-item" id="id-los_reduction" style="width:100%;height:600px;"></div>
            </div>
          </div>
        </div>
      </div>

