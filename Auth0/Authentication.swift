// Authentication.swift
//
// Copyright (c) 2016 Auth0 (http://auth0.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

public typealias DatabaseUser = (email: String, username: String?, verified: Bool)

/**
 Auth endpoints of Auth0
 - seeAlso: [Auth0 Auth API docs](https://auth0.com/docs/api/authentication)
 */
public protocol Authentication: Trackable, Loggable {
    var clientId: String { get }
    var url: URL { get }

    /**
     Logs in an user using email|username and password using a Database and Passwordless connection

     ```
     Auth0
        .authentication(clientId: clientId, domain: "samples.auth0.com")
        .login(emailOrUsername: "support@auth0.com", password: "a secret password", connection: "Username-Password-Authentication")
        .start { result in
            switch result {
            case .Success(let credentials):
                print(credentials)
            case .Failure(let error):
                print(error)
            }
        }
     ```

     you can also specify scope and additional parameters

     ```
     Auth0
        .authentication(clientId: clientId, domain: "samples.auth0.com")
        .login(emailOrUsername: "support@auth0.com", password:  "a secret password", connection: "Username-Password-Authentication", scope: "openid email", parameters: ["state": "a random state"])
        .start { print($0) }
     ```

     for passwordless connections

     ```
     Auth0
        .authentication(clientId: clientId, domain: "samples.auth0.com")
        .login(usernameOrEmail: "+4599134762367", password: "123456", connection: "sms", scope: "openid email", parameters: ["state": "a random state"])
        .start { print($0) }
     ```

     Also some enterprise connections, like Active Directory (AD), allows authentication using username/password without using the web flow.

     When result is `Successful`, a `Credentials` object will be in it's associated value with at least an `access_token` (depending on the scopes used to authenticate)

     - parameter usernameOrEmail:   username or email used of the user to authenticate, e.g. in email in Database connections or phone number for SMS connections.
     - parameter password:          password of the user or one time password (OTP) for passwordless connection users
     - parameter multifactorCode:   multifactor code if the user has enrolled one. e.g. Guardian. By default is `nil` and no code is sent.
     - parameter connection:        name of any of your configured database or passwordless connections
     - parameter scope:             scope value requested when authenticating the user. Default is 'openid'
     - parameter parameters:        additional parameters that are optionally sent with the authentication request

     - returns: authentication request that will yield Auth0 User Credentials
     - seeAlso: Credentials
     */
    func login(usernameOrEmail username: String, password: String, multifactorCode: String?, connection: String, scope: String, parameters: [String: Any]) -> Request<Credentials, AuthenticationError>

    /**
     Creates a user in a Database connection

     ```
     Auth0
        .authentication(clientId: clientId, domain: "samples.auth0.com")
        .createUser(email: "support@auth0.com", password: "a secret password", connection: "Username-Password-Authentication")
        .start { print($0) }
     ```

     you can also add additional attributes when creating the user

     ```
     Auth0
        .authentication(clientId: clientId, domain: "samples.auth0.com")
        .createUser(email: "support@auth0.com", password: "a secret password", connection: "Username-Password-Authentication", userMetadata: ["first_name": "support"])
        .start { print($0) }
     ```

     and if the database connection requires a username

     ```
     Auth0
        .authentication(clientId, domain: "samples.auth0.com")
        .createUser(email: "support@auth0.com", username: "support", password: "a secret password", connection: "Username-Password-Authentication")
        .start { print($0) }
     ```

     - parameter email:             email of the user to create
     - parameter username:          username of the user if the connection requires username. By default is 'nil'
     - parameter password:          password for the new user
     - parameter connection:        name where the user will be created (Database connection)
     - parameter userMetadata:      additional userMetadata parameters that will be added to the newly created user.

     - returns: request that will yield a created database user (just email, username and email verified flag)
     */
    func createUser(email: String, username: String?, password: String, connection: String, userMetadata: [String: Any]?) -> Request<DatabaseUser, AuthenticationError>

    /**
     Resets a Database user password

     ```
     Auth0
        .authentication(clientId: clientId, domain: "samples.auth0.com")
        .resetPassword(email: "support@auth0.com", connection: "Username-Password-Authentication")
        .start { print($0) }
     ```

     - parameter email:      email of the database user
     - parameter connection: name of the Database connection

     - returns: request to reset password
     */
    func resetPassword(email: String, connection: String) -> Request<Void, AuthenticationError>

