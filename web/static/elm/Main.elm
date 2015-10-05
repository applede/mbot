-- declares that this is the LoginForm module, which is how
-- other modules will reference this one if they want to import it and reuse its code.
module LoginForm where

import StartApp
import Effects
import Http
import Task exposing (Task)
import Json.Decode exposing (succeed, (:=), oneOf, map, string, Decoder)
import Json.Encode as JS

-- Elm’s "import" keyword works mostly like "require" in node.js.
-- The “exposing (..)” option specifies that we want to bring the Html module’s contents
-- into this file’s current namespace, so that instead of writing out
-- Html.form and Html.label we can just use "form" and "label" without the "Html." prefix.
import Html exposing (..)

-- This works the same way; we also want to import the entire
-- Html.Events module into the current namespace.
import Html.Events exposing (..)

-- With this import we are only bringing a few specific functions into our
-- namespace, specifically "id", "type'", "for", "value", and "class".
import Html.Attributes exposing (id, type', for, value, class)


type alias Model =
  { username: String
  , password: String
  , errors: Errors
  }

type alias Errors =
  { username: Bool
  , password: Bool
  , error: String
  }


type alias Action =
  { actionType: String
  , payload: String
  }


validationClass err =
  if err then
    class "form-group has-error"
  else
    class "form-group"


view actionDispatcher model =
  div [ class "row" ]
  [ div [ class "panel panel-default col-sm-4 col-sm-offset-4"]
    [ div [class "panel-body"]
      [ form [ id "signup-form", class "form-horizontal" ]
        [ div [ validationClass model.errors.username ]
          [ label [ for "username-field", class "control-label col-sm-3" ] [ text "Username" ]
          , div [ class "col-sm-9"]
            [ input
              [ id "username-field"
              , type' "text"
              , value model.username
              , class "form-control"
              , on "input" targetValue (\str -> Signal.message actionDispatcher { actionType = "SET_USERNAME", payload = str })
              ]
              []
            ]
          ]
        , div [ validationClass model.errors.password ]
          [ label [ for "password-field", class "control-label col-sm-3" ] [ text "Password" ]
          , div [ class "col-sm-9" ]
            [ input
              [ id "password-field"
              , type' "password"
              , value model.password
              , class "form-control"
              , on "input" targetValue (\str -> Signal.message actionDispatcher { actionType = "SET_PASSWORD", payload = str })
              ]
              []
            ]
          ]
        , div [ class "form-group" ]
          [ div [ class "col-sm-offset-3 col-sm-9" ]
            [ div [ class "btn btn-primary", onClick actionDispatcher { actionType = "VALIDATE", payload = "" } ] [ text "Login" ]
            ]
          ]
        ]
        , div [ class "validation-error" ] [ text (viewUsernameErrors model) ]
      ]
    ]
  ]


viewUsernameErrors : Model -> String
viewUsernameErrors model =
   if model.errors.error /= "" then
       model.errors.error
   else
       ""


getErrors : Model -> Errors
getErrors model =
    { username = model.username == ""
    , password = model.password == ""
    , error = model.errors.error
    }


withError : Model -> String -> Model
withError model err =
  let
    currentErrors = model.errors
    newErrors =
      { currentErrors | error <- err }
  in
    { model | errors <- newErrors }


sendLogin : Model -> Decoder Action -> Task Http.Error Action
sendLogin model decoder =
  let request =
    { verb = "POST"
    , headers = [("Content-Type", "application/json")]
    , url = "http://localhost:4000/login"
    , body =
      Http.string <| "{ \"data\": { \"username\": \"" ++ model.username ++ "\", \"password\": \"" ++ model.password ++ "\" } }"
    }
  in
    Http.fromJson decoder (Http.send Http.defaultSettings request)


update : Action -> Model -> (Model, Effects.Effects Action)
update action model =
  if action.actionType == "VALIDATE" then
    let
      url =
          "http://localhost:4000/login"

      loginToken = \token ->
        { actionType = "LOGIN_SUCCESS", payload = token }

      loginError = \err ->
        { actionType = "LOGIN_ERROR", payload = err }

      loginDecode =
        oneOf
          [ map loginToken ("token" := string)
          , map loginError ("error" := string)
          ]

      requestError err =
        err |> toString |> loginError |> Task.succeed

      request =
          sendLogin model loginDecode

      neverFailingRequest =
          Task.onError request requestError
    in
      ( { model | errors <- getErrors model }, Effects.task neverFailingRequest)
  else if action.actionType == "SET_USERNAME" then
    ( { model | username <- action.payload }, Effects.none )
  else if action.actionType == "SET_PASSWORD" then
    ( { model | password <- action.payload }, Effects.none )
  else if action.actionType == "LOGIN_SUCCESS" then
    ( withError model action.payload, Effects.none )
  else if action.actionType == "LOGIN_ERROR" then
    ( withError model action.payload, Effects.none )
  else
    ( model, Effects.none )


initialModel = { username = "", password = "", errors = initialErrors }


initialErrors =
  { username = False, password = False, error = "" }


app =
  StartApp.start
    { init = (initialModel, Effects.none )
    , update = update
    , view = view
    , inputs = []
    }

-- Take a look at this starting model we’re passing to our view function.
-- Note that in Elm syntax, we use = to separate fields from values
-- instead of : like JavaScript uses for its object literals.
main =
    app.html

port tasks : Signal (Task Effects.Never ())

port tasks =
    app.tasks
