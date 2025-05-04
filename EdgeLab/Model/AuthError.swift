//
//  AuthError.swift
//  EdgeLab
//
//  Created by user270106 on 5/3/25.
//

import Foundation

enum AuthError: Error {
    case invalidEmail
    case weakPassword
    case passwordsDontMatch
    case emailAlreadyExists
    case invalidCredentials
}