    /**
     Creates a database user and then authenticates the user against Auth0.

     ```
     Auth0
        .authentication(clientId: clientId, domain: "samples.auth0.com")
        .signUp(email: "support@auth0.com", password: "a secret password", connection: "Username-Password-Authentication")
        .start { print($0) }
     ```

     you can also add additional attributes when creating the user

     ```
     Auth0
        .authentication(clientId: clientId, domain: "samples.auth0.com")
        .signUp(email: "support@auth0.com", password: "a secret password", connection: "Username-Password-Authentication", userMetadata: ["first_name": "support"])
        .start { print($0) }
     ```

     and if the database connection requires a username

     ```
     Auth0
     .authentication(clientId: clientId, domain: "samples.auth0.com")
     .signUp(email: "support@auth0.com", username: "support", password: "a secret password", connection: "Username-Password-Authentication")
     .start { print($0) }
     ```

     or specifying the scope and parameters used for authentication

     ```
     Auth0
        .authentication(clientId: clientId, domain: "samples.auth0.com")
        .signUp(email: "support@auth0.com", password: "a secret password", connection: "Username-Password-Authentication", scope: "openid email", parameters: ["state": "a random state"])
        .start { print($0) }
     ```

     - parameter email:        email of the new user
     - parameter username:     username of the user if connections requires username. By default is 'nil'
     - parameter password:     password for the new user
     - parameter connection:   name of the Database connection where the user will be created
     - parameter userMetadata: additional userMetadata values added when creating the user
     - parameter scope:        requested scope value when authenticating the user. By default is 'openid'
     - parameter parameters:   additional parameters sent during authentication

     - returns: an authentication request that will yield Auth0 user credentials after creating the user.
     */
    func signUp(email: String, username: String?, password: String, connection: String, userMetadata: [String: Any]?, scope: String, parameters: [String: Any]) -> ConcatRequest<DatabaseUser, Credentials, AuthenticationError>

    /**
     Starts passwordless authentication by sending an email with a OTP code

     ```
     Auth0
        .authentication(clientId: clientId, domain: "samples.auth0.com")
        .startPasswordless(email: "support@auth0.com")
        .start { print($0) }
     ```

     or if you have configured iOS Universal Links

     ```
     Auth0
        .authentication(clientId: clientId, domain: "samples.auth0.com")
        .startPasswordless(email: "support@auth0.com", type: .iOSLink)
        .start { print($0) }
     ```

     - parameter email:      email where to send the code or link
     - parameter type:       type of passwordless authentication/ By default is code
     - parameter connection: name of the passwordless connection. By default is 'email'
     - parameter parameters: additional authentication parameters added for Web link. Ignored in other types

     - returns: a request
     */
    func startPasswordless(email: String, type: PasswordlessType, connection: String, parameters: [String: Any]) -> Request<Void, AuthenticationError>

    /**
     Starts passwordless authentication by sending an sms with an OTP code

     ```
     Auth0
        .authentication(clientId: clientId, domain: "samples.auth0.com")
        .startPasswordless(phoneNumber: "support@auth0.com")
        .start { print($0) }
     ```

     or if you have configured iOS Universal Links

     ```
     Auth0
        .authentication(clientId: clientId, domain: "samples.auth0.com")
        .startPasswordless(phoneNumber: "support@auth0.com", type: .iOSLink)
        .start { print($0) }
     ```

     - parameter phoneNumber:   phone number where to send the sms with code or link
     - parameter type:          type of passwordless authentication. By default is code
     - parameter connection:    name of the passwordless connection. By default is 'sms'

     - returns: a request
     */
    func startPasswordless(phoneNumber: String, type: PasswordlessType, connection: String) -> Request<Void, AuthenticationError>

    /**
     Returns token information by performing a request to /tokeninfo endpoint

     ```
     Auth0
        .authentication(clientId: clientId, domain: "samples.auth0.com")
        .tokenInfo(token: token)
        .start { print($0) }
     ```

     - parameter token: token obtained by authenticating the user

     - returns: a request that will yield token information
     */
    func tokenInfo(token: String) -> Request<Profile, AuthenticationError>

