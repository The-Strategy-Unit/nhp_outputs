# ui is created correctly

    Code
      mod_principal_summary_ui("id")
    Output
      <div class="row">
        <div class="col-sm-2"></div>
        <div class="col-sm-8">
          <div class="card bs4Dash">
            <div class="card-header">
              <h3 class="card-title">Summary</h3>
            </div>
            <div class="card-body">
              <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                <div class="load-container shiny-spinner-hidden load1">
                  <div id="spinner-bca61015a8656c8b633239e1f4c01396" class="loader">Loading...</div>
                </div>
                <div style="height:400px" class="shiny-spinner-placeholder"></div>
                <div id="id-summary_table" class="shiny-html-output"></div>
              </div>
            </div>
          </div>
          <script type="application/json">{"title":"Summary","solidHeader":true,"width":8,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
        </div>
        <div class="col-sm-2"></div>
      </div>

# mod_principal_summary_table creates a gt object

    Code
      mod_principal_summary_table(data)

