import m from "mithril"

var Login = {
  controller() {

  },

  view(ctrl) {
    return m(".row", [
      m(".col-sm-4.col-sm-offset-4", [
        m(".panel.panel-default", [
          m(".panel-body", [
            m("form.form-horizontal", [
              m(".form-group", [
                m("label.col-sm-3.control-label", "Username"),
                m(".col-sm-9", [
                  m("input.form-control[type=text][placeholder='Enter username']")
                ])
              ]),
              m(".form-group", [
                m("label.col-sm-3.control-label", "Password"),
                m(".col-sm-9", [
                  m("input.form-control[type=password][placeholder='Enter password']")
                ])
              ]),
              m(".form-group", [
                m(".col-sm-3.col-sm-offset-3", [
                  m("button.btn.btn-primary", "Login")
                ])
              ])
            ])
          ])
        ])
      ])
    ])
  }
}

export default Login;
