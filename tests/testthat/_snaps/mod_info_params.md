# ui is created correctly

    Code
      mod_info_params_ui("id")
    Output
      <h1>Information: input parameters</h1>
      <div class="col-sm-12">
        <div class="card bs4Dash">
          <div class="card-header">
            <h3 class="card-title">Notes</h3>
          </div>
          <div class="card-body">
            <p>
              This page contains a reminder of the parameter values you provided to the model inputs app.
              Further information about the model and these outputs can be found on the
              <a href="https://connect.strategyunitwm.nhs.uk/nhp/project_information">model project information site.</a>
            </p>
          </div>
        </div>
        <script type="application/json">{"title":"Notes","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
      </div>
      <div class="col-sm-12">
        <div class="card bs4Dash collapsed-card">
          <div class="card-header">
            <h3 class="card-title">Demographic factors</h3>
            <div class="card-tools float-right">
              <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                <i class="fas fa-plus" role="presentation" aria-label="plus icon"></i>
              </button>
            </div>
          </div>
          <div class="card-body">
            <div id="id-params_demographic_factors" class="shiny-html-output"></div>
          </div>
        </div>
        <script type="application/json">{"title":"Demographic factors","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
      </div>
      <div class="col-sm-12">
        <div class="card bs4Dash collapsed-card">
          <div class="card-header">
            <h3 class="card-title">Baseline adjustment</h3>
            <div class="card-tools float-right">
              <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                <i class="fas fa-plus" role="presentation" aria-label="plus icon"></i>
              </button>
            </div>
          </div>
          <div class="card-body">
            <div id="id-params_baseline_adjustment" class="shiny-html-output"></div>
          </div>
        </div>
        <script type="application/json">{"title":"Baseline adjustment","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
      </div>
      <div class="col-sm-12">
        <div class="card bs4Dash collapsed-card">
          <div class="card-header">
            <h3 class="card-title">Covid adjustment</h3>
            <div class="card-tools float-right">
              <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                <i class="fas fa-plus" role="presentation" aria-label="plus icon"></i>
              </button>
            </div>
          </div>
          <div class="card-body">
            <div id="id-params_covid_adjustment" class="shiny-html-output"></div>
          </div>
        </div>
        <script type="application/json">{"title":"Covid adjustment","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
      </div>
      <div class="col-sm-12">
        <div class="card bs4Dash collapsed-card">
          <div class="card-header">
            <h3 class="card-title">Waiting list adjustment</h3>
            <div class="card-tools float-right">
              <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                <i class="fas fa-plus" role="presentation" aria-label="plus icon"></i>
              </button>
            </div>
          </div>
          <div class="card-body">
            <p>
              Time Profile:
              <span id="id-time_profile_waiting_list_adjustment" class="shiny-text-output"></span>
            </p>
            <div id="id-params_waiting_list_adjustment" class="shiny-html-output"></div>
          </div>
        </div>
        <script type="application/json">{"title":"Waiting list adjustment","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
      </div>
      <div class="col-sm-12">
        <div class="card bs4Dash collapsed-card">
          <div class="card-header">
            <h3 class="card-title">Expatriation</h3>
            <div class="card-tools float-right">
              <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                <i class="fas fa-plus" role="presentation" aria-label="plus icon"></i>
              </button>
            </div>
          </div>
          <div class="card-body">
            <p>
              Time Profile:
              <span id="id-time_profile_expat" class="shiny-text-output"></span>
            </p>
            <div id="id-params_expat" class="shiny-html-output"></div>
          </div>
        </div>
        <script type="application/json">{"title":"Expatriation","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
      </div>
      <div class="col-sm-12">
        <div class="card bs4Dash collapsed-card">
          <div class="card-header">
            <h3 class="card-title">Repatriation (local)</h3>
            <div class="card-tools float-right">
              <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                <i class="fas fa-plus" role="presentation" aria-label="plus icon"></i>
              </button>
            </div>
          </div>
          <div class="card-body">
            <p>
              Time Profile:
              <span id="id-time_profile_repat_local" class="shiny-text-output"></span>
            </p>
            <div id="id-params_repat_local" class="shiny-html-output"></div>
          </div>
        </div>
        <script type="application/json">{"title":"Repatriation (local)","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
      </div>
      <div class="col-sm-12">
        <div class="card bs4Dash collapsed-card">
          <div class="card-header">
            <h3 class="card-title">Repatriation (non-local)</h3>
            <div class="card-tools float-right">
              <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                <i class="fas fa-plus" role="presentation" aria-label="plus icon"></i>
              </button>
            </div>
          </div>
          <div class="card-body">
            <p>
              Time Profile:
              <span id="id-time_profile_repat_nonlocal" class="shiny-text-output"></span>
            </p>
            <div id="id-params_repat_nonlocal" class="shiny-html-output"></div>
          </div>
        </div>
        <script type="application/json">{"title":"Repatriation (non-local)","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
      </div>
      <div class="col-sm-12">
        <div class="card bs4Dash collapsed-card">
          <div class="card-header">
            <h3 class="card-title">Non-demographic adjustment</h3>
            <div class="card-tools float-right">
              <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                <i class="fas fa-plus" role="presentation" aria-label="plus icon"></i>
              </button>
            </div>
          </div>
          <div class="card-body">
            <div id="id-params_non_demographic_adjustment" class="shiny-html-output"></div>
          </div>
        </div>
        <script type="application/json">{"title":"Non-demographic adjustment","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
      </div>
      <div class="col-sm-12">
        <div class="card bs4Dash collapsed-card">
          <div class="card-header">
            <h3 class="card-title">Activity avoidance</h3>
            <div class="card-tools float-right">
              <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                <i class="fas fa-plus" role="presentation" aria-label="plus icon"></i>
              </button>
            </div>
          </div>
          <div class="card-body">
            <div id="id-params_activity_avoidance" class="shiny-html-output"></div>
          </div>
        </div>
        <script type="application/json">{"title":"Activity avoidance","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
      </div>
      <div class="col-sm-12">
        <div class="card bs4Dash collapsed-card">
          <div class="card-header">
            <h3 class="card-title">Efficiencies</h3>
            <div class="card-tools float-right">
              <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                <i class="fas fa-plus" role="presentation" aria-label="plus icon"></i>
              </button>
            </div>
          </div>
          <div class="card-body">
            <div id="id-params_efficiencies" class="shiny-html-output"></div>
          </div>
        </div>
        <script type="application/json">{"title":"Efficiencies","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
      </div>
      <div class="col-sm-12">
        <div class="card bs4Dash collapsed-card">
          <div class="card-header">
            <h3 class="card-title">Bed occupancy</h3>
            <div class="card-tools float-right">
              <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                <i class="fas fa-plus" role="presentation" aria-label="plus icon"></i>
              </button>
            </div>
          </div>
          <div class="card-body">
            <div class="row">
              <div class="col-sm-6">
                <h4>Day and night</h4>
                <div id="id-params_bed_occupancy_day_night" class="shiny-html-output"></div>
              </div>
              <div class="col-sm-6">
                <h4>Specialty mapping</h4>
                <div id="id-params_bed_occupancy_specialty_mapping" class="shiny-html-output"></div>
              </div>
            </div>
          </div>
        </div>
        <script type="application/json">{"title":"Bed occupancy","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
      </div>