    /**
     Returns user information by performing a request to /userinfo endpoint

     ```
     Auth0
        .authentication(clientId, domain: "samples.auth0.com")
        .userInfo(token: token)
        .start { print($0) }
     ```

     - parameter token: token obtained by authenticating the user

     - returns: a request that will yield user information
     */
    func userInfo(token: String) -> Request<Profile, AuthenticationError>

    /**
     Logs in a user using a social Identity Provider token. e.g. Facebook

     ```
     Auth0
        .authentication(clientId: clientId, domain: "samples.auth0.com")
        .loginSocial(token: fbToken, connection: "facebook")
        .start { print($0) }
     ```

     and if you need to specify a scope or add additional parameters

     ```
     Auth0
        .authentication(clientId: clientId, domain: "samples.auth0.com")
        .loginSocial(token: fbToken, connection: "facebook", scope: "openid email", parameters: ["state": "a random state"])
        .start { print($0) }
     ```

     - parameter token:      token obtained from a social IdP
     - parameter connection: name of the social connection. Only works with 'google-oauth2', 'facebook' and 'twitter'
     - parameter scope:      requested scope value when authenticating the user. By default is 'openid'
     - parameter parameters: additional parameters sent during authentication

     - returns: a request that will yield Auth0 user's credentials
     */
    func loginSocial(token: String, connection: String, scope: String, parameters: [String: Any]) -> Request<Credentials, AuthenticationError>

    /**
     Perform a OAuth2 token request against Auth0.

     ```
     Auth0
        .authentication(clientId: clientId, domain: "samples.auth0.com")
        .tokenExchange(withParameters: ["key": "value"])
        .start { print($0) }
     ```

     - parameter parameters: request parameters

     - returns: a request that will yield Auth0 user's credentials
     - seeAlso: Authentication#exchangeCode(codeVerifier:redirectURI:) for PKCE
     */
    func tokenExchange(withParameters parameters: [String: Any]) -> Request<Credentials, AuthenticationError>

    /**
     Performs the last step of Proof Key for Code Exchange [RFC 7636](https://tools.ietf.org/html/rfc7636).

     This will request User's token using the code and it's verifier after a request to `/oauth/authorize`

     ```
     Auth0
        .authentication(clientId: clientId, domain: "samples.auth0.com")
        .tokenExchange(withCode: "a code", codeVerifier: "code verifier", redirectURI: "https://samples.auth0.com/callback")
        .start { print($0) }
     ```

     - parameter code:         code returned after an `/oauth/authorize` request
     - parameter codeVerifier: verifier used to generate the challenge sent in `/oauth/authorize` request
     - parameter redirectURI:  redirect uri sent in `/oauth/authorize` request

     - returns: a request that will yield Auth0 user's credentials
     - seeAlso: https://tools.ietf.org/html/rfc7636
     */
    func tokenExchange(withCode code: String, codeVerifier: String, redirectURI: String) -> Request<Credentials, AuthenticationError>
}

/**
 Types of passwordless authentication

 - Code:        Simple OTP code sent by email or sms
 - WebLink:     Regular Web HTTP link (Web only, uses redirect)
 - iOSLink:     iOS 9 Universal Link
 - AndroidLink: Android App Link
 */
public enum PasswordlessType: String {
    case Code = "code"
    case WebLink = "link"
    case iOSLink = "link_ios"
    case AndroidLink = "link_android"
}

public extension Authentication {

