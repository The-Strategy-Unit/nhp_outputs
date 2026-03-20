# ui is created correctly

    Code
      mod_principal_summary_ui("id")
    Output
      <h1>Principal projection: summary</h1>
      <div class="col-sm-12">
        <div class="card bs4Dash">
          <div class="card-header">
            <h3 class="card-title">Notes</h3>
          </div>
          <div class="card-body">
            <p>Bed days are defined as the difference in days between discharge and admission, plus one day.
      One bed day is added to account for zero length of stay spells/partial days at the beginning and end of a spell.
      See the <a href="https://connect.strategyunitwm.nhs.uk/nhp/project_information">model project information site</a> for definitions of terms.</p>
      
            <p>Bed-availability data is not available at site level.</p>
          </div>
        </div>
        <script type="application/json">{"title":"Notes","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
      </div>
      <div class="col-sm-12">
        <div class="card bs4Dash">
          <div class="card-header">
            <h3 class="card-title">Summary by point of delivery</h3>
          </div>
          <div class="card-body">
            <div data-spinner-id="spinner-46fc03e74e82de292a3ae28234e2c826" class="shiny-spinner-output-container shiny-spinner-hideui">
              <div class="load-container shiny-spinner-hidden load1">
                <div id="spinner-46fc03e74e82de292a3ae28234e2c826" class="loader">Loading...</div>
              </div>
              <div style="height:400px" class="shiny-spinner-placeholder"></div>
              <div class="shiny-html-output gt_shiny" id="id-summary_table"></div>
            </div>
          </div>
        </div>
        <script type="application/json">{"title":"Summary by point of delivery","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
      </div>