    /**
     Logs in an user using email|username and password using a Database and Passwordless connection

     ```
     Auth0
        .authentication(clientId: clientId, domain: "samples.auth0.com")
        .login(usernameOrEmail: "support@auth0.com", password: "a secret password", connection: "Username-Password-Authentication")
        .start { result in
            switch result {
            case .Success(let credentials):
                print(credentials)
            case .Failure(let error):
                print(error)
            }
        }
     ```

     you can also specify scope and additional parameters

     ```
     Auth0
        .authentication(clientId: clientId, domain: "samples.auth0.com")
        .login(usernameOrEmail: "support@auth0.com", password:  "a secret password", connection: "Username-Password-Authentication", scope: "openid email", parameters: ["state": "a random state"])
        .start { print($0) }
     ```

     for passwordless connections

     ```
     Auth0
        .authentication(clientId: clientId, domain: "samples.auth0.com")
        .login(usernameOrEmail: "+4599134762367", password: "123456", connection: "sms", scope: "openid email", parameters: ["state": "a random state"])
        .start { print($0) }
     ```

     Also some enterprise connections, like Active Directory (AD), allows authentication using username/password without using the web flow.

     When result is `Successful`, a `Credentials` object will be in it's associated value with at least an `access_token` (depending on the scopes used to authenticate)

     - parameter usernameOrEmail:   username or email used of the user to authenticate, e.g. in email in Database connections or phone number for SMS connections.
     - parameter password:          password of the user or one time password (OTP) for passwordless connection users
     - parameter multifactorCode:   multifactor code if the user has enrolled one. e.g. Guardian. By default is `nil` and no code is sent.
     - parameter connection:        name of any of your configured database or passwordless connections
     - parameter scope:             scope value requested when authenticating the user. Default is 'openid'
     - parameter parameters:        additional parameters that are optionally sent with the authentication request

     - returns: authentication request that will yield Auth0 User Credentials
     - seeAlso: Credentials
     */
    public func login(usernameOrEmail username: String, password: String, multifactorCode: String? = nil, connection: String, scope: String = "openid", parameters: [String: Any] = [:]) -> Request<Credentials, AuthenticationError> {
        return self.login(usernameOrEmail: username, password: password, multifactorCode: multifactorCode, connection: connection, scope: scope, parameters: parameters)
    }

    /**
     Creates a user in a Database connection

     ```
     Auth0
        .authentication(clientId: clientId, domain: "samples.auth0.com")
        .createUser(email: "support@auth0.com", password: "a secret password", connection: "Username-Password-Authentication")
        .start { print($0) }
     ```

     you can also add additional attributes when creating the user

     ```
     Auth0
        .authentication(clientId: clientId, domain: "samples.auth0.com")
        .createUser(email: "support@auth0.com", password: "a secret password", connection: "Username-Password-Authentication", userMetadata: ["first_name": "support"])
        .start { print($0) }
     ```

     and if the database connection requires a username

     ```
     Auth0
        .authentication(clientId, domain: "samples.auth0.com")
        .createUser(email: "support@auth0.com", username: "support", password: "a secret password", connection: "Username-Password-Authentication")
        .start { print($0) }
     ```

     - parameter email:             email of the user to create
     - parameter username:          username of the user if the connection requires username. By default is 'nil'
     - parameter password:          password for the new user
     - parameter connection:        name where the user will be created (Database connection)
     - parameter userMetadata:      additional userMetadata parameters that will be added to the newly created user.

     - returns: request that will yield a created database user (just email, username and email verified flag)
     */
    public func createUser(email: String, username: String? = nil, password: String, connection: String, userMetadata: [String: Any]? = nil) -> Request<DatabaseUser, AuthenticationError> {
        return self.createUser(email: email, username: username, password: password, connection: connection, userMetadata: userMetadata)
    }

    /**
     Creates a database user and then authenticates the user against Auth0.

     ```
     Auth0
        .authentication(clientId: clientId, domain: "samples.auth0.com")
        .signUp(email: "support@auth0.com", password: "a secret password", connection: "Username-Password-Authentication")
        .start { print($0) }
     ```

     you can also add additional attributes when creating the user

     ```
     Auth0
        .authentication(clientId: clientId, domain: "samples.auth0.com")
        .signUp(email: "support@auth0.com", password: "a secret password", connection: "Username-Password-Authentication", userMetadata: ["first_name": "support"])
        .start { print($0) }
     ```

     and if the database connection requires a username

     ```
     Auth0
        .authentication(clientId: clientId, domain: "samples.auth0.com")
        .signUp(email: "support@auth0.com", username: "support", password: "a secret password", connection: "Username-Password-Authentication")
        .start { print($0) }
     ```

     or specifying the scope and parameters used for authentication

     ```
     Auth0
        .authentication(clientId: clientId, domain: "samples.auth0.com")
        .signUp(email: "support@auth0.com", password: "a secret password", connection: "Username-Password-Authentication", scope: "openid email", parameters: ["state": "a random state"])
        .start { print($0) }
     ```

     - parameter email:        email of the new user
     - parameter username:     username of the user if connections requires username. By default is 'nil'
     - parameter password:     password for the new user
     - parameter connection:   name of the Database connection where the user will be created
     - parameter userMetadata: additional userMetadata values added when creating the user
     - parameter scope:        requested scope value when authenticating the user. By default is 'openid'
     - parameter parameters:   additional parameters sent during authentication

     - returns: an authentication request that will yield Auth0 user credentials after creating the user.
     */
    public func signUp(email: String, username: String? = nil, password: String, connection: String, userMetadata: [String: Any]? = nil, scope: String = "openid", parameters: [String: Any] = [:]) -> ConcatRequest<DatabaseUser, Credentials, AuthenticationError> {
        return self.signUp(email: email, username: username, password: password, connection: connection, userMetadata: userMetadata, scope: scope, parameters: parameters)
    }

    /**
     Starts passwordless authentication by sending an email with a OTP code

     ```
     Auth0
        .authentication(clientId: clientId, domain: "samples.auth0.com")
        .startPasswordless(email: "support@auth0.com")
        .start { print($0) }
     ```

     or if you have configured iOS Universal Links

     ```
     Auth0
        .authentication(clientId: clientId, domain: "samples.auth0.com")
        .startPasswordless(email: "support@auth0.com", type: .iOSLink)
        .start { print($0) }
     ```

     - parameter email:      email where to send the code or link
     - parameter type:       type of passwordless authentication/ By default is code
     - parameter connection: name of the passwordless connection. By default is 'email'
     - parameter parameters: additional authentication parameters added for Web link. Ignored in other types

     - returns: a request
     */
    public func startPasswordless(email: String, type: PasswordlessType = .Code, connection: String = "email", parameters: [String: Any] = [:]) -> Request<Void, AuthenticationError> {
        return self.startPasswordless(email: email, type: type, connection: connection, parameters: parameters)
    }

    /**
     Starts passwordless authentication by sending an sms with an OTP code

     ```
     Auth0
        .authentication(clientId: clientId, domain: "samples.auth0.com")
        .startPasswordless(phoneNumber: "support@auth0.com")
        .start { print($0) }
     ```

     or if you have configured iOS Universal Links

     ```
     Auth0
        .authentication(clientId: clientId, domain: "samples.auth0.com")
        .startPasswordless(phoneNumber: "support@auth0.com", type: .iOSLink)
        .start { print($0) }
     ```

     - parameter phoneNumber:   phone number where to send the sms with code or link
     - parameter type:          type of passwordless authentication. By default is code
     - parameter connection:    name of the passwordless connection. By default is 'sms'

     - returns: a request
     */
    public func startPasswordless(phoneNumber: String, type: PasswordlessType = .Code, connection: String = "sms") -> Request<Void, AuthenticationError> {
        return self.startPasswordless(phoneNumber: phoneNumber, type: type, connection: connection)
    }

    /**
     Logs in a user using a social Identity Provider token. e.g. Facebook

     ```
     Auth0
        .authentication(clientId: clientId, domain: "samples.auth0.com")
        .loginSocial(token: fbToken, connection: "facebook")
        .start { print($0) }
     ```

     and if you need to specify a scope or add additional parameters

     ```
     Auth0
        .authentication(clientId: clientId, domain: "samples.auth0.com")
        .loginSocial(token: fbToken, connection: "facebook", scope: "openid email", parameters: ["state": "a random state"])
        .start { print($0) }
     ```

     - parameter token:      token obtained from a social IdP
     - parameter connection: name of the social connection. Only works with 'google-oauth2', 'facebook' and 'twitter'
     - parameter scope:      requested scope value when authenticating the user. By default is 'openid'
     - parameter parameters: additional parameters sent during authentication

     - returns: a request that will yield Auth0 user's credentials
     */
    public func loginSocial(token: String, connection: String, scope: String = "openid", parameters: [String: Any] = [:]) -> Request<Credentials, AuthenticationError> {
        return self.loginSocial(token: token, connection: connection, scope: scope, parameters: parameters)
    }
}
